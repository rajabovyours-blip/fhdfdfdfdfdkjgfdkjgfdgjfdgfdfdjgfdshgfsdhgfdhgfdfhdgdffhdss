let categories = [];
let currentPage = 1;
let totalPages = 1;
let currentLimit = 10;
let productImages = []; // store urls of uploaded images

document.addEventListener('DOMContentLoaded', () => {
  auth.requireAuth();
  layout.inject();
  
  loadCategories();
  loadProducts();
  
  document.getElementById('btn-add-product').addEventListener('click', () => openModal());
  document.getElementById('btn-close-modal').addEventListener('click', closeModal);
  document.getElementById('btn-cancel-modal').addEventListener('click', closeModal);
  document.getElementById('btn-save-product').addEventListener('click', saveProduct);
  
  document.getElementById('btn-search').addEventListener('click', () => {
    currentPage = 1;
    loadProducts();
  });
  
  document.getElementById('prod-img-upload').addEventListener('change', async (e) => {
    const file = e.target.files[0];
    if (!file) return;
    // Compress image before uploading
    const compressedFile = await ImageCompressor.compress(file, {
      maxWidth: 800,
      maxHeight: 800,
      quality: 0.8
    });
    
    const formData = new FormData();
    formData.append('file', compressedFile);
    
    try {
      const res = await api.post('/upload/image', formData);
      if (res.data && res.data.url) {
        productImages.push(res.data.url);
        renderImages();
        layout.showToast('Rasm yuklandi');
      }
    } catch (err) {
      layout.showToast(err.message, 'error');
    }
    
    e.target.value = ''; // reset input
  });
  
  // Excel import
  document.getElementById('btn-import-excel').addEventListener('click', () => {
    document.getElementById('import-modal').classList.add('active');
  });
  document.getElementById('btn-upload-excel').addEventListener('click', uploadExcel);
});

async function loadCategories() {
  try {
    const res = await api.get('/categories');
    categories = res.data || [];
    
    const filterSelect = document.getElementById('category-filter');
    const formSelect = document.getElementById('prod-category');
    
    let options = '';
    categories.forEach(c => {
      let nameUz = typeof c.name === 'object' ? c.name.uz : c.name;
      options += `<option value="${c.id}">${nameUz}</option>`;
    });
    
    filterSelect.innerHTML += options;
    formSelect.innerHTML = '<option value="">Tanlang...</option>' + options;
  } catch (err) {
    console.error("Categories error:", err);
  }
}

