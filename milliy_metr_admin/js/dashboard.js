/**
 * Boshqaruv paneli — analitika.
 *
 * Barcha hisob-kitob backendda (/analytics/dashboard) bajariladi.
 * Bu fayl faqat chizadi va formatlaydi.
 */

let charts = {};
let currentPeriod = parseInt(localStorage.getItem('dash_period') || '30', 10);

const PALETTE = {
  primary: '#FF6B00',
  primarySoft: 'rgba(255, 107, 0, 0.12)',
  success: '#22A45D',
  danger: '#DE3730',
  warning: '#FFB800',
  neutral: '#8899A6',
  series: ['#FF6B00', '#22A45D', '#3B82F6', '#FFB800', '#A855F7', '#DE3730', '#14B8A6', '#8899A6'],
};

document.addEventListener('DOMContentLoaded', () => {
  auth.requireAuth();
  layout.inject();
  renderPeriodSelector();
  loadDashboard();
});

/** Davr tanlash tugmalari (7 / 30 / 90 / 365 kun) */
function renderPeriodSelector() {
  const host = document.getElementById('period-selector');
  if (!host) return;

  const options = [
    { days: 7, key: 'last7Days' },
    { days: 30, key: 'last30Days' },
    { days: 90, key: 'last90Days' },
    { days: 365, key: 'last365Days' },
  ];

  host.innerHTML = options.map(o => `
    <button type="button" class="btn btn-sm ${o.days === currentPeriod ? '' : 'btn-outline'}"
            data-days="${o.days}">${i18n.t(o.key)}</button>
  `).join('');

  host.querySelectorAll('button').forEach(btn => {
    btn.addEventListener('click', () => {
      currentPeriod = parseInt(btn.dataset.days, 10);
      localStorage.setItem('dash_period', String(currentPeriod));
      renderPeriodSelector();
      loadDashboard();
    });
  });
}

async function loadDashboard() {
  const overlay = document.getElementById('loading-overlay');
  if (overlay) overlay.style.display = 'flex';

  try {
    const res = await api.get(`/analytics/dashboard?days=${currentPeriod}`);
    const d = res.data || res;

    renderKpis(d);
    renderTotals(d.totals || {});
    renderRevenueChart(d.dailySeries || []);
    renderStatusChart(d.statusDistribution || []);
    renderPaymentChart(d.paymentBreakdown || []);
    renderTopProductsChart(d.topProducts || []);
    renderCategoryChart(d.categorySales || []);
    renderCustomersChart(d.newCustomers || []);
    renderLowStock(d.lowStock || []);
    renderRecentOrders(d.recentOrders || []);
  } catch (err) {
    layout.showToast(err.message || i18n.t('error'), 'error');
  } finally {
    if (overlay) overlay.style.display = 'none';
  }
}

/* ─────────────────────────── KPI kartalar ─────────────────────────── */

/** O'zgarish foizini rangli strelka bilan ko'rsatadi. */
function trendHtml(changePct) {
  if (changePct === null || changePct === undefined) {
    return `<span style="color: var(--color-text-medium, #666); font-size: 12px;">—</span>`;
  }
  const flat = changePct === 0;
  const color = flat ? '#8899A6' : (changePct > 0 ? PALETTE.success : PALETTE.danger);
  const arrow = flat ? 'trending_flat' : (changePct > 0 ? 'trending_up' : 'trending_down');
  const sign = changePct > 0 ? '+' : '';
  return `
    <span style="color:${color}; font-size:12px; font-weight:600; display:inline-flex; align-items:center; gap:2px;">
      <span class="material-symbols-rounded" style="font-size:16px;">${arrow}</span>
      ${sign}${changePct}%
    </span>
    <span style="color: var(--color-text-medium, #888); font-size:11px;"> ${i18n.t('vsPrevPeriod')}</span>
  `;
}

function renderKpis(d) {
  const k = d.kpi || {};
  const set = (id, value, trend) => {
    const el = document.getElementById(id);
    if (el) el.innerHTML = `${value}<div style="margin-top:4px;">${trend}</div>`;
  };

  set('kpi-revenue', i18n.money(k.revenue?.value), trendHtml(k.revenue?.changePct));
  set('kpi-orders', i18n.number(k.orders?.value), trendHtml(k.orders?.changePct));
  set('kpi-aov', i18n.money(k.aov?.value), trendHtml(k.aov?.changePct));
  set('kpi-conversion', `${(k.conversion?.value ?? 0).toFixed(1)}%`, trendHtml(k.conversion?.changePct));
}

function renderTotals(t) {
  const set = (id, v) => { const el = document.getElementById(id); if (el) el.textContent = v; };
  set('total-revenue', i18n.money(t.revenue));
  set('total-orders', i18n.number(t.orders));
  set('total-customers', i18n.number(t.customers));
  set('total-products', i18n.number(t.products));
  set('total-today', i18n.number(t.todayOrders));
}

