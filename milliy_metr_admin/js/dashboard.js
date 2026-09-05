document.addEventListener('DOMContentLoaded', () => {
  auth.requireAuth();
  layout.inject();
  loadDashboardData();
});

const CHART_COLORS = ['#0F3A59', '#FF6B00', '#008A27', '#FFB800', '#DE3730', '#82BDEB', '#8B949E', '#2E7D32', '#6B4EFF', '#00A3A3'];

function formatNum(num) {
  if (!num) return '0';
  return Math.round(num).toLocaleString('ru-RU');
}

function formatMoney(num) {
  return formatNum(num) + " so'm";
}

async function loadDashboardData() {
  const overlay = document.getElementById('loading-overlay');
  try {
    const [dashboardRes, ordersRes] = await Promise.all([
      api.get('/admin/dashboard'),
      api.get('/orders').catch(() => ({ data: [] })),
    ]);

    const kpi = dashboardRes.data || {};
    const orders = ordersRes.data || [];

    document.getElementById('kpi-users').textContent = formatNum(kpi.total_users);
    document.getElementById('kpi-products').textContent = formatNum(kpi.total_products);
    document.getElementById('kpi-orders').textContent = formatNum(kpi.total_orders);
    document.getElementById('kpi-revenue').textContent = formatMoney(kpi.total_revenue);
    document.getElementById('kpi-aov').textContent = formatMoney(kpi.average_order_value);

    renderRevenueChart(kpi.monthly_sales || []);
    renderStatusChart(kpi.order_status_distribution || []);
    renderCustomersChart(kpi.new_customers_trend || []);
    renderPaymentChart(kpi.payment_method_breakdown || []);
    renderTopProductsChart(kpi.top_products || []);
    renderCategoriesChart(kpi.sales_by_category || []);
    renderLowStockTable(kpi.low_stock_products || []);
    renderRecentOrders(orders.slice(0, 5));

  } catch (err) {
    layout.showToast(err.message, 'error');
  } finally {
    if (overlay) overlay.style.display = 'none';
  }
}

function renderRevenueChart(data) {
  new Chart(document.getElementById('chart-revenue'), {
    type: 'line',
    data: {
      labels: data.map(d => d.month),
      datasets: [{
        label: 'Daromad (so\'m)',
        data: data.map(d => d.revenue),
        borderColor: CHART_COLORS[0],
        backgroundColor: CHART_COLORS[0] + '22',
        tension: 0.3,
        fill: true,
      }],
    },
    options: { responsive: true, plugins: { legend: { display: false } } },
  });
}

function renderStatusChart(data) {
  new Chart(document.getElementById('chart-status'), {
    type: 'doughnut',
    data: {
      labels: data.map(d => d.status),
      datasets: [{ data: data.map(d => d.count), backgroundColor: CHART_COLORS }],
    },
    options: { responsive: true },
  });
}

function renderCustomersChart(data) {
  new Chart(document.getElementById('chart-customers'), {
    type: 'line',
    data: {
      labels: data.map(d => d.month),
      datasets: [{
        label: 'Yangi mijozlar',
        data: data.map(d => d.count),
        borderColor: CHART_COLORS[1],
        backgroundColor: CHART_COLORS[1] + '22',
        tension: 0.3,
        fill: true,
      }],
    },
    options: { responsive: true, plugins: { legend: { display: false } } },
  });
}

function renderPaymentChart(data) {
  new Chart(document.getElementById('chart-payment'), {
    type: 'doughnut',
    data: {
      labels: data.map(d => d.method),
      datasets: [{ data: data.map(d => d.revenue), backgroundColor: CHART_COLORS }],
    },
    options: { responsive: true },
  });
}

function renderTopProductsChart(data) {
  new Chart(document.getElementById('chart-top-products'), {
    type: 'bar',
    data: {
      labels: data.map(d => d.name),
      datasets: [{ label: 'Sotilgan miqdor', data: data.map(d => d.quantity_sold), backgroundColor: CHART_COLORS[0] }],
    },
    options: { responsive: true, indexAxis: 'y', plugins: { legend: { display: false } } },
  });
}

function renderCategoriesChart(data) {
  new Chart(document.getElementById('chart-categories'), {
    type: 'bar',
    data: {
      labels: data.map(d => d.name),
      datasets: [{ label: 'Daromad', data: data.map(d => d.revenue), backgroundColor: CHART_COLORS[1] }],
    },
    options: { responsive: true, plugins: { legend: { display: false } } },
  });
}

function renderLowStockTable(data) {
  const el = document.getElementById('low-stock-list');
  if (!data.length) {
    el.innerHTML = `<tr><td colspan="2" class="text-center" style="color: var(--text-medium); padding: var(--space-24);">Kam qolgan mahsulot yo'q</td></tr>`;
    return;
  }
  el.innerHTML = data.map(p => `
    <tr>
      <td>${p.name}</td>
      <td><span class="badge badge-danger">${p.stock} dona qoldi</span></td>
    </tr>
  `).join('');
}

function renderRecentOrders(recentOrders) {
  const listEl = document.getElementById('recent-orders-list');
  if (recentOrders.length === 0) {
    listEl.innerHTML = `<tr><td colspan="5" class="text-center" style="color: var(--text-medium); padding: var(--space-24);">Hozircha buyurtmalar yo'q</td></tr>`;
    return;
  }
  listEl.innerHTML = recentOrders.map(order => {
    let statusBadge = 'badge-neutral';
    let statusText = order.status || 'Noma\'lum';
    if (['completed', 'delivered'].includes(statusText.toLowerCase())) statusBadge = 'badge-success';
    else if (['pending', 'processing'].includes(statusText.toLowerCase())) statusBadge = 'badge-warning';
    else if (['cancelled', 'rejected'].includes(statusText.toLowerCase())) statusBadge = 'badge-danger';

    const dateStr = order.created_at ? new Date(order.created_at).toLocaleString('ru-RU') : '-';
    const total = order.total_amount ? formatMoney(order.total_amount) : '-';

    return `
      <tr>
        <td data-label="ID">#${(order.id || '').substring(0, 8)}</td>
        <td data-label="Mijoz">${order.user?.full_name || order.user?.phone || 'Mijoz'}</td>
        <td data-label="Summa" style="font-weight: 500;">${total}</td>
        <td data-label="Sana">${dateStr}</td>
        <td data-label="Holat"><span class="badge ${statusBadge}">${statusText}</span></td>
      </tr>
    `;
  }).join('');
}