async function loadProducts() {
  const tbody = document.getElementById('product-list');
  const q = document.getElementById('search-input').value;
  const cat = document.getElementById('category-filter').value;
  
  let url = `/products?page=${currentPage}&limit=${currentLimit}`;
  if (q) url += `&search=${encodeURIComponent(q)}`;
  if (cat) url += `&category_id=${cat}`;
  
  tbody.innerHTML = `<tr><td colspan="6" class="text-center">Yuklanmoqda...</td></tr>`;
  
  try {
    const res = await api.get(url);
    const data = res.data || [];
    
    // Pagination data might be in res.meta or res.total_pages, but backend might not return it cleanly.
    // If it returns total count:
    const total = res.total || (data.length === currentLimit ? currentPage * currentLimit + 1 : currentPage * currentLimit);
    totalPages = Math.ceil(total / currentLimit);
    
    renderTable(data);
    renderPagination();
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="6" class="text-center text-danger">${err.message}</td></tr>`;
  }
}

function renderTable(products) {
  const tbody = document.getElementById('product-list');
  
  if (products.length === 0) {
    tbody.innerHTML = `<tr><td colspan="6" class="text-center">Mahsulotlar topilmadi</td></tr>`;
    return;
  }
  
  tbody.innerHTML = products.map(p => {
    let nameUz = typeof p.name === 'object' ? p.name.uz : p.name;
    
    let catName = 'Noma\'lum';
    if (p.category_id) {
      const c = categories.find(x => x.id === p.category_id);
      if (c) catName = typeof c.name === 'object' ? c.name.uz : c.name;
    }
    
    const imgSrc = (p.images && p.images.length > 0) ? (CONFIG.API_BASE_URL.replace('/api/v1', '') + p.images[0]) : '';
    const imgHtml = imgSrc 
      ? `<img src="${imgSrc}" style="width: 48px; height: 48px; border-radius: 4px; object-fit: cover;">` 
      : `<div style="width: 48px; height: 48px; background: #eee; border-radius: 4px;"></div>`;
      
    const price = parseInt(p.price).toLocaleString('ru-RU') + ' so\'m';
    const stock = p.stock_quantity;
    
    let stockHtml = `<span style="color: var(--color-success); font-weight: 500;">${stock}</span>`;
    if (stock <= 5) stockHtml = `<span style="color: var(--color-danger); font-weight: 500;">${stock}</span>`;
    
    return `
      <tr>
        <td>${imgHtml}</td>
        <td style="font-weight: 500;">${nameUz}</td>
        <td><span class="badge badge-neutral">${catName}</span></td>
        <td>${price}</td>
        <td>${stockHtml}</td>
        <td class="text-center">
          <button class="btn btn-sm btn-outline" style="padding: 0 8px;" onclick="openModal('${p.id}')"><span class="material-symbols-rounded" style="font-size: 18px;">edit</span></button>
          <button class="btn btn-sm btn-danger" style="padding: 0 8px;" onclick="deleteProduct('${p.id}')"><span class="material-symbols-rounded" style="font-size: 18px;">delete</span></button>
        </td>
      </tr>
    `;
  }).join('');
}

function renderPagination() {
  const container = document.getElementById('pagination');
  if (totalPages <= 1) {
    container.innerHTML = '';
    return;
  }
  
  let html = `<button onclick="changePage(${currentPage - 1})" ${currentPage === 1 ? 'disabled' : ''}><span class="material-symbols-rounded">chevron_left</span></button>`;
  
  for (let i = 1; i <= totalPages; i++) {
    // Basic logic to show current, first, last, and neighbors
    if (i === 1 || i === totalPages || (i >= currentPage - 1 && i <= currentPage + 1)) {
        html += `<button class="${i === currentPage ? 'active' : ''}" onclick="changePage(${i})">${i}</button>`;
    } else if (i === currentPage - 2 || i === currentPage + 2) {
        html += `<button disabled>...</button>`;
    }
  }
  
  html += `<button onclick="changePage(${currentPage + 1})" ${currentPage === totalPages ? 'disabled' : ''}><span class="material-symbols-rounded">chevron_right</span></button>`;
  
  container.innerHTML = html;
}

function changePage(p) {
  if (p < 1 || p > totalPages) return;
  currentPage = p;
  loadProducts();
}

// Global variable for edit to avoid re-fetching
let currentEditProduct = null;

async function openModal(id = null) {
  const modal = document.getElementById('product-modal');
  const title = document.getElementById('modal-title');
  const form = document.getElementById('product-form');
  
  form.reset();
  document.getElementById('prod-id').value = '';
  productImages = [];
  renderImages();
  
  if (id) {
    title.textContent = 'Mahsulotni Tahrirlash';
    try {
      const res = await api.get(`/products/${id}`);
      const p = res.data;
      currentEditProduct = p;
      
      document.getElementById('prod-id').value = p.id;
      
      if (typeof p.name === 'object') {
        document.getElementById('prod-name-uz').value = p.name.uz || '';
        document.getElementById('prod-name-ru').value = p.name.ru || '';
      } else {
        document.getElementById('prod-name-uz').value = p.name || '';
      }
      
      if (typeof p.description === 'object') {
        document.getElementById('prod-desc-uz').value = p.description.uz || '';
        document.getElementById('prod-desc-ru').value = p.description.ru || '';
      } else {
        document.getElementById('prod-desc-uz').value = p.description || '';
      }
      
      document.getElementById('prod-category').value = p.category_id || '';
      document.getElementById('prod-price').value = p.price || '';
      document.getElementById('prod-discount-price').value = p.discount_price || '';
      document.getElementById('prod-unit').value = p.unit || 'dona';
      document.getElementById('prod-stock').value = p.stock_quantity || 0;
      document.getElementById('prod-brand').value = p.brand || '';
      
      productImages = p.images || [];
      renderImages();
      
    } catch (err) {
      layout.showToast(err.message, 'error');
      return;
    }
  } else {
    title.textContent = "Mahsulot Qo'shish";
    currentEditProduct = null;
  }
  
  modal.classList.add('active');
}

function closeModal() {
  document.getElementById('product-modal').classList.remove('active');
}

function renderImages() {
  const container = document.getElementById('prod-image-list');
  container.innerHTML = productImages.map((url, index) => {
    const fullUrl = CONFIG.API_BASE_URL.replace('/api/v1', '') + url;
    return `
      <div class="product-img-item">
        <img src="${fullUrl}">
        <button type="button" class="product-img-remove" onclick="removeImage(${index})">&times;</button>
      </div>
    `;
  }).join('');
}

window.removeImage = function(index) {
  productImages.splice(index, 1);
  renderImages();
};

async function saveProduct() {
  const id = document.getElementById('prod-id').value;
  
  if (!document.getElementById('prod-category').value) {
    layout.showToast("Kategoriya tanlanishi shart", 'error');
    return;
  }
  
  const nameUz = document.getElementById('prod-name-uz').value;
  const descUz = document.getElementById('prod-desc-uz').value;
  
  const payload = {
    name: {
      uz: nameUz,
      ru: document.getElementById('prod-name-ru').value || nameUz,
      en: nameUz
    },
    description: {
      uz: descUz,
      ru: document.getElementById('prod-desc-ru').value || descUz,
      en: descUz
    },
    price: parseFloat(document.getElementById('prod-price').value) || 0,
    category_id: document.getElementById('prod-category').value,
    unit: document.getElementById('prod-unit').value,
    stock_quantity: parseInt(document.getElementById('prod-stock').value) || 0,
    images: productImages
  };
  
  const discount = document.getElementById('prod-discount-price').value;
  if (discount) payload.discount_price = parseFloat(discount);
  
  const brand = document.getElementById('prod-brand').value;
  if (brand) payload.brand = brand;
  
  const btn = document.getElementById('btn-save-product');
  btn.disabled = true;
  btn.textContent = 'Saqlanmoqda...';
  
  try {
    if (id) {
      await api.put(`/products/${id}`, payload);
      layout.showToast('Mahsulot yangilandi');
    } else {
      await api.post('/products', payload);
      layout.showToast('Mahsulot qo\'shildi');
    }
    closeModal();
    loadProducts();
  } catch (err) {
    layout.showToast(err.message, 'error');
  } finally {
    btn.disabled = false;
    btn.textContent = 'Saqlash';
  }
}

async function deleteProduct(id) {
  if (!confirm('Rostdan ham ushbu mahsulotni o\'chirmoqchimisiz?')) return;
  
  try {
    await api.delete(`/products/${id}`);
    layout.showToast('Mahsulot o\'chirildi');
    loadProducts();
  } catch (err) {
    layout.showToast(err.message, 'error');
  }
}

async function uploadExcel() {
  const fileInput = document.getElementById('excel-file');
  if (!fileInput.files[0]) {
    layout.showToast('Faylni tanlang', 'error');
    return;
  }
  
  const formData = new FormData();
  formData.append('file', fileInput.files[0]);
  
  const btn = document.getElementById('btn-upload-excel');
  btn.disabled = true;
  btn.textContent = 'Yuklanmoqda...';
  
  try {
    // Usually POST /admin/products/import/preview then confirm. 
    // This is a simplified direct trigger for the preview endpoint.
    const res = await api.post('/admin/products/import/preview', formData, {
      headers: {} // let fetch set content-type for multipart
    });
    
    // We would normally show a preview table here. For now just show a success message.
    layout.showToast(`Import tayyor: ${res.data?.length || 0} ta qator.`);
    document.getElementById('import-modal').classList.remove('active');
  } catch (err) {
    layout.showToast(err.message, 'error');
  } finally {
    btn.disabled = false;
    btn.textContent = 'Yuklash va Ko\'rish';
  }
}
