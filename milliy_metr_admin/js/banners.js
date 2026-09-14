let allBanners = [];

document.addEventListener('DOMContentLoaded', () => {
  auth.requireAuth();
  layout.inject();
  
  loadBanners();
  
  document.getElementById('btn-add-banner').addEventListener('click', () => openModal());
  document.getElementById('btn-close-modal').addEventListener('click', closeModal);
  document.getElementById('btn-cancel-modal').addEventListener('click', closeModal);
  document.getElementById('btn-save-banner').addEventListener('click', saveBanner);

  document.getElementById('media-type-image').addEventListener('change', () => setMediaTypeUI('image'));
  document.getElementById('media-type-video').addEventListener('change', () => setMediaTypeUI('video'));
  
  document.getElementById('banner-img-upload').addEventListener('change', async (e) => {
    const file = e.target.files[0];
    if (!file) return;
    // Compress image before uploading — to'liq HD (1080p)
    const compressedFile = await ImageCompressor.compress(file, {
      maxWidth: 1920,
      maxHeight: 1080, // 16:9, to'liq HD
      quality: 0.92
    });
    
    const formData = new FormData();
    formData.append('file', compressedFile);
    
    try {
      const res = await api.post('/upload/image', formData);
      if (res.data && res.data.url) {
        document.getElementById('banner-image-url').value = res.data.url;
        const preview = document.getElementById('banner-img-preview');
        preview.src = api.getImageUrl(res.data.url);
        preview.style.display = 'block';
        layout.showToast('Rasm yuklandi');
      }
    } catch (err) {
      layout.showToast(err.message, 'error');
    }
  });

  document.getElementById('banner-video-upload').addEventListener('change', async (e) => {
    const file = e.target.files[0];
    if (!file) return;

    const sizeMb = (file.size / (1024 * 1024)).toFixed(1);
    if (file.size > 20 * 1024 * 1024) {
      layout.showToast(`Video ${sizeMb} MB — 20 MB dan katta. Avval siqib qayta yuklang.`, 'error');
      e.target.value = '';
      return;
    }

    const formData = new FormData();
    formData.append('file', file);

    layout.showToast(`Video yuklanmoqda (${sizeMb} MB)...`);

    try {
      // DIQQAT: video uchun ImageCompressor ISHLATILMAYDI — u faqat
      // <canvas> orqali rasmni siqadi, video formatini tushunmaydi.
      // Video hajmini kamaytirish admin tomonidan yuklashdan oldin
      // qilinishi kerak (forma ichidagi tavsiyalarga qarang).
      const res = await api.post('/upload/video', formData);
      if (res.data && res.data.url) {
        document.getElementById('banner-video-url').value = res.data.url;
        const preview = document.getElementById('banner-video-preview');
        preview.src = api.getImageUrl(res.data.url);
        preview.style.display = 'block';
        layout.showToast('Video yuklandi');
      }
    } catch (err) {
      layout.showToast(err.message, 'error');
      e.target.value = '';
    }
  });
});

/** Rasm / Video rejimlari orasida forma ko'rinishini almashtiradi. */
function setMediaTypeUI(type) {
  const imgBlock = document.getElementById('image-upload-block');
  const videoBlock = document.getElementById('video-upload-block');
  const imgLabel = document.getElementById('type-label-image');
  const videoLabel = document.getElementById('type-label-video');
  const imgUploadLabel = document.getElementById('image-upload-label');

  if (type === 'video') {
    videoBlock.style.display = 'block';
    imgLabel.classList.remove('active');
    videoLabel.classList.add('active');
    // Video rejimida rasm baribir kerak — video yuklanmasa yoki
    // ijro qila olmasa shu rasm ko'rinadi, shuning uchun majburiy
    // deb qoldiramiz, faqat izohini o'zgartiramiz.
    imgUploadLabel.textContent = 'Muqova rasmi (video ishlamasa shu ko\'rinadi)';
  } else {
    imgBlock.style.display = 'block';
    videoBlock.style.display = 'none';
    videoLabel.classList.remove('active');
    imgLabel.classList.add('active');
    imgUploadLabel.textContent = 'Rasm yuklash';
  }
}

function getSelectedMediaType() {
  return document.getElementById('media-type-video').checked ? 'video' : 'image';
}

