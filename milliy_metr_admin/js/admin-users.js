let allAdmins = [];

document.addEventListener('DOMContentLoaded', () => {
  auth.requireAuth();
  layout.inject();
  
  loadAdmins();
  
  document.getElementById('btn-add-admin').addEventListener('click', () => openModal());
  document.getElementById('btn-close-modal').addEventListener('click', closeModal);
  document.getElementById('btn-cancel-modal').addEventListener('click', closeModal);
  document.getElementById('btn-save-admin').addEventListener('click', saveAdmin);
});

async function loadAdmins() {
  const tbody = document.getElementById('admin-list');
  try {
    const res = await api.get('/admin/users/');
    allAdmins = res.data || [];
    renderTable();
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="5" class="text-center text-danger">${err.message}</td></tr>`;
  }
}

function renderTable() {
  const tbody = document.getElementById('admin-list');
  
  if (allAdmins.length === 0) {
    tbody.innerHTML = `<tr><td colspan="5" class="text-center">Adminlar mavjud emas</td></tr>`;
    return;
  }
  
  tbody.innerHTML = allAdmins.map(u => {
    const statusHtml = u.is_active 
      ? '<span class="badge badge-success">Faol</span>' 
      : '<span class="badge badge-danger">Bloklangan</span>';
      
    const roleHtml = u.role === 'OWNER' 
      ? '<span class="badge badge-warning">OWNER</span>'
      : '<span class="badge badge-info">ADMIN</span>';
      
    return `
      <tr>
        <td style="font-weight: 500;">${u.full_name || '-'}</td>
        <td>@${u.username || '-'}</td>
        <td>${roleHtml}</td>
        <td>${statusHtml}</td>
        <td class="text-center">
          <button class="btn btn-sm btn-outline" style="padding: 0 8px;" onclick="openModal('${u.id}')" title="Tahrirlash"><span class="material-symbols-rounded" style="font-size: 18px;">edit</span></button>
          <button class="btn btn-sm btn-outline" style="padding: 0 8px; color: var(--danger-color); border-color: var(--danger-color); margin-left: 4px;" onclick="deleteAdmin('${u.id}')" title="O'chirish"><span class="material-symbols-rounded" style="font-size: 18px;">delete</span></button>
        </td>
      </tr>
    `;
  }).join('');
}

function openModal(id = null) {
  const modal = document.getElementById('admin-modal');
  const title = document.getElementById('modal-title');
  const form = document.getElementById('admin-form');
  
  form.reset();
  document.getElementById('admin-id').value = '';
  document.getElementById('group-username').style.display = id ? 'none' : 'block';
  document.getElementById('group-active').style.display = id ? 'flex' : 'none';
  
  if (id) {
    title.textContent = 'Adminni Tahrirlash';
    document.getElementById('pwd-hint').textContent = '(O\'zgartirish uchun kiriting, yo\'qsa bo\'sh qoldiring)';
    document.getElementById('admin-password').required = false;
    
    const u = allAdmins.find(x => x.id === id);
    if (u) {
      document.getElementById('admin-id').value = u.id;
      document.getElementById('admin-fullname').value = u.full_name || '';
      document.getElementById('admin-role').value = u.role;
      document.getElementById('admin-active').checked = u.is_active;
    }
  } else {
    title.textContent = "Admin Qo'shish";
    document.getElementById('pwd-hint').textContent = '(Kamida 6 belgi)';
    document.getElementById('admin-password').required = true;
    document.getElementById('admin-role').value = 'ADMIN';
  }
  
  modal.classList.add('active');
}

function closeModal() {
  document.getElementById('admin-modal').classList.remove('active');
}

async function saveAdmin() {
  const id = document.getElementById('admin-id').value;
  const fullname = document.getElementById('admin-fullname').value;
  const username = document.getElementById('admin-username').value;
  const password = document.getElementById('admin-password').value;
  const role = document.getElementById('admin-role').value;
  const isActive = document.getElementById('admin-active').checked;
  
  if (!fullname) {
    layout.showToast("Ismni kiriting", 'error');
    return;
  }
  
  const btn = document.getElementById('btn-save-admin');
  btn.disabled = true;
  btn.textContent = 'Saqlanmoqda...';
  
  try {
    if (id) {
      // Update details
      const updatePayload = { full_name: fullname, role: role };
      if (password) updatePayload.password = password;
      
      await api.put(`/admin/users/${id}`, updatePayload);
      
      // Update status if needed (we fetch current user first to see if changed, or just patch it)
      const u = allAdmins.find(x => x.id === id);
      if (u && u.is_active !== isActive) {
        await api.patch(`/admin/users/${id}/status`, { is_active: isActive });
      }
      
      layout.showToast('Administrator yangilandi');
    } else {
      // Create
      if (!username || password.length < 6) {
        throw new Error('Username va kamida 6 belgili parol kiritilishi shart');
      }
      const payload = {
        username: username,
        full_name: fullname,
        password: password,
        role: role
      };
      await api.post('/admin/users/', payload);
      
      layout.showToast("Admin muvaffaqiyatli saqlandi!", 'success');
      closeModal();
      loadAdmins();
    }
  } catch (err) {
    // Improved error reporting for Add Admin failure
    let errorMsg = err.message || "Xatolik yuz berdi";
    if (err.response && err.response.data && err.response.data.detail) {
      errorMsg = typeof err.response.data.detail === 'string' 
        ? err.response.data.detail 
        : JSON.stringify(err.response.data.detail);
    }
    layout.showToast("Xatolik: " + errorMsg, 'error');
    console.error("Admin save error:", err);
  } finally {
    btn.disabled = false;
    btn.textContent = 'Saqlash';
  }
}

async function deleteAdmin(id) {
  if (!confirm("Haqiqatan ham bu adminni o'chirmoqchimisiz?")) {
    return;
  }
  
  try {
    await api.delete(`/admin/users/${id}`);
    layout.showToast("Admin muvaffaqiyatli o'chirildi", 'success');
    loadAdmins();
  } catch (err) {
    let errorMsg = err.message || "Xatolik yuz berdi";
    if (err.response && err.response.data && err.response.data.detail) {
      errorMsg = typeof err.response.data.detail === 'string' 
        ? err.response.data.detail 
        : JSON.stringify(err.response.data.detail);
    }
    layout.showToast("Xatolik: " + errorMsg, 'error');
  }
}
