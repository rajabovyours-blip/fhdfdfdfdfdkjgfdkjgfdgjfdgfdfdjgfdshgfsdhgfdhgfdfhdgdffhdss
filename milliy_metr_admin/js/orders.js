let allOrders = [];
let currentOrderId = null;

document.addEventListener('DOMContentLoaded', () => {
  auth.requireAuth();
  layout.inject();

  ensureFilterUi();
  loadOrders();

  document.getElementById('btn-close-modal').addEventListener('click', closeModal);
  document.getElementById('btn-save-status').addEventListener('click', updateStatus);
  document.getElementById('btn-cancel-order').addEventListener('click', cancelOrder);

  document.getElementById('search-input').addEventListener('input', debounce(loadOrders, 400));
  document.getElementById('status-filter').addEventListener('change', loadOrders);
});

function debounce(fn, ms) {
  let t;
  return (...args) => { clearTimeout(t); t = setTimeout(() => fn(...args), ms); };
}

/**
 * Sana oraligi va to'lov holati filtrlarini qo'shadi.
 * HTML da bo'lmasa ham ishlashi uchun dinamik yaratiladi.
 */
function ensureFilterUi() {
  const statusFilter = document.getElementById('status-filter');
  if (!statusFilter || document.getElementById('date-from')) return;

  // Muhim: statusFilter.parentElement — bu faqat status select joylashgan
  // tor (200px) quti. Filtrlarni O'SHA quti ichiga emas, balki butun
  // filtr qatoriga (.d-flex.gap-16) qo'shish kerak, aks holda hammasi
  // bir-biriga siqilib, buzilib ko'rinadi.
  const row = statusFilter.closest('.d-flex.gap-16') || statusFilter.parentElement.parentElement;

  const wrap = document.createElement('div');
  wrap.style.cssText = 'display:flex; gap:8px; align-items:center; flex-wrap:wrap;';
  wrap.innerHTML = `
    <select class="form-control" id="payment-filter" style="min-width:150px;">
      <option value="">${i18n.t('paymentMethods')} — ${i18n.t('total')}</option>
      <option value="paid">${i18n.t('ps_paid')}</option>
      <option value="pending">${i18n.t('ps_pending')}</option>
      <option value="cancelled">${i18n.t('ps_cancelled')}</option>
      <option value="refunded">${i18n.t('ps_refunded')}</option>
    </select>
    <input type="date" class="form-control" id="date-from" style="min-width:150px;">
    <input type="date" class="form-control" id="date-to" style="min-width:150px;">
    <button type="button" class="btn btn-sm btn-outline" id="btn-reset-filters">
      <span class="material-symbols-rounded" style="font-size:18px;">restart_alt</span>
    </button>
  `;
  row.appendChild(wrap);

  ['payment-filter', 'date-from', 'date-to'].forEach(id => {
    document.getElementById(id).addEventListener('change', loadOrders);
  });

  document.getElementById('btn-reset-filters').addEventListener('click', () => {
    document.getElementById('search-input').value = '';
    document.getElementById('status-filter').value = '';
    document.getElementById('payment-filter').value = '';
    document.getElementById('date-from').value = '';
    document.getElementById('date-to').value = '';
    loadOrders();
  });
}

/** Filtrlar endi SERVERDA qo'llanadi — katta ro'yxatda ham tez ishlaydi. */
async function loadOrders() {
  const tbody = document.getElementById('orders-list');
  tbody.innerHTML = `<tr><td colspan="8" class="text-center">${i18n.t('loading')}</td></tr>`;

  const params = new URLSearchParams();
  const val = (id) => document.getElementById(id)?.value?.trim() || '';

  if (val('search-input')) params.set('search', val('search-input'));
  if (val('status-filter')) params.set('status', val('status-filter'));
  if (val('payment-filter')) params.set('payment_status', val('payment-filter'));
  if (val('date-from')) params.set('date_from', val('date-from'));
  if (val('date-to')) params.set('date_to', val('date-to'));

  const qs = params.toString();

  try {
    const res = await api.get(`/orders${qs ? '?' + qs : ''}`);
    allOrders = res.data || [];
    renderTable();
  } catch (err) {
    tbody.innerHTML = `<tr><td colspan="8" class="text-center text-danger">${err.message}</td></tr>`;
  }
}

function customerName(o) {
  return o.user?.fullName || o.user?.phone || o.user?.phoneNumber || i18n.t('customer');
}

function customerPhone(o) {
  return o.user?.phone || o.user?.phoneNumber || '—';
}

function renderTable() {
  const tbody = document.getElementById('orders-list');

  if (allOrders.length === 0) {
    tbody.innerHTML = `<tr><td colspan="8" class="text-center">${i18n.t('noData')}</td></tr>`;
    return;
  }

  const locale = i18n.lang === 'ru' ? 'ru-RU' : 'uz-UZ';

  tbody.innerHTML = allOrders.map(o => {
    const dateStr = o.createdAt ? new Date(o.createdAt).toLocaleString(locale) : '—';
    const total = i18n.money(o.total);
    const address = o.deliveryAddress || '—';
    const payment = (o.paymentMethod || '—').toUpperCase();

    return `
      <tr>
        <td data-label="ID">${o.orderNumber || '#' + (o.id || '').substring(0, 8)}</td>
        <td data-label="${i18n.t('customer')}" style="font-weight: 500;">${customerName(o)}</td>
        <td data-label="${i18n.t('date')}">${dateStr}</td>
        <td data-label="${i18n.t('address')}">${address}</td>
        <td data-label="${i18n.t('payments')}">
          ${payment}
          <div><span class="badge ${i18n.statusBadge(o.paymentStatus)}" style="font-size:10px;">${i18n.paymentStatus(o.paymentStatus)}</span></div>
        </td>
        <td data-label="${i18n.t('amount')}" style="font-weight: 500;">${total}</td>
        <td data-label="${i18n.t('status')}"><span class="badge ${i18n.statusBadge(o.status)}">${i18n.status(o.status)}</span></td>
        <td class="text-center">
          <button class="btn btn-sm btn-outline" style="padding: 0 8px;" onclick="openModal('${o.id}')">
            <span class="material-symbols-rounded" style="font-size: 18px;">visibility</span>
          </button>
        </td>
      </tr>
    `;
  }).join('');
}

