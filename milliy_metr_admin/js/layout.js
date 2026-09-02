const layout = {
  inject() {
    const appContainer = document.getElementById('app');
    if (!appContainer) return;
    
    appContainer.classList.add('app-container');
    
    const user = auth.getUserInfo();
    const userName = user ? (user.full_name || user.fullName || user.username || 'Admin') : 'Admin';
    const currentPage = window.location.pathname.split('/').pop() || 'dashboard.html';

    const sidebarHTML = `
      <aside class="app-sidebar" id="sidebar">
        <div class="app-sidebar-header">
          <div class="app-sidebar-logo">
            <img src="assets/images/logo.png" alt="Milliy Metr" style="height: 32px; width: auto; object-fit: contain;">
            Milliy Metr
          </div>
        </div>
        <nav class="app-nav">
          <a href="dashboard.html" class="nav-item ${currentPage.includes('dashboard') ? 'active' : ''}">
            <span class="material-symbols-rounded">dashboard</span>
            Boshqaruv
          </a>
          <a href="orders.html" class="nav-item ${currentPage.includes('order') ? 'active' : ''}">
            <span class="material-symbols-rounded">shopping_cart</span>
            Buyurtmalar
          </a>
          <a href="products.html" class="nav-item ${currentPage.includes('product') ? 'active' : ''}">
            <span class="material-symbols-rounded">inventory_2</span>
            Mahsulotlar
          </a>
          <a href="categories.html" class="nav-item ${currentPage.includes('categor') ? 'active' : ''}">
            <span class="material-symbols-rounded">category</span>
            Kategoriyalar
          </a>
          <a href="users.html" class="nav-item ${currentPage.includes('users.html') && !currentPage.includes('admin') ? 'active' : ''}">
            <span class="material-symbols-rounded">group</span>
            Mijozlar
          </a>
          <a href="banners.html" class="nav-item ${currentPage.includes('banner') ? 'active' : ''}">
            <span class="material-symbols-rounded">view_carousel</span>
            Bannerlar
          </a>
          <a href="notifications.html" class="nav-item ${currentPage.includes('notification') ? 'active' : ''}">
            <span class="material-symbols-rounded">notifications</span>
            Bildirishnomalar
          </a>
          <a href="admin-users.html" class="nav-item ${currentPage.includes('admin-users') ? 'active' : ''}">
            <span class="material-symbols-rounded">admin_panel_settings</span>
            Adminlar
          </a>
        </nav>
      </aside>
    `;

    const headerHTML = `
      <header class="app-header">
        <div class="d-flex align-items-center gap-16">
          <button class="mobile-menu-btn" id="menu-toggle">
            <span class="material-symbols-rounded">menu</span>
          </button>
          <h2 id="page-title" style="margin: 0;">${document.title}</h2>
        </div>
        
        <div class="d-flex align-items-center gap-16">
          <span style="font-weight: 500;">${userName}</span>
          <button class="btn btn-sm btn-outline" id="logout-btn">
            <span class="material-symbols-rounded" style="font-size: 18px;">logout</span>
            Chiqish
          </button>
        </div>
      </header>
    `;

    const contentArea = appContainer.innerHTML;
    
    appContainer.innerHTML = `
      ${sidebarHTML}
      <div class="app-main">
        ${headerHTML}
        <main class="app-content">
          ${contentArea}
        </main>
      </div>
    `;

    // Event listeners
    document.getElementById('logout-btn')?.addEventListener('click', () => {
      auth.logout();
    });

    const sidebar = document.getElementById('sidebar');
    
    // Create backdrop for mobile sidebar
    let backdrop = document.getElementById('sidebar-backdrop');
    if (!backdrop) {
      backdrop = document.createElement('div');
      backdrop.id = 'sidebar-backdrop';
      backdrop.className = 'sidebar-backdrop';
      document.body.appendChild(backdrop);
    }
    
    document.getElementById('menu-toggle')?.addEventListener('click', () => {
      sidebar.classList.toggle('open');
      backdrop.classList.toggle('active');
    });

    // Close sidebar when clicking backdrop
    backdrop.addEventListener('click', () => {
      sidebar.classList.remove('open');
      backdrop.classList.remove('active');
    });

    // Close sidebar when clicking main content on mobile
    document.querySelector('.app-main')?.addEventListener('click', (e) => {
      if (window.innerWidth <= 1023 && sidebar.classList.contains('open')) {
        sidebar.classList.remove('open');
        backdrop.classList.remove('active');
      }
    });
  },
  
  showToast(message, type = 'success') {
    let container = document.getElementById('toast-container');
    if (!container) {
      container = document.createElement('div');
      container.id = 'toast-container';
      document.body.appendChild(container);
    }
    
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    
    let icon = 'info';
    if (type === 'success') icon = 'check_circle';
    if (type === 'error') icon = 'error';
    
    toast.innerHTML = `
      <span class="material-symbols-rounded">${icon}</span>
      <span>${message}</span>
    `;
    
    container.appendChild(toast);
    
    setTimeout(() => {
      toast.style.animation = 'slideUp 0.3s ease-in reverse forwards';
      setTimeout(() => toast.remove(), 300);
    }, 3000);
  }
};