/* ─────────────────────────── Grafiklar ─────────────────────────── */

function destroy(name) {
  if (charts[name]) { charts[name].destroy(); delete charts[name]; }
}

const moneyTick = (v) => {
  const n = Number(v);
  if (n >= 1000000) return (n / 1000000).toFixed(1) + ' mln';
  if (n >= 1000) return Math.round(n / 1000) + ' ming';
  return n;
};

const baseOptions = {
  responsive: true,
  maintainAspectRatio: false,
  interaction: { mode: 'index', intersect: false },
  plugins: {
    legend: { display: false },
    tooltip: {
      backgroundColor: 'rgba(17,24,28,0.92)',
      padding: 12,
      cornerRadius: 8,
      titleFont: { size: 13, weight: '600' },
      bodyFont: { size: 13 },
    },
  },
};

/** Asosiy grafik: kunlik daromad (maydon) + buyurtmalar soni (ikkinchi o'q) */
function renderRevenueChart(series) {
  const ctx = document.getElementById('chart-revenue');
  if (!ctx) return;
  destroy('revenue');

  charts.revenue = new Chart(ctx, {
    type: 'line',
    data: {
      labels: series.map(s => s.label),
      datasets: [
        {
          label: i18n.t('revenue'),
          data: series.map(s => s.revenue),
          borderColor: PALETTE.primary,
          backgroundColor: PALETTE.primarySoft,
          fill: true,
          tension: 0.35,
          borderWidth: 2.5,
          pointRadius: 0,
          pointHoverRadius: 5,
          yAxisID: 'y',
        },
        {
          label: i18n.t('ordersCount'),
          data: series.map(s => s.orders),
          borderColor: PALETTE.series[2],
          borderDash: [5, 4],
          fill: false,
          tension: 0.35,
          borderWidth: 2,
          pointRadius: 0,
          pointHoverRadius: 5,
          yAxisID: 'y1',
        },
      ],
    },
    options: {
      ...baseOptions,
      plugins: {
        ...baseOptions.plugins,
        legend: { display: true, position: 'top', align: 'end', labels: { usePointStyle: true, boxWidth: 8 } },
        tooltip: {
          ...baseOptions.plugins.tooltip,
          callbacks: {
            label: (c) => c.datasetIndex === 0
              ? `${i18n.t('revenue')}: ${i18n.money(c.parsed.y)}`
              : `${i18n.t('ordersCount')}: ${c.parsed.y}`,
          },
        },
      },
      scales: {
        y: {
          position: 'left',
          beginAtZero: true,
          grid: { color: 'rgba(0,0,0,0.05)' },
          ticks: { callback: moneyTick },
        },
        y1: {
          position: 'right',
          beginAtZero: true,
          grid: { drawOnChartArea: false },
          ticks: { precision: 0 },
        },
        x: { grid: { display: false }, ticks: { maxTicksLimit: 12, autoSkip: true } },
      },
    },
  });
}

/** Buyurtma holatlari — donut */
function renderStatusChart(dist) {
  const ctx = document.getElementById('chart-status');
  if (!ctx) return;
  destroy('status');

  const total = dist.reduce((s, x) => s + x.count, 0);
  const colorFor = (s) => {
    if (['delivered', 'completed'].includes(s)) return PALETTE.success;
    if (s === 'cancelled') return PALETTE.danger;
    if (['confirmed', 'processing'].includes(s)) return PALETTE.warning;
    return PALETTE.neutral;
  };

  charts.status = new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: dist.map(x => i18n.status(x.status)),
      datasets: [{
        data: dist.map(x => x.count),
        backgroundColor: dist.map(x => colorFor(x.status)),
        borderWidth: 0,
      }],
    },
    options: {
      ...baseOptions,
      cutout: '68%',
      plugins: {
        ...baseOptions.plugins,
        legend: { display: true, position: 'bottom', labels: { usePointStyle: true, boxWidth: 8, padding: 12 } },
        tooltip: {
          ...baseOptions.plugins.tooltip,
          callbacks: {
            label: (c) => {
              const pct = total ? ((c.parsed / total) * 100).toFixed(1) : 0;
              return `${c.label}: ${c.parsed} (${pct}%)`;
            },
          },
        },
      },
    },
  });
}

/** To'lov usullari — gorizontal bar */
function renderPaymentChart(data) {
  const ctx = document.getElementById('chart-payment');
  if (!ctx) return;
  destroy('payment');

  charts.payment = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: data.map(x => (x.method || '—').toUpperCase()),
      datasets: [{
        data: data.map(x => x.revenue),
        backgroundColor: data.map((_, i) => PALETTE.series[i % PALETTE.series.length]),
        borderRadius: 6,
        barThickness: 28,
      }],
    },
    options: {
      ...baseOptions,
      indexAxis: 'y',
      plugins: {
        ...baseOptions.plugins,
        tooltip: {
          ...baseOptions.plugins.tooltip,
          callbacks: { label: (c) => i18n.money(c.parsed.x) },
        },
      },
      scales: {
        x: { beginAtZero: true, grid: { color: 'rgba(0,0,0,0.05)' }, ticks: { callback: moneyTick } },
        y: { grid: { display: false } },
      },
    },
  });
}

