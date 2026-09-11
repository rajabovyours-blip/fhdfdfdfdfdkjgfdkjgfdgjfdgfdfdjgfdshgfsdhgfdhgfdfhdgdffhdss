const layout = {
  inject() {
    const appContainer = document.getElementById('app');
    if (!appContainer) return;

    appContainer.classList.add('app-container');

    const user = auth.getUserInfo();
    const userName = user ? (user.full_name || user.fullName || user.username || 'Admin') : 'Admin';
    const currentPage = window.location.pathname.split('/').pop() || 'dashboard.html';

    const T = (k) => (typeof i18n !== 'undefined' ? i18n.t(k) : k);
    const currentLang = (typeof i18n !== 'undefined' ? i18n.lang : 'uz');

    const navItems = [
      { href: 'dashboard.html', icon: 'dashboard', key: 'dashboard', match: 'dashboard' },
      { href: 'orders.html', icon: 'shopping_cart', key: 'orders', match: 'order' },
      { href: 'products.html', icon: 'inventory_2', key: 'products', match: 'product' },
      { href: 'categories.html', icon: 'category', key: 'categories', match: 'categor' },
      { href: 'users.html', icon: 'group', key: 'customers', match: 'users.html' },
      { href: 'chat.html', icon: 'chat', key: 'chat', match: 'chat' },
      { href: 'banners.html', icon: 'view_carousel', key: 'banners', match: 'banner' },
      { href: 'reviews.html', icon: 'reviews', key: 'reviews', match: 'review' },
      { href: 'notifications.html', icon: 'notifications', key: 'notifications', match: 'notification' },
      { href: 'payments.html', icon: 'payments', key: 'payments', match: 'payment' },
      { href: 'admin-users.html', icon: 'admin_panel_settings', key: 'admins', match: 'admin-users' },
      { href: 'settings.html', icon: 'settings', key: 'settings', match: 'settings' },
    ];

    const navHTML = navItems.map((item) => {
      let isActive = currentPage.includes(item.match);
      // "users.html" va "admin-users.html" ni chalkashtirmaslik uchun
      if (item.key === 'customers') isActive = currentPage.includes('users.html') && !currentPage.includes('admin-users');
      return `
        <a href="${item.href}" class="nav-item ${isActive ? 'active' : ''}">
          <span class="material-symbols-rounded">${item.icon}</span>
          ${T(item.key)}
        </a>`;
    }).join('');

    const sidebarHTML = `
      <aside class="app-sidebar" id="sidebar">
        <div class="app-sidebar-header">
          <div class="app-sidebar-logo">
            <img src="assets/images/logo.png" alt="Milliy Metr" style="height: 32px; width: auto; object-fit: contain;">
            Milliy Metr
          </div>
        </div>
        <nav class="app-nav">${navHTML}</nav>
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
          <div class="lang-switch" style="display:inline-flex; border:1px solid var(--color-outline, #ddd); border-radius:8px; overflow:hidden;">
            <button type="button" class="lang-btn" data-lang="uz"
              style="padding:4px 10px; border:none; cursor:pointer; font-weight:600; font-size:13px;
                     background:${currentLang === 'uz' ? 'var(--color-primary, #FF6B00)' : 'transparent'};
                     color:${currentLang === 'uz' ? '#fff' : 'inherit'};">UZ</button>
            <button type="button" class="lang-btn" data-lang="ru"
              style="padding:4px 10px; border:none; cursor:pointer; font-weight:600; font-size:13px;
                     background:${currentLang === 'ru' ? 'var(--color-primary, #FF6B00)' : 'transparent'};
                     color:${currentLang === 'ru' ? '#fff' : 'inherit'};">RU</button>
          </div>
          <span style="font-weight: 500;">${userName}</span>
          <button class="btn btn-sm btn-outline" id="logout-btn">
            <span class="material-symbols-rounded" style="font-size: 18px;">logout</span>
            ${T('logout')}
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

    // Til almashtirish
    document.querySelectorAll('.lang-btn').forEach((btn) => {
      btn.addEventListener('click', () => {
        if (typeof i18n !== 'undefined') i18n.setLang(btn.dataset.lang);
      });
    });

    document.getElementById('logout-btn')?.addEventListener('click', () => {
      auth.logout();
    });

    const sidebar = document.getElementById('sidebar');

    let backdrop = document.getElementById('sidebar-backdrop');
    if (!backdrop) {
      backdrop = document.createElement('div');
      backdrop.id = 'sidebar-backdrop';
      backdrop.className = 'sidebar-backdrop';
      document.body.appendChild(backdrop);
    }

    document.getElementById('menu-toggle')?.addEventListener('click', (e) => {
      e.stopPropagation();
      sidebar.classList.toggle('open');
      backdrop.classList.toggle('active');
    });

    backdrop.addEventListener('click', () => {
      sidebar.classList.remove('open');
      backdrop.classList.remove('active');
    });

    document.querySelectorAll('.nav-item').forEach(item => {
      item.addEventListener('click', () => {
        if (window.innerWidth <= 1023) {
          sidebar.classList.remove('open');
          backdrop.classList.remove('active');
        }
      });
    });

    // Sahifadagi data-i18n elementlarini tarjima qilish
    if (typeof i18n !== 'undefined') i18n.apply();
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
