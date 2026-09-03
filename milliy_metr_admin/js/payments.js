let allPayments = [];

document.addEventListener('DOMContentLoaded', () => {
  auth.requireAuth();
  layout.inject();
  
  loadPayments();
  
  document.getElementById('btn-close-modal').addEventListener('click', closeModal);
  document.getElementById('search-input').addEventListener('input', renderTable);
  document.getElementById('provider-filter').addEventListener('change', renderTable);
  document.getElementById('status-filter').addEventListener('change', renderTable);
});

async function loadPayments() {
  const tbody = document.getElementById('payments-list');
  try {
    const res = await api.get('/payments/admin/list');
    allPayments = res.data || [];
    renderTable();
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="8" class="text-center text-danger">${err.message}</td></tr>`;
  }
}

function renderTable() {
  const tbody = document.getElementById('payments-list');
  const q = document.getElementById('search-input').value.toLowerCase();
  const providerFilter = document.getElementById('provider-filter').value;
  const statusFilter = document.getElementById('status-filter').value;
  
  const filtered = allPayments.filter(p => {
    const matchesSearch = 
      (p.order_number || '').toLowerCase().includes(q) ||
      (p.transaction_id || '').toLowerCase().includes(q) ||
      (p.customer_name || '').toLowerCase().includes(q);
    const matchesProvider = !providerFilter || p.provider === providerFilter;
    const matchesStatus = !statusFilter || p.status === statusFilter;
    return matchesSearch && matchesProvider && matchesStatus;
  });
  
  if (filtered.length === 0) {
    tbody.innerHTML = `<tr><td colspan="8" class="text-center">To'lovlar topilmadi</td></tr>`;
    return;
  }
  
  tbody.innerHTML = filtered.map(p => {
    let statusBadge = 'badge-neutral';
    let statusText = p.status || 'Noma\'lum';
    
    if (statusText === 'performed') statusBadge = 'badge-success';
    else if (statusText === 'created' || statusText === 'pending') statusBadge = 'badge-warning';
    else if (statusText === 'cancelled') statusBadge = 'badge-danger';
    else if (statusText === 'cancelled_after_perform') { statusBadge = 'badge-danger'; statusText = 'refunded'; }
    
    const providerBadge = p.provider === 'payme' ? 'badge-info' : 'badge-neutral';
    const dateStr = p.created_at ? new Date(p.created_at).toLocaleString('ru-RU') : '-';
    const amount = p.amount ? (p.amount / 100).toLocaleString('ru-RU') + ' so\'m' : '-';
    
    return `
      <tr>
        <td data-label="ID">#${(p.id || '').substring(0, 8)}</td>
        <td data-label="Buyurtma">${p.order_number || '-'}</td>
        <td data-label="Mijoz" style="font-weight: 500;">${p.customer_name || '-'}</td>
        <td data-label="Provayder"><span class="badge ${providerBadge}">${(p.provider || '').toUpperCase()}</span></td>
        <td data-label="Summa" style="font-weight: 500;">${amount}</td>
        <td data-label="Holat"><span class="badge ${statusBadge}">${statusText.toUpperCase()}</span></td>
        <td data-label="Sana">${dateStr}</td>
        <td class="text-center">
          <button class="btn btn-sm btn-outline" style="padding: 0 8px;" onclick="openPaymentModal('${p.id}')">
            <span class="material-symbols-rounded" style="font-size: 18px;">visibility</span>
          </button>
        </td>
      </tr>
    `;
  }).join('');
}

function openPaymentModal(id) {
  const modal = document.getElementById('payment-modal');
  const p = allPayments.find(x => x.id === id);
  if (!p) return;
  
  document.getElementById('detail-provider').textContent = (p.provider || '').toUpperCase();
  document.getElementById('detail-status').textContent = (p.status || '').toUpperCase();
  document.getElementById('detail-amount').textContent = p.amount ? (p.amount / 100).toLocaleString('ru-RU') + ' so\'m' : '-';
  document.getElementById('detail-txn').textContent = p.transaction_id || '-';
  document.getElementById('detail-created').textContent = p.created_at ? new Date(p.created_at).toLocaleString('ru-RU') : '-';
  document.getElementById('detail-performed').textContent = p.perform_time ? new Date(p.perform_time).toLocaleString('ru-RU') : '-';
  document.getElementById('detail-cancelled').textContent = p.cancel_time ? new Date(p.cancel_time).toLocaleString('ru-RU') : '-';
  document.getElementById('detail-reason').textContent = p.cancel_reason || '-';
  
  try {
    document.getElementById('detail-raw').textContent = p.raw_payload ? JSON.stringify(p.raw_payload, null, 2) : 'Ma\'lumot yo\'q';
  } catch {
    document.getElementById('detail-raw').textContent = String(p.raw_payload || 'Ma\'lumot yo\'q');
  }
  
  modal.classList.add('active');
}

function closeModal() {
  document.getElementById('payment-modal').classList.remove('active');
}
