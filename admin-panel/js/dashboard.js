document.addEventListener('DOMContentLoaded', () => {
  auth.requireAuth();
  layout.inject();
  
  loadDashboardData();
});

async function loadDashboardData() {
  const overlay = document.getElementById('loading-overlay');
  
  try {
    // Attempt to fetch dashboard data. 
    // The spec notes /admin/dashboard exists, let's also fetch orders to show recent ones
    const [dashboardRes, ordersRes] = await Promise.all([
      api.get('/admin/dashboard').catch(() => ({ data: {} })), // Fallback if endpoint fails
      api.get('/orders').catch(() => ({ data: [] }))
    ]);
    
    const kpi = dashboardRes.data || {};
    const orders = ordersRes.data || [];
    
    // Format numbers
    const formatNum = (num) => {
      if (!num) return '0';
      return parseInt(num).toLocaleString('ru-RU');
    };
    
    // Update KPI UI
    document.getElementById('kpi-products').textContent = formatNum(kpi.total_products);
    document.getElementById('kpi-users').textContent = formatNum(kpi.total_users);
    document.getElementById('kpi-orders').textContent = formatNum(kpi.total_orders);
    
    if (kpi.total_revenue) {
        document.getElementById('kpi-revenue').textContent = formatNum(kpi.total_revenue) + ' so\'m';
    } else {
        document.getElementById('kpi-revenue').textContent = '0 so\'m';
    }
    
    // Update Recent Orders (Take top 5)
    const recentOrders = orders.slice(0, 5);
    const listEl = document.getElementById('recent-orders-list');
    
    if (recentOrders.length === 0) {
      listEl.innerHTML = `
        <tr>
          <td colspan="5" class="text-center" style="color: var(--text-medium); padding: var(--space-24);">
            Hozircha buyurtmalar yo'q
          </td>
        </tr>
      `;
    } else {
      listEl.innerHTML = recentOrders.map(order => {
        let statusBadge = 'badge-neutral';
        let statusText = order.status || 'Noma\'lum';
        
        if (['completed', 'delivered'].includes(statusText.toLowerCase())) statusBadge = 'badge-success';
        else if (['pending', 'processing'].includes(statusText.toLowerCase())) statusBadge = 'badge-warning';
        else if (['cancelled', 'rejected'].includes(statusText.toLowerCase())) statusBadge = 'badge-danger';
        
        const dateStr = order.created_at ? new Date(order.created_at).toLocaleString('ru-RU') : '-';
        const total = order.total_amount ? parseInt(order.total_amount).toLocaleString('ru-RU') + ' so\'m' : '-';
        
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
    
  } catch (err) {
    layout.showToast(err.message, 'error');
  } finally {
    if (overlay) overlay.style.display = 'none';
  }
}
