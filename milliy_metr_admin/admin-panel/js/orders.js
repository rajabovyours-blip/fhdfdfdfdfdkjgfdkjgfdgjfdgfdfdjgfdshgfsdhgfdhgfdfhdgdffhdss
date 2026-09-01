let allOrders = [];
let currentOrderId = null;

document.addEventListener('DOMContentLoaded', () => {
  auth.requireAuth();
  layout.inject();
  
  loadOrders();
  
  document.getElementById('btn-close-modal').addEventListener('click', closeModal);
  document.getElementById('btn-save-status').addEventListener('click', updateStatus);
  document.getElementById('btn-cancel-order').addEventListener('click', cancelOrder);
  
  document.getElementById('search-input').addEventListener('input', renderTable);
  document.getElementById('status-filter').addEventListener('change', renderTable);
});

async function loadOrders() {
  const tbody = document.getElementById('orders-list');
  try {
    const res = await api.get('/orders');
    allOrders = res.data || [];
    renderTable();
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="8" class="text-center text-danger">${err.message}</td></tr>`;
  }
}

function renderTable() {
  const tbody = document.getElementById('orders-list');
  const q = document.getElementById('search-input').value.toLowerCase();
  const statusFilter = document.getElementById('status-filter').value;
  
  const filtered = allOrders.filter(o => {
    const id = (o.id || '').toLowerCase();
    const matchesSearch = id.includes(q);
    const matchesStatus = statusFilter === '' || (o.status && o.status.toLowerCase() === statusFilter);
    return matchesSearch && matchesStatus;
  });
  
  if (filtered.length === 0) {
    tbody.innerHTML = `<tr><td colspan="8" class="text-center">Buyurtmalar topilmadi</td></tr>`;
    return;
  }
  
  tbody.innerHTML = filtered.map(o => {
    let statusBadge = 'badge-neutral';
    let statusText = o.status || 'Noma\'lum';
    
    if (['completed', 'delivered'].includes(statusText.toLowerCase())) statusBadge = 'badge-success';
    else if (['pending', 'processing'].includes(statusText.toLowerCase())) statusBadge = 'badge-warning';
    else if (['cancelled', 'rejected'].includes(statusText.toLowerCase())) statusBadge = 'badge-danger';
    else if (['confirmed'].includes(statusText.toLowerCase())) statusBadge = 'badge-info';
    
    const dateStr = o.created_at ? new Date(o.created_at).toLocaleString('ru-RU') : '-';
    const total = o.total_amount ? parseInt(o.total_amount).toLocaleString('ru-RU') + ' so\'m' : '-';
    const customer = o.user?.full_name || o.user?.phone || 'Mijoz';
    const address = o.address?.full_address || '-';
    const payment = o.payment_method || '-';
      
    return `
      <tr>
        <td data-label="ID">#${(o.id || '').substring(0, 8)}</td>
        <td data-label="Mijoz" style="font-weight: 500;">${customer}</td>
        <td data-label="Sana">${dateStr}</td>
        <td data-label="Manzil">${address}</td>
        <td data-label="To'lov">${payment}</td>
        <td data-label="Summa" style="font-weight: 500;">${total}</td>
        <td data-label="Holat"><span class="badge ${statusBadge}">${statusText.toUpperCase()}</span></td>
        <td class="text-center">
          <button class="btn btn-sm btn-outline" style="padding: 0 8px;" onclick="openModal('${o.id}')"><span class="material-symbols-rounded" style="font-size: 18px;">visibility</span></button>
        </td>
      </tr>
    `;
  }).join('');
}

function openModal(id) {
  const modal = document.getElementById('order-modal');
  currentOrderId = id;
  
  const o = allOrders.find(x => x.id === id);
  if (o) {
    document.getElementById('order-customer').textContent = o.user?.full_name || 'Noma\'lum';
    document.getElementById('order-phone').textContent = o.user?.phone || 'Noma\'lum';
    document.getElementById('order-date').textContent = o.created_at ? new Date(o.created_at).toLocaleString('ru-RU') : '-';
    document.getElementById('order-address').textContent = o.address?.full_address || '-';
    document.getElementById('order-payment').textContent = o.payment_method || '-';
    document.getElementById('order-payment-status').textContent = o.payment_status || '-';
    document.getElementById('order-total').textContent = o.total_amount ? parseInt(o.total_amount).toLocaleString('ru-RU') + ' so\'m' : '-';
    
    // Set current status in dropdown
    const statusSelect = document.getElementById('edit-order-status');
    statusSelect.value = o.status || 'pending';
    
    // Render items
    const itemsList = document.getElementById('order-items');
    if (o.items && o.items.length > 0) {
      itemsList.innerHTML = o.items.map(item => {
        const product = item.product || {};
        const pName = typeof product.name === 'object' ? product.name.uz : (product.name || 'Mahsulot');
        const imgSrc = (product.images && product.images.length > 0) 
            ? (CONFIG.API_BASE_URL.replace('/api/v1', '') + product.images[0]) 
            : '';
        const price = item.price ? parseInt(item.price).toLocaleString('ru-RU') + ' so\'m' : '-';
        
        return `
          <div class="order-item">
            ${imgSrc ? `<img src="${imgSrc}">` : `<div style="width:60px; height:60px; background:#eee; border-radius:8px;"></div>`}
            <div style="flex: 1;">
              <div style="font-weight: 500;">${pName}</div>
              <div style="color: var(--text-medium); font-size: 12px; margin-top: 4px;">
                ${price} x ${item.quantity} ${product.unit || 'dona'}
              </div>
            </div>
            <div style="font-weight: 600;">
              ${(item.price * item.quantity).toLocaleString('ru-RU')} so'm
            </div>
          </div>
        `;
      }).join('');
    } else {
      itemsList.innerHTML = '<div style="padding: 16px; text-align: center; color: var(--text-medium);">Mahsulotlar topilmadi</div>';
    }
    
    modal.classList.add('active');
  }
}

function closeModal() {
  document.getElementById('order-modal').classList.remove('active');
  currentOrderId = null;
}

async function updateStatus() {
  if (!currentOrderId) return;
  
  const status = document.getElementById('edit-order-status').value;
  const btn = document.getElementById('btn-save-status');
  btn.disabled = true;
  
  try {
    // Expected to be PATCH /orders/{id}/status?status=... or body {status: ...}
    // According to backend, PATCH /orders/{id}/status with query param `status` is typical, 
    // but we can send as body. Let's try query param since it's common.
    await api.patch(`/orders/${currentOrderId}/status?status=${status}`);
    layout.showToast('Buyurtma holati yangilandi');
    
    // Update local data
    const idx = allOrders.findIndex(x => x.id === currentOrderId);
    if (idx !== -1) allOrders[idx].status = status;
    renderTable();
  } catch (err) {
    layout.showToast(err.message, 'error');
  } finally {
    btn.disabled = false;
  }
}

async function cancelOrder() {
  if (!currentOrderId) return;
  if (!confirm('Rostdan ham ushbu buyurtmani bekor qilmoqchimisiz?')) return;
  
  const btn = document.getElementById('btn-cancel-order');
  btn.disabled = true;
  
  try {
    await api.put(`/orders/${currentOrderId}/cancel`);
    layout.showToast('Buyurtma bekor qilindi');
    
    // Update local data
    const idx = allOrders.findIndex(x => x.id === currentOrderId);
    if (idx !== -1) allOrders[idx].status = 'cancelled';
    document.getElementById('edit-order-status').value = 'cancelled';
    renderTable();
  } catch (err) {
    layout.showToast(err.message, 'error');
  } finally {
    btn.disabled = false;
  }
}