async function loadBanners() {
  const tbody = document.getElementById('banner-list');
  try {
    const res = await api.get('/banners'); // Get all banners
    allBanners = res.data || [];
    renderBannerTable();
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="7" class="text-center text-danger">${err.message}</td></tr>`;
  }
}

function renderBannerTable() {
  const tbody = document.getElementById('banner-list');
  
  if (allBanners.length === 0) {
    tbody.innerHTML = `<tr><td colspan="7" class="text-center">${i18n.t('noData')}</td></tr>`;
    return;
  }
  
  tbody.innerHTML = allBanners.map(b => {
    const imgUrl = b.imageUrl || b.image_url;
    const imgSrc = imgUrl ? api.getImageUrl(imgUrl) : '';
    const isActive = b.isActive !== undefined ? b.isActive : b.is_active;
    const statusHtml = isActive 
      ? `<span class="badge badge-success">${i18n.t('active')}</span>` 
      : `<span class="badge badge-neutral">${i18n.t('inactive')}</span>`;
      
    const linkUrl = b.linkUrl || b.link_url || '-';
    const orderIndex = b.orderIndex !== undefined ? b.orderIndex : b.order_index;
    const mediaType = b.mediaType || b.media_type || 'image';
    const typeHtml = mediaType === 'video'
      ? `<span class="badge badge-type-video"><span class="material-symbols-rounded" style="font-size:14px; vertical-align:-2px;">movie</span> Video</span>`
      : `<span class="badge badge-neutral"><span class="material-symbols-rounded" style="font-size:14px; vertical-align:-2px;">image</span> Rasm</span>`;
      
    return `
      <tr>
        <td>
          <img src="${imgSrc}" style="width: 100px; height: 50px; border-radius: 4px; object-fit: cover; background: #eee;">
        </td>
        <td>${typeHtml}</td>
        <td>${b.title || '-'}</td>
        <td style="max-width: 200px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;">${linkUrl}</td>
        <td>${orderIndex}</td>
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
  const videoPreview = document.getElementById('banner-video-preview');
  
  form.reset();
  document.getElementById('banner-id').value = '';
  document.getElementById('banner-image-url').value = '';
  document.getElementById('banner-video-url').value = '';
  preview.style.display = 'none';
  videoPreview.style.display = 'none';
  videoPreview.src = '';
  document.getElementById('banner-active').checked = true;
  document.getElementById('banner-order').value = "0";
  document.getElementById('media-type-image').checked = true;
  setMediaTypeUI('image');
  
  if (id) {
    title.textContent = i18n.t('edit') + ': ' + i18n.t('banners');
    const b = allBanners.find(x => x.id === id);
    if (b) {
      document.getElementById('banner-id').value = b.id;
      document.getElementById('banner-title').value = b.title || '';
      document.getElementById('banner-link').value = b.linkUrl || b.link_url || '';
      document.getElementById('banner-order').value = b.orderIndex !== undefined ? b.orderIndex : (b.order_index || 0);
      document.getElementById('banner-active').checked = b.isActive !== undefined ? b.isActive : b.is_active;
      
      const bImgUrl = b.imageUrl || b.image_url;
      if (bImgUrl) {
        document.getElementById('banner-image-url').value = bImgUrl;
        preview.src = api.getImageUrl(bImgUrl);
        preview.style.display = 'block';
      }

      const mediaType = b.mediaType || b.media_type || 'image';
      const bVideoUrl = b.videoUrl || b.video_url;
      if (mediaType === 'video' && bVideoUrl) {
        document.getElementById('media-type-video').checked = true;
        setMediaTypeUI('video');
        document.getElementById('banner-video-url').value = bVideoUrl;
        videoPreview.src = api.getImageUrl(bVideoUrl);
        videoPreview.style.display = 'block';
      }
    }
  } else {
    title.textContent = i18n.t('add') + ': ' + i18n.t('banners');
  }
  
  modal.classList.add('active');
}

function closeModal() {
  document.getElementById('banner-modal').classList.remove('active');
  // Video pleerni to'xtatib qo'yamiz — yopilgandan keyin ham fonda
  // aylanib turmasin.
  const videoPreview = document.getElementById('banner-video-preview');
  videoPreview.pause();
  videoPreview.src = '';
}

async function saveBanner() {
  const id = document.getElementById('banner-id').value;
  const imgUrl = document.getElementById('banner-image-url').value;
  const mediaType = getSelectedMediaType();
  const videoUrl = document.getElementById('banner-video-url').value;
  
  if (!imgUrl) {
    layout.showToast("Rasm kiritilishi shart!", 'error');
    return;
  }

  if (mediaType === 'video' && !videoUrl) {
    layout.showToast("Video tanlangan, lekin hali yuklanmagan!", 'error');
    return;
  }
  
  const payload = {
    title: document.getElementById('banner-title').value || null,
    link_url: document.getElementById('banner-link').value || null,
    linkUrl: document.getElementById('banner-link').value || null,
    image_url: imgUrl,
    imageUrl: imgUrl,
    order_index: parseInt(document.getElementById('banner-order').value) || 0,
    orderIndex: parseInt(document.getElementById('banner-order').value) || 0,
    is_active: document.getElementById('banner-active').checked,
    isActive: document.getElementById('banner-active').checked,
    // media_type/video_url — backend "video" bo'lmasa ham bo'sh qiymatni
    // qabul qiladi, shuning uchun rasm rejimida ham xavfsiz yuboriladi.
    media_type: mediaType,
    mediaType: mediaType,
    video_url: mediaType === 'video' ? videoUrl : null,
    videoUrl: mediaType === 'video' ? videoUrl : null,
  };
  
  const btn = document.getElementById('btn-save-banner');
  btn.disabled = true;
  btn.textContent = i18n.t('loading');
  
  try {
    if (id) {
      await api.put(`/banners/${id}`, payload);
      layout.showToast(i18n.t('success'));
    } else {
      await api.post('/banners', payload);
      layout.showToast(i18n.t('success'));
    }
    closeModal();
    loadBanners();
  } catch (err) {
    layout.showToast(err.message, 'error');
  } finally {
    btn.disabled = false;
    btn.textContent = i18n.t('save');
  }
}

async function deleteBanner(id) {
  if (!confirm(i18n.t('confirmDelete'))) return;
  
  try {
    await api.delete(`/banners/${id}`);
    layout.showToast(i18n.t('success'));
    loadBanners();
  } catch (err) {
    layout.showToast(err.message, 'error');
  }
}
