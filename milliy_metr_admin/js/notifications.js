document.addEventListener('DOMContentLoaded', () => {
  auth.requireAuth();
  layout.inject();
  
  loadNotifications();
  
  document.getElementById('btn-add-notification').addEventListener('click', () => openModal());
  document.getElementById('btn-close-modal').addEventListener('click', closeModal);
  document.getElementById('btn-cancel-modal').addEventListener('click', closeModal);
  document.getElementById('btn-save-notif').addEventListener('click', sendBroadcast);
  
  document.getElementById('notif-img-upload').addEventListener('change', async (e) => {
    const file = e.target.files[0];
    if (!file) return;
    // Compress image before uploading
    const compressedFile = await ImageCompressor.compress(file, {
      maxWidth: 800,
      maxHeight: 600,
      quality: 0.8
    });
    
    const formData = new FormData();
    formData.append('file', compressedFile);
    
    try {
      const res = await api.post('/upload/image', formData);
      if (res.data && res.data.url) {
        document.getElementById('notif-image-url').value = res.data.url;
        const preview = document.getElementById('notif-img-preview');
        preview.src = CONFIG.API_BASE_URL.replace('/api/v1', '') + res.data.url;
        preview.style.display = 'block';
        layout.showToast('Rasm yuklandi');
      }
    } catch (err) {
      layout.showToast(err.message, 'error');
    }
  });
});

async function loadNotifications() {
  const tbody = document.getElementById('notification-list');
  try {
    const res = await api.get('/notifications');
    const notifs = res.data || [];
    
    if (notifs.length === 0) {
      tbody.innerHTML = `<tr><td colspan="5" class="text-center">Xabarlar tarixi bo'sh</td></tr>`;
      return;
    }
    
    tbody.innerHTML = notifs.map(n => {
      const imgSrc = n.image_url ? (CONFIG.API_BASE_URL.replace('/api/v1', '') + n.image_url) : '';
      const imgHtml = imgSrc 
        ? `<img src="${imgSrc}" style="width: 40px; height: 40px; border-radius: 4px; object-fit: cover;">` 
        : '-';
        
      const dateStr = n.created_at ? new Date(n.created_at).toLocaleString('ru-RU') : '-';
        
      return `
        <tr>
          <td>${imgHtml}</td>
          <td style="font-weight: 500;">${n.title || '-'}</td>
          <td style="max-width: 300px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">${n.body || '-'}</td>
          <td><span class="badge badge-neutral">${n.target || 'Barchaga'}</span></td>
          <td>${dateStr}</td>
        </tr>
      `;
    }).join('');
    
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="5" class="text-center text-danger">${err.message}</td></tr>`;
  }
}

function openModal() {
  const modal = document.getElementById('notification-modal');
  const form = document.getElementById('notification-form');
  const preview = document.getElementById('notif-img-preview');
  
  form.reset();
  document.getElementById('notif-image-url').value = '';
  preview.style.display = 'none';
  
  modal.classList.add('active');
}

function closeModal() {
  document.getElementById('notification-modal').classList.remove('active');
}

async function sendBroadcast() {
  const title = document.getElementById('notif-title').value;
  const body = document.getElementById('notif-body').value;
  
  if (!title || !body) {
    layout.showToast('Sarlavha va matn kiritilishi shart!', 'error');
    return;
  }
  
  const payload = {
    title: title,
    body: body,
    image_url: document.getElementById('notif-image-url').value || null,
    target: document.getElementById('notif-target').value || 'all'
  };
  
  const btn = document.getElementById('btn-save-notif');
  btn.disabled = true;
  btn.innerHTML = 'Yuborilmoqda...';
  
  try {
    await api.post('/notifications/broadcast', payload);
    layout.showToast('Xabar yuborildi!');
    closeModal();
    loadNotifications();
  } catch (err) {
    layout.showToast(err.message, 'error');
  } finally {
    btn.disabled = false;
    btn.innerHTML = '<span class="material-symbols-rounded">send</span> Yuborish';
  }
}
