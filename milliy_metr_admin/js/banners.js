let allBanners = [];

document.addEventListener('DOMContentLoaded', () => {
  auth.requireAuth();
  layout.inject();
  
  loadBanners();
  
  document.getElementById('btn-add-banner').addEventListener('click', () => openModal());
  document.getElementById('btn-close-modal').addEventListener('click', closeModal);
  document.getElementById('btn-cancel-modal').addEventListener('click', closeModal);
  document.getElementById('btn-save-banner').addEventListener('click', saveBanner);
  
  document.getElementById('banner-img-upload').addEventListener('change', async (e) => {
    const file = e.target.files[0];
    if (!file) return;
    // Compress image before uploading
    const compressedFile = await ImageCompressor.compress(file, {
      maxWidth: 1024,
      maxHeight: 576, // 16:9 approx max for banners
      quality: 0.8
    });
    
    const formData = new FormData();
    formData.append('file', compressedFile);
    
    try {
      const res = await api.post('/upload/image', formData);
      if (res.data && res.data.url) {
        document.getElementById('banner-image-url').value = res.data.url;
        const preview = document.getElementById('banner-img-preview');
        preview.src = CONFIG.API_BASE_URL.replace('/api/v1', '') + res.data.url;
        preview.style.display = 'block';
        layout.showToast('Rasm yuklandi');
      }
    } catch (err) {
      layout.showToast(err.message, 'error');
    }
  });
});

async function loadBanners() {
  const tbody = document.getElementById('banner-list');
  try {
    const res = await api.get('/banners'); // Get all banners
    allBanners = res.data || [];
    renderBannerTable();
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="6" class="text-center text-danger">${err.message}</td></tr>`;
  }
}

function renderBannerTable() {
  const tbody = document.getElementById('banner-list');
  
  if (allBanners.length === 0) {
    tbody.innerHTML = `<tr><td colspan="6" class="text-center">Bannerlar mavjud emas</td></tr>`;
    return;
  }
  
  tbody.innerHTML = allBanners.map(b => {
    const imgSrc = b.image_url ? (CONFIG.API_BASE_URL.replace('/api/v1', '') + b.image_url) : '';
    const statusHtml = b.is_active 
      ? '<span class="badge badge-success">Faol</span>' 
      : '<span class="badge badge-neutral">Nofaol</span>';
      
    return `
      <tr>
        <td>
          <img src="${imgSrc}" style="width: 100px; height: 50px; border-radius: 4px; object-fit: cover; background: #eee;">
        </td>
        <td>${b.title || '-'}</td>
        <td>${b.link_url || '-'}</td>
        <td>${b.order_index}</td>
        <td>${statusHtml}</td>
        <td class="text-center">
          <button class="btn btn-sm btn-outline" style="padding: 0 8px;" onclick="openModal('${b.id}')"><span class="material-symbols-rounded" style="font-size: 18px;">edit</span></button>
          <button class="btn btn-sm btn-danger" style="padding: 0 8px;" onclick="deleteBanner('${b.id}')"><span class="material-symbols-rounded" style="font-size: 18px;">delete</span></button>
        </td>
      </tr>
    `;
  }).join('');
}

function openModal(id = null) {
  const modal = document.getElementById('banner-modal');
  const title = document.getElementById('modal-title');
  const form = document.getElementById('banner-form');
  const preview = document.getElementById('banner-img-preview');
  
  form.reset();
  document.getElementById('banner-id').value = '';
  document.getElementById('banner-image-url').value = '';
  preview.style.display = 'none';
  document.getElementById('banner-active').checked = true;
  document.getElementById('banner-order').value = "0";
  
  if (id) {
    title.textContent = 'Bannerni Tahrirlash';
    const b = allBanners.find(x => x.id === id);
    if (b) {
      document.getElementById('banner-id').value = b.id;
      document.getElementById('banner-title').value = b.title || '';
      document.getElementById('banner-link').value = b.link_url || '';
      document.getElementById('banner-order').value = b.order_index || 0;
      document.getElementById('banner-active').checked = b.is_active;
      
      if (b.image_url) {
        document.getElementById('banner-image-url').value = b.image_url;
        preview.src = CONFIG.API_BASE_URL.replace('/api/v1', '') + b.image_url;
        preview.style.display = 'block';
      }
    }
  } else {
    title.textContent = "Banner Qo'shish";
  }
  
  modal.classList.add('active');
}

function closeModal() {
  document.getElementById('banner-modal').classList.remove('active');
}

async function saveBanner() {
  const id = document.getElementById('banner-id').value;
  const imgUrl = document.getElementById('banner-image-url').value;
  
  if (!imgUrl) {
    layout.showToast("Rasm kiritilishi shart!", 'error');
    return;
  }
  
  const payload = {
    title: document.getElementById('banner-title').value || null,
    link_url: document.getElementById('banner-link').value || null,
    image_url: imgUrl,
    order_index: parseInt(document.getElementById('banner-order').value) || 0,
    is_active: document.getElementById('banner-active').checked
  };
  
  const btn = document.getElementById('btn-save-banner');
  btn.disabled = true;
  btn.textContent = 'Saqlanmoqda...';
  
  try {
    if (id) {
      await api.put(`/banners/${id}`, payload);
      layout.showToast('Banner yangilandi');
    } else {
      await api.post('/banners', payload);
      layout.showToast('Banner qo\'shildi');
    }
    closeModal();
    loadBanners();
  } catch (err) {
    layout.showToast(err.message, 'error');
  } finally {
    btn.disabled = false;
    btn.textContent = 'Saqlash';
  }
}

async function deleteBanner(id) {
  if (!confirm('Rostdan ham ushbu bannerni o\'chirmoqchimisiz?')) return;
  
  try {
    await api.delete(`/banners/${id}`);
    layout.showToast('Banner o\'chirildi');
    loadBanners();
  } catch (err) {
    layout.showToast(err.message, 'error');
  }
}