async function openModal(id) {
  const modal = document.getElementById('order-modal');
  currentOrderId = id;

  const o = allOrders.find(x => x.id === id);
  if (!o) return;

  const locale = i18n.lang === 'ru' ? 'ru-RU' : 'uz-UZ';
  const set = (elId, text) => { const el = document.getElementById(elId); if (el) el.textContent = text; };

  set('order-customer', customerName(o));
  set('order-phone', customerPhone(o));
  set('order-date', o.createdAt ? new Date(o.createdAt).toLocaleString(locale) : '—');
  set('order-address', o.deliveryAddress || '—');
  set('order-payment', (o.paymentMethod || '—').toUpperCase());
  set('order-payment-status', i18n.paymentStatus(o.paymentStatus));
  set('order-total', i18n.money(o.total));

  const statusSelect = document.getElementById('edit-order-status');
  if (statusSelect) statusSelect.value = (o.status || 'pending').toLowerCase();

  // Mahsulotlar
  const itemsList = document.getElementById('order-items');
  if (itemsList) {
    if (o.items && o.items.length > 0) {
      itemsList.innerHTML = o.items.map(item => {
        const product = item.product || {};
        const pName = typeof product.name === 'object'
          ? (product.name[i18n.lang] || product.name.uz || '—')
          : (product.name || '—');
        const imgSrc = (product.images && product.images.length > 0)
          ? api.getImageUrl(product.images[0]) : '';
        const unitPrice = Number(item.price || 0);

        return `
          <div class="order-item">
            ${imgSrc
              ? `<img src="${imgSrc}">`
              : `<div style="width:60px; height:60px; background:#eee; border-radius:8px;"></div>`}
            <div style="flex: 1;">
              <div style="font-weight: 500;">${pName}</div>
              <div style="color: var(--text-medium); font-size: 12px; margin-top: 4px;">
                ${i18n.money(unitPrice)} × ${item.quantity} ${product.unit || ''}
              </div>
            </div>
            <div style="font-weight: 600;">${i18n.money(unitPrice * item.quantity)}</div>
          </div>
        `;
      }).join('');
    } else {
      itemsList.innerHTML = `<div style="padding:16px; text-align:center; color:var(--text-medium);">${i18n.t('noData')}</div>`;
    }
  }

  modal.classList.add('active');
  loadPaymentHistory(id);
}

/** Shu buyurtma bo'yicha to'lov urinishlari tarixi. */
async function loadPaymentHistory(orderId) {
  let host = document.getElementById('order-payments');
  if (!host) {
    const itemsList = document.getElementById('order-items');
    if (!itemsList) return;
    host = document.createElement('div');
    host.id = 'order-payments';
    host.style.marginTop = '16px';
    itemsList.parentElement.appendChild(host);
  }

  host.innerHTML = `<div style="font-size:13px; color:var(--text-medium);">${i18n.t('loading')}</div>`;

  try {
    const res = await api.get('/payments/admin/list?limit=100');
    const rows = (res.data || []).filter(p => String(p.order_id) === String(orderId));

    if (!rows.length) {
      host.innerHTML = `
        <h4 style="font-size:14px; margin:0 0 8px;">${i18n.t('payments')}</h4>
        <div style="font-size:13px; color:var(--text-medium);">${i18n.t('noData')}</div>`;
      return;
    }

    const locale = i18n.lang === 'ru' ? 'ru-RU' : 'uz-UZ';
    host.innerHTML = `
      <h4 style="font-size:14px; margin:0 0 8px;">${i18n.t('payments')}</h4>
      <div class="table-responsive">
        <table class="table" style="font-size:12px;">
          <thead><tr>
            <th>${i18n.t('paymentMethods')}</th>
            <th>ID</th>
            <th>${i18n.t('amount')}</th>
            <th>${i18n.t('status')}</th>
            <th>${i18n.t('date')}</th>
          </tr></thead>
          <tbody>
            ${rows.map(p => `
              <tr>
                <td>${(p.provider || '—').toUpperCase()}</td>
                <td style="font-family:monospace; font-size:11px;">${p.transaction_id || '—'}</td>
                <td>${i18n.money(Number(p.amount || 0) / 100)}</td>
                <td><span class="badge ${i18n.statusBadge(p.status)}">${p.status === 'cancelled_after_perform' ? i18n.t('ps_refunded') : i18n.paymentStatus(p.status)}</span></td>
                <td>${p.created_at ? new Date(p.created_at).toLocaleString(locale) : '—'}</td>
              </tr>`).join('')}
          </tbody>
        </table>
      </div>`;
  } catch (err) {
    host.innerHTML = `<div style="font-size:13px; color:var(--color-danger);">${err.message}</div>`;
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
    await api.patch(`/orders/${currentOrderId}/status`, { status: status });
    layout.showToast(i18n.t('success'));

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
  if (!confirm(i18n.t('confirmDelete'))) return;

  const btn = document.getElementById('btn-cancel-order');
  btn.disabled = true;

  try {
    await api.patch(`/orders/${currentOrderId}/status`, { status: 'cancelled' });
    layout.showToast(i18n.t('success'));

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
