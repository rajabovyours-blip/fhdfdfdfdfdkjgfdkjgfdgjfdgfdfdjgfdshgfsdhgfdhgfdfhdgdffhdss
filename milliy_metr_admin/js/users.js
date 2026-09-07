let allUsers = [];

document.addEventListener('DOMContentLoaded', () => {
  auth.requireAuth();
  layout.inject();
  
  loadUsers();
  
  document.getElementById('btn-close-modal').addEventListener('click', closeModal);
  document.getElementById('btn-cancel-modal').addEventListener('click', closeModal);
  document.getElementById('btn-save-user').addEventListener('click', saveUser);
  
  document.getElementById('search-input').addEventListener('input', (e) => {
    renderTable(e.target.value);
  });
});

async function loadUsers() {
  const tbody = document.getElementById('users-list');
  try {
    const res = await api.get('/users?role=customer');
    allUsers = res.data || [];
    renderTable();
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="7" class="text-center text-danger">${err.message}</td></tr>`;
  }
}

function renderTable(searchQuery = '') {
  const tbody = document.getElementById('users-list');
  const q = searchQuery.toLowerCase();
  
  const filtered = allUsers.filter(u => {
    const name = (u.fullName || u.full_name || '').toLowerCase();
    const phone = (u.phone || '').toLowerCase();
    return name.includes(q) || phone.includes(q);
  });
  
  if (filtered.length === 0) {
    tbody.innerHTML = `<tr><td colspan="7" class="text-center">Mijozlar topilmadi</td></tr>`;
    return;
  }
  
  tbody.innerHTML = filtered.map(u => {
    const isActive = u.isActive !== undefined ? u.isActive : u.is_active;
    const statusHtml = isActive !== false 
      ? '<span class="badge badge-success">Faol</span>' 
      : '<span class="badge badge-danger">Bloklangan</span>';
      
    const createdAt = u.createdAt || u.created_at;
    const dateStr = createdAt ? new Date(createdAt).toLocaleDateString('ru-RU') : 'Yaqinda';
    const provider = u.provider ? (u.provider.toLowerCase() === 'google' ? 'Google orqali' : u.provider) : 'SMS orqali';
    const count = u.ordersCount || u.orders_count || 0;
      
    return `
      <tr>
        <td style="font-weight: 500;">${u.fullName || u.full_name || 'Ism kiritilmagan'}</td>
        <td>${u.phone || '-'}</td>
        <td>${dateStr}</td>
        <td><span class="badge badge-neutral">${count} ta</span></td>
        <td>${provider}</td>
        <td>${statusHtml}</td>
        <td class="text-center">
          <button class="btn btn-sm btn-outline" style="padding: 0 8px;" onclick="openModal('${u.id}')"><span class="material-symbols-rounded" style="font-size: 18px;">edit</span></button>
        </td>
      </tr>
    `;
  }).join('');
}

function openModal(id) {
  const modal = document.getElementById('user-modal');
  const form = document.getElementById('user-form');
  
  form.reset();
  
  const u = allUsers.find(x => x.id === id);
  if (u) {
    document.getElementById('user-id').value = u.id;
    document.getElementById('user-fullname').value = u.fullName || u.full_name || '';
    document.getElementById('user-phone').value = u.phone || '';
    const isActive = u.isActive !== undefined ? u.isActive : u.is_active;
    document.getElementById('user-active').checked = isActive !== false; // defaults to true
    
    const createdAt = u.createdAt || u.created_at;
    document.getElementById('user-date').textContent = createdAt ? new Date(createdAt).toLocaleDateString('ru-RU') : 'Yaqinda';
    document.getElementById('user-orders-count').textContent = u.ordersCount || u.orders_count || 0;
    document.getElementById('user-auth-method').textContent = u.authProvider || u.auth_provider || 'SMS orqali';
    
    modal.classList.add('active');
  }
}

function closeModal() {
  document.getElementById('user-modal').classList.remove('active');
}

async function saveUser() {
  const id = document.getElementById('user-id').value;
  const payload = {
    full_name: document.getElementById('user-fullname').value,
    phone_number: document.getElementById('user-phone').value,
    is_active: document.getElementById('user-active').checked
  };
  
  const btn = document.getElementById('btn-save-user');
  btn.disabled = true;
  btn.textContent = 'Saqlanmoqda...';
  
  try {
    await api.put(`/users/${id}`, payload);
    layout.showToast('Mijoz ma\'lumotlari yangilandi');
    closeModal();
    loadUsers();
  } catch (err) {
    layout.showToast(err.message, 'error');
  } finally {
    btn.disabled = false;
    btn.textContent = 'Saqlash';
  }
}