/** Top mahsulotlar — gorizontal bar, daromad bo'yicha */
function renderTopProductsChart(data) {
  const ctx = document.getElementById('chart-top-products');
  if (!ctx) return;
  destroy('topProducts');

  const short = (s) => (s && s.length > 28 ? s.slice(0, 27) + '…' : s || '—');

  charts.topProducts = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: data.map(x => short(x.name)),
      datasets: [{
        data: data.map(x => x.revenue),
        backgroundColor: PALETTE.primary,
        borderRadius: 6,
        barThickness: 20,
      }],
    },
    options: {
      ...baseOptions,
      indexAxis: 'y',
      plugins: {
        ...baseOptions.plugins,
        tooltip: {
          ...baseOptions.plugins.tooltip,
          callbacks: {
            title: (items) => data[items[0].dataIndex]?.name || '',
            label: (c) => {
              const item = data[c.dataIndex];
              return [`${i18n.t('revenue')}: ${i18n.money(item.revenue)}`,
                      `${i18n.t('quantity')}: ${item.quantity}`];
            },
          },
        },
      },
      scales: {
        x: { beginAtZero: true, grid: { color: 'rgba(0,0,0,0.05)' }, ticks: { callback: moneyTick } },
        y: { grid: { display: false } },
      },
    },
  });
}

/** Kategoriyalar — donut */
function renderCategoryChart(data) {
  const ctx = document.getElementById('chart-categories');
  if (!ctx) return;
  destroy('categories');

  const total = data.reduce((s, x) => s + x.revenue, 0);

  charts.categories = new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: data.map(x => x.name),
      datasets: [{
        data: data.map(x => x.revenue),
        backgroundColor: data.map((_, i) => PALETTE.series[i % PALETTE.series.length]),
        borderWidth: 0,
      }],
    },
    options: {
      ...baseOptions,
      cutout: '60%',
      plugins: {
        ...baseOptions.plugins,
        legend: { display: true, position: 'bottom', labels: { usePointStyle: true, boxWidth: 8, padding: 10, font: { size: 11 } } },
        tooltip: {
          ...baseOptions.plugins.tooltip,
          callbacks: {
            label: (c) => {
              const pct = total ? ((c.parsed / total) * 100).toFixed(1) : 0;
              return `${i18n.money(c.parsed)} (${pct}%)`;
            },
          },
        },
      },
    },
  });
}

/** Yangi mijozlar — ustunli grafik */
function renderCustomersChart(data) {
  const ctx = document.getElementById('chart-customers');
  if (!ctx) return;
  destroy('customers');

  charts.customers = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: data.map(x => x.label),
      datasets: [{
        data: data.map(x => x.count),
        backgroundColor: PALETTE.series[2],
        borderRadius: 6,
      }],
    },
    options: {
      ...baseOptions,
      scales: {
        y: { beginAtZero: true, grid: { color: 'rgba(0,0,0,0.05)' }, ticks: { precision: 0 } },
        x: { grid: { display: false } },
      },
    },
  });
}

/* ─────────────────────────── Jadvallar ─────────────────────────── */

function renderLowStock(items) {
  const tbody = document.getElementById('low-stock-list');
  if (!tbody) return;

  if (!items.length) {
    tbody.innerHTML = `<tr><td colspan="2" class="text-center">${i18n.t('noData')}</td></tr>`;
    return;
  }

  tbody.innerHTML = items.map(p => {
    const critical = p.stock <= 3;
    return `
      <tr>
        <td style="font-weight:500;">${p.name}</td>
        <td><span class="badge ${critical ? 'badge-danger' : 'badge-warning'}">${p.stock}</span></td>
      </tr>`;
  }).join('');
}

function renderRecentOrders(orders) {
  const tbody = document.getElementById('recent-orders-list');
  if (!tbody) return;

  if (!orders.length) {
    tbody.innerHTML = `<tr><td colspan="5" class="text-center">${i18n.t('noData')}</td></tr>`;
    return;
  }

  const locale = i18n.lang === 'ru' ? 'ru-RU' : 'uz-UZ';

  tbody.innerHTML = orders.map(o => `
    <tr>
      <td>${o.orderNumber || '#' + String(o.id).substring(0, 8)}</td>
      <td>${o.customerName || '—'}</td>
      <td style="font-weight:600;">${i18n.money(o.total)}</td>
      <td>${o.createdAt ? new Date(o.createdAt).toLocaleString(locale) : '—'}</td>
      <td><span class="badge ${i18n.statusBadge(o.status)}">${i18n.status(o.status)}</span></td>
    </tr>
  `).join('');
}
