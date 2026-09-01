let allCategories = [];

document.addEventListener('DOMContentLoaded', () => {
  auth.requireAuth();
  layout.inject();
  
  loadCategories();
  
  // Event Listeners
  document.getElementById('btn-add-category').addEventListener('click', () => openModal());
  document.getElementById('btn-close-modal').addEventListener('click', closeModal);
  document.getElementById('btn-cancel-modal').addEventListener('click', closeModal);
  document.getElementById('btn-save-category').addEventListener('click', saveCategory);
  
  // Image Upload handler
  document.getElementById('cat-img-upload').addEventListener('change', async (e) => {
    const file = e.target.files[0];
    if (!file) return;
    
    const formData = new FormData();
    formData.append('file', file);
    
    try {
      const res = await api.post('/upload/image', formData);
      if (res.data && res.data.url) {
        document.getElementById('cat-image-url').value = res.data.url;
        const preview = document.getElementById('cat-img-preview');
        preview.src = CONFIG.API_BASE_URL.replace('/api/v1', '') + res.data.url;
        preview.style.display = 'block';
        layout.showToast('Rasm yuklandi');
      }
    } catch (err) {
      layout.showToast(err.message, 'error');
    }
  });
});

async function loadCategories() {
  const tbody = document.getElementById('category-list');
  try {
    const res = await api.get('/categories');
    allCategories = res.data || [];
    renderCategoryTable();
    updateParentDropdown();
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="4" class="text-center text-danger">${err.message}</td></tr>`;
  }
}

function renderCategoryTable() {
  const tbody = document.getElementById('category-list');
  
  if (allCategories.length === 0) {
    tbody.innerHTML = `<tr><td colspan="4" class="text-center">Kategoriyalar mavjud emas</td></tr>`;
    return;
  }
  
  // Build hierarchy (simple approach: sort by parent_id to show children under parents if possible, or build tree)
  const topLevel = allCategories.filter(c => !c.parent_id);
  const childrenMap = {};
  allCategories.forEach(c => {
    if (c.parent_id) {
      if (!childrenMap[c.parent_id]) childrenMap[c.parent_id] = [];
      childrenMap[c.parent_id].push(c);
    }
  });
  
  let html = '';
  
  function renderNode(cat, depth = 0) {
    let nameUz = cat.name;
    if (typeof cat.name === 'object' && cat.name.uz) nameUz = cat.name.uz;
    
    let parentName = '-';
    if (cat.parent_id) {
        const parent = allCategories.find(p => p.id === cat.parent_id);
        if (parent) {
            parentName = typeof parent.name === 'object' ? parent.name.uz : parent.name;
        }
    }
    
    const imgSrc = cat.image_url ? (CONFIG.API_BASE_URL.replace('/api/v1', '') + cat.image_url) : '';
    const imgHtml = imgSrc 
      ? `<img src="${imgSrc}" style="width: 40px; height: 40px; border-radius: 4px; object-fit: cover;">` 
      : `<div style="width: 40px; height: 40px; background: #eee; border-radius: 4px; display: flex; align-items:center; justify-content:center;"><span class="material-symbols-rounded" style="color:#aaa;">category</span></div>`;
      
    const indent = depth > 0 ? `<span style="display:inline-block; width:${depth * 24}px"></span><span class="material-symbols-rounded" style="font-size: 16px; color: #999; vertical-align: middle;">subdirectory_arrow_right</span> ` : '';

    html += `
      <tr>
        <td>${imgHtml}</td>
        <td style="${depth === 0 ? 'font-weight: 600;' : ''}">${indent}${nameUz}</td>
        <td>${parentName}</td>
        <td class="text-center">
          <button class="btn btn-sm btn-outline" style="padding: 0 8px;" onclick="openModal('${cat.id}')"><span class="material-symbols-rounded" style="font-size: 18px;">edit</span></button>
          <button class="btn btn-sm btn-danger" style="padding: 0 8px;" onclick="deleteCategory('${cat.id}')"><span class="material-symbols-rounded" style="font-size: 18px;">delete</span></button>
        </td>
      </tr>
    `;
    
    if (childrenMap[cat.id]) {
      childrenMap[cat.id].forEach(child => renderNode(child, depth + 1));
    }
  }
  
  topLevel.forEach(node => renderNode(node, 0));
  tbody.innerHTML = html;
}

function updateParentDropdown(excludeId = null) {
  const select = document.getElementById('cat-parent');
  let html = '<option value="">(Yo\'q - Asosiy Kategoriya)</option>';
  
  // Only top level categories can be parents typically, but let's just show all except the current one
  allCategories.forEach(cat => {
    if (cat.id !== excludeId) {
      let nameUz = typeof cat.name === 'object' ? cat.name.uz : cat.name;
      html += `<option value="${cat.id}">${nameUz}</option>`;
    }
  });
  
  select.innerHTML = html;
}

function openModal(id = null) {
  const modal = document.getElementById('category-modal');
  const title = document.getElementById('modal-title');
  const form = document.getElementById('category-form');
  const preview = document.getElementById('cat-img-preview');
  
  form.reset();
  document.getElementById('cat-id').value = '';
  document.getElementById('cat-image-url').value = '';
  preview.style.display = 'none';
  
  if (id) {
    title.textContent = 'Kategoriyani Tahrirlash';
    const cat = allCategories.find(c => c.id === id);
    if (cat) {
      document.getElementById('cat-id').value = cat.id;
      
      if (typeof cat.name === 'object') {
        document.getElementById('cat-name-uz').value = cat.name.uz || '';
        document.getElementById('cat-name-ru').value = cat.name.ru || '';
        document.getElementById('cat-name-en').value = cat.name.en || '';
      } else {
        document.getElementById('cat-name-uz').value = cat.name || '';
      }
      
      updateParentDropdown(cat.id);
      document.getElementById('cat-parent').value = cat.parent_id || '';
      
      if (cat.image_url) {
        document.getElementById('cat-image-url').value = cat.image_url;
        preview.src = CONFIG.API_BASE_URL.replace('/api/v1', '') + cat.image_url;
        preview.style.display = 'block';
      }
    }
  } else {
    title.textContent = "Kategoriya Qo'shish";
    updateParentDropdown();
  }
  
  modal.classList.add('active');
}

function closeModal() {
  document.getElementById('category-modal').classList.remove('active');
}

async function saveCategory() {
  const id = document.getElementById('cat-id').value;
  const nameUz = document.getElementById('cat-name-uz').value;
  if (!nameUz) {
    layout.showToast("Nomi kiritilishi shart!", 'error');
    return;
  }
  
  const payload = {
    name: {
      uz: nameUz,
      ru: document.getElementById('cat-name-ru').value || nameUz,
      en: document.getElementById('cat-name-en').value || nameUz
    },
    parent_id: document.getElementById('cat-parent').value || null,
    image_url: document.getElementById('cat-image-url').value || null,
    is_featured: false
  };
  
  const btn = document.getElementById('btn-save-category');
  btn.disabled = true;
  btn.textContent = 'Saqlanmoqda...';
  
  try {
    if (id) {
      await api.put(`/categories/${id}`, payload);
      layout.showToast('Kategoriya yangilandi');
    } else {
      await api.post('/categories', payload);
      layout.showToast('Kategoriya qo\'shildi');
    }
    closeModal();
    loadCategories();
  } catch (err) {
    layout.showToast(err.message, 'error');
  } finally {
    btn.disabled = false;
    btn.textContent = 'Saqlash';
  }
}

async function deleteCategory(id) {
  if (!confirm('Rostdan ham ushbu kategoriyani o\'chirmoqchimisiz?')) return;
  
  try {
    await api.delete(`/categories/${id}`);
    layout.showToast('Kategoriya o\'chirildi');
    loadCategories();
  } catch (err) {
    layout.showToast(err.message, 'error');
  }
}
