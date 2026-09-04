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
  
  document.getElementById('btn-add-spec').addEventListener('click', () => addSpecRow());
  document.getElementById('prod-unit').addEventListener('change', handleUnitChange);
  
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
    const catId = p.categoryId || p.category_id;
    if (catId) {
      const c = categories.find(x => x.id === catId);
      if (c) catName = typeof c.name === 'object' ? c.name.uz : c.name;
    }
    
    const imgSrc = (p.images && p.images.length > 0) ? api.getImageUrl(p.images[0]) : (p.imageUrl ? api.getImageUrl(p.imageUrl) : '');
    const imgHtml = imgSrc 
      ? `<img src="${imgSrc}" style="width: 48px; height: 48px; border-radius: 4px; object-fit: cover;">` 
      : `<div style="width: 48px; height: 48px; background: #eee; border-radius: 4px;"></div>`;
      
    const price = parseInt(p.price || 0).toLocaleString('ru-RU') + ' so\'m';
    const stock = p.stock !== undefined ? p.stock : (p.stockQuantity !== undefined ? p.stockQuantity : 0);
    
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
      
      document.getElementById('prod-category').value = p.categoryId || p.category_id || '';
      document.getElementById('prod-price').value = p.price || '';
      document.getElementById('prod-discount-price').value = p.discountPrice || p.discount_price || '';
      document.getElementById('prod-unit').value = p.unit || 'dona';
      document.getElementById('prod-stock').value = p.stock !== undefined ? p.stock : (p.stockQuantity !== undefined ? p.stockQuantity : 0);
      document.getElementById('prod-has-delivery').checked = p.hasDelivery !== undefined ? p.hasDelivery : (p.has_delivery !== undefined ? p.has_delivery : true);
      document.getElementById('prod-brand').value = p.brand || '';
      document.getElementById('prod-moq').value = p.moq || 1;
      document.getElementById('prod-delivery-info').value = p.delivery_information || '';
      
      productImages = p.images || [];
      renderImages();
      
      const specs = p.specifications || {};
      renderSpecs(specs);
      
    } catch (err) {
      layout.showToast(err.message, 'error');
      return;
    }
  } else {
    title.textContent = "Mahsulot Qo'shish";
    currentEditProduct = null;
    document.getElementById('prod-moq').value = 1;
    document.getElementById('prod-delivery-info').value = '';
    renderSpecs({});
    handleUnitChange();
  }
  
  modal.classList.add('active');
}

function closeModal() {
  document.getElementById('product-modal').classList.remove('active');
}

