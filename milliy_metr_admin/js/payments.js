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

/** Payment.status qiymatlarini (created/performed/cancelled/cancelled_after_perform)
 * tarjima kalitiga moslaydi. i18n.js dagi "ps_" prefiksidan foydalanadi. */
function paymentTxStatusLabel(raw) {
  const s = String(raw || '').toLowerCase().trim();
  if (s === 'cancelled_after_perform') return i18n.t('ps_refunded');
  return i18n.paymentStatus(s);
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
    tbody.innerHTML = `<tr><td colspan="8" class="text-center">${i18n.t('noResults')}</td></tr>`;
    return;
  }

  const locale = i18n.lang === 'ru' ? 'ru-RU' : 'uz-UZ';

  tbody.innerHTML = filtered.map(p => {
    const statusLabel = paymentTxStatusLabel(p.status);
    const badgeClass = i18n.statusBadge(p.status === 'cancelled_after_perform' ? 'refunded' : p.status);

    const providerBadge = 'badge-neutral';
    const dateStr = p.created_at ? new Date(p.created_at).toLocaleString(locale) : '-';
    const amount = p.amount ? i18n.money(p.amount / 100) : '-';

    return `
      <tr>
        <td data-label="ID">#${(p.id || '').substring(0, 8)}</td>
        <td data-label="${i18n.t('orderNumber')}">${p.order_number || '-'}</td>
        <td data-label="${i18n.t('customer')}" style="font-weight: 500;">${p.customer_name || '-'}</td>
        <td data-label="${i18n.t('paymentMethods')}"><span class="badge ${providerBadge}">${(p.provider || '').toUpperCase()}</span></td>
        <td data-label="${i18n.t('amount')}" style="font-weight: 500;">${amount}</td>
        <td data-label="${i18n.t('status')}"><span class="badge ${badgeClass}">${statusLabel}</span></td>
        <td data-label="${i18n.t('date')}">${dateStr}</td>
        <td class="text-center">
          <button class="btn btn-sm btn-outline" style="padding: 0 8px;" onclick="openPaymentModal('${p.id}')" title="${i18n.t('view')}">
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

  const locale = i18n.lang === 'ru' ? 'ru-RU' : 'uz-UZ';
  const set = (elId, text) => { const el = document.getElementById(elId); if (el) el.textContent = text; };

  set('detail-provider', (p.provider || '').toUpperCase());
  set('detail-status', paymentTxStatusLabel(p.status));
  set('detail-amount', p.amount ? i18n.money(p.amount / 100) : '-');
  set('detail-txn', p.transaction_id || '-');
  set('detail-created', p.created_at ? new Date(p.created_at).toLocaleString(locale) : '-');
  set('detail-performed', p.perform_time ? new Date(p.perform_time).toLocaleString(locale) : '-');
  set('detail-cancelled', p.cancel_time ? new Date(p.cancel_time).toLocaleString(locale) : '-');
  set('detail-reason', p.cancel_reason ?? '-');

  const rawEl = document.getElementById('detail-raw');
  try {
    rawEl.textContent = p.raw_payload ? JSON.stringify(p.raw_payload, null, 2) : i18n.t('noData');
  } catch {
    rawEl.textContent = String(p.raw_payload || i18n.t('noData'));
  }

  modal.classList.add('active');
}

function closeModal() {
  document.getElementById('payment-modal').classList.remove('active');
}