function renderImages() {
  const container = document.getElementById('prod-image-list');
  container.innerHTML = productImages.map((url, index) => {
    const fullUrl = api.getImageUrl(url);
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
  
  const payload = {
    name: { uz: document.getElementById('prod-name-uz').value, ru: document.getElementById('prod-name-ru').value },
    description: { uz: document.getElementById('prod-desc-uz').value, ru: document.getElementById('prod-desc-ru').value },
    categoryId: document.getElementById('prod-category').value,
    price: parseFloat(document.getElementById('prod-price').value) || 0,
    discountPrice: parseFloat(document.getElementById('prod-discount-price').value) || null,
    unit: document.getElementById('prod-unit').value,
    stock: parseInt(document.getElementById('prod-stock').value) || 0,
    hasDelivery: document.getElementById('prod-has-delivery').checked,
    brand: document.getElementById('prod-brand').value || null,
    images: productImages,
    moq: parseInt(document.getElementById('prod-moq').value) || 1,
    delivery_information: document.getElementById('prod-delivery-info').value || null,
    specifications: serializeSpecs()
  };
  
  
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

let importPreviewData = []; // store preview rows for confirm step

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
  btn.innerHTML = '<span class="material-symbols-rounded">hourglass_top</span> Tekshirilmoqda...';
  
  try {
    const res = await api.post('/admin/products/import/preview', formData);
    const data = res.data || res;
    
    importPreviewData = data.rows || [];
    const stats = data.stats || {};
    
    // Show stats
    const statsEl = document.getElementById('import-stats');
    statsEl.innerHTML = `
      <span class="badge badge-neutral" style="padding: 8px 12px; height: auto;">Jami: ${stats.total || 0}</span>
      <span class="badge badge-success" style="padding: 8px 12px; height: auto;">Tayyor: ${stats.valid || 0}</span>
      ${stats.duplicates ? `<span class="badge badge-warning" style="padding: 8px 12px; height: auto;">Dublikat: ${stats.duplicates}</span>` : ''}
      ${stats.invalid ? `<span class="badge badge-danger" style="padding: 8px 12px; height: auto;">Xatolik: ${stats.invalid}</span>` : ''}
      ${stats.needs_review ? `<span class="badge badge-warning" style="padding: 8px 12px; height: auto;">Tekshirish: ${stats.needs_review}</span>` : ''}
    `;
    
    // Render preview table
    const tbody = document.getElementById('import-preview-body');
    tbody.innerHTML = importPreviewData.map(row => {
      let statusBadge = 'badge-neutral';
      let statusText = row.status;
      if (row.status === 'Valid') { statusBadge = 'badge-success'; statusText = 'Tayyor'; }
      else if (row.status === 'Error') { statusBadge = 'badge-danger'; statusText = 'Xato'; }
      else if (row.status === 'Duplicate') { statusBadge = 'badge-warning'; statusText = 'Dublikat'; }
      else if (row.status === 'Needs Review') { statusBadge = 'badge-warning'; statusText = 'Tekshirish'; }
      
      const price = parseFloat(row.price || 0).toLocaleString('ru-RU');
      
      return `<tr>
        <td>${row.row_index}</td>
        <td style="font-weight: 500;">${row.name || '-'}</td>
        <td>${price}</td>
        <td>${row.stock || 0}</td>
        <td>${row.detected_category || '-'}</td>
        <td>
          <span class="badge ${statusBadge}">${statusText}</span>
          ${row.errors && row.errors.length ? `<div style="font-size: 11px; color: var(--color-danger); margin-top: 4px;">${row.errors.join(', ')}</div>` : ''}
        </td>
      </tr>`;
    }).join('');
    
    // Toggle steps
    document.getElementById('import-step-upload').style.display = 'none';
    document.getElementById('import-step-preview').style.display = 'block';
    btn.style.display = 'none';
    
    // Show confirm button only if there are valid rows
    const validRows = importPreviewData.filter(r => r.status === 'Valid' || r.status === 'Needs Review');
    if (validRows.length > 0) {
      const confirmBtn = document.getElementById('btn-confirm-import');
      confirmBtn.style.display = 'inline-flex';
      confirmBtn.onclick = confirmImport;
    }
    
    layout.showToast(`${importPreviewData.length} ta qator topildi`);
  } catch (err) {
    layout.showToast(err.message, 'error');
  } finally {
    btn.disabled = false;
    btn.innerHTML = '<span class="material-symbols-rounded">upload_file</span> Yuklash va Ko\'rish';
  }
}

async function confirmImport() {
  const validRows = importPreviewData.filter(r => r.status !== 'Error');
  
  if (validRows.length === 0) {
    layout.showToast('Import qiladigan qator topilmadi', 'error');
    return;
  }
  
  const btn = document.getElementById('btn-confirm-import');
  btn.disabled = true;
  btn.innerHTML = '<span class="material-symbols-rounded">hourglass_top</span> Import qilinmoqda...';
  
  try {
    const res = await api.post('/admin/products/import', validRows);
    const result = res.data || res;
    
    layout.showToast(`${result.imported || 0} ta mahsulot import qilindi!`);
    closeImportModal();
    loadProducts();
  } catch (err) {
    layout.showToast(err.message, 'error');
  } finally {
    btn.disabled = false;
    btn.innerHTML = '<span class="material-symbols-rounded">check_circle</span> Import qilish';
  }
}

function closeImportModal() {
  document.getElementById('import-modal').classList.remove('active');
  // Reset modal state
  document.getElementById('import-step-upload').style.display = 'block';
  document.getElementById('import-step-preview').style.display = 'none';
  document.getElementById('btn-upload-excel').style.display = 'inline-flex';
  document.getElementById('btn-confirm-import').style.display = 'none';
  document.getElementById('excel-file').value = '';
  importPreviewData = [];
}

function handleUnitChange() {
  if (currentEditProduct) return; // Do not overwrite existing specs when editing
  
  const unit = document.getElementById('prod-unit').value;
  let labels = [];
  
  switch(unit) {
    case 'kv.m':
      labels = ["Qadoqdagi maydon (m²)", "Qalinligi (mm)", "Material turi", "Rangi"];
      break;
    case 'kg':
      labels = ["Qadoq og'irligi (kg)", "Markasi/Brendi", "Qotish vaqti"];
      break;
    case 'metr':
      labels = ["Uzunligi (m)", "Diametri (mm)", "Material turi"];
      break;
    case 'litr':
      labels = ["Hajmi (litr)", "1 litr necha m² yetadi", "Qurish vaqti"];
      break;
    case 'dona':
      labels = ["O'lchamlari (UzxKxQ)", "Og'irligi (kg)", "Material"];
      break;
    case 'm3':
      labels = ["Fraksiya/o'lcham", "Zichligi"];
      break;
    case 'rulon':
      labels = ["Rulon uzunligi (m)", "Kengligi (m)"];
      break;
    case 'komplekt':
      labels = ["Tarkibidagi dona soni"];
      break;
    case 'tonna':
      labels = ["Fraksiya", "Kelib chiqishi"];
      break;
  }
  
  const specs = {};
  labels.forEach(l => specs[l] = '');
  renderSpecs(specs);
}

function renderSpecs(specs) {
  const container = document.getElementById('specs-container');
  container.innerHTML = '';
  
  const keys = Object.keys(specs);
  if (keys.length === 0) {
    // Add one empty row by default if none
    addSpecRow('', '');
  } else {
    keys.forEach(k => addSpecRow(k, specs[k]));
  }
}

function addSpecRow(key = '', value = '') {
  const container = document.getElementById('specs-container');
  
  const div = document.createElement('div');
  div.className = 'd-flex gap-8 align-items-center spec-row';
  div.innerHTML = `
    <input type="text" class="form-control spec-key" placeholder="Nomi (masalan: Og'irligi)" value="${key}" style="flex: 1;">
    <input type="text" class="form-control spec-value" placeholder="Qiymati (masalan: 10 kg)" value="${value}" style="flex: 1;">
    <button type="button" class="btn btn-sm btn-outline" style="padding: 0 8px; color: var(--color-danger); border-color: var(--color-danger);" onclick="this.parentElement.remove()">
      <span class="material-symbols-rounded" style="font-size: 18px;">delete</span>
    </button>
  `;
  container.appendChild(div);
}

function serializeSpecs() {
  const specs = {};
  const rows = document.querySelectorAll('#specs-container .spec-row');
  rows.forEach(r => {
    const key = r.querySelector('.spec-key').value.trim();
    const value = r.querySelector('.spec-value').value.trim();
    if (key && value) {
      specs[key] = value;
    }
  });
  return Object.keys(specs).length > 0 ? specs : null;
}
