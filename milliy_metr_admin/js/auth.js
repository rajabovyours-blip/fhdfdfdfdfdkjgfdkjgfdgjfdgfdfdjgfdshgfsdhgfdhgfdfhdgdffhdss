const auth = {
  // Check if user is logged in
  isAuthenticated() {
    return !!localStorage.getItem('mm_admin_access_token');
  },

  // Perform login
  async login(username, password) {
    try {
      const payload = new URLSearchParams();
      payload.append('username', username);
      payload.append('password', password);
      
      const res = await api.post('/auth/admin-login', payload.toString(), { isUrlEncoded: true });
      
      // Save tokens
      const tokenData = res.data || res;
      localStorage.setItem('mm_admin_access_token', tokenData.access_token);
      if (tokenData.refresh_token) {
        localStorage.setItem('mm_admin_refresh_token', tokenData.refresh_token);
      }
      
      const user = await this.getCurrentUser();
      
      // Backend already verified admin role during /admin-login
      // Store user info
      localStorage.setItem('mm_admin_user', JSON.stringify(user));
      
      return user;
    } catch (e) {
      this.logout();
      throw e;
    }
  },

  // Get current user data
  async getCurrentUser() {
    const res = await api.get('/auth/me');
    return res.data || res;
  },

  getUserInfo() {
    try {
      return JSON.parse(localStorage.getItem('mm_admin_user'));
    } catch (e) {
      return null;
    }
  },

  // Logout
  logout() {
    localStorage.removeItem('mm_admin_access_token');
    localStorage.removeItem('mm_admin_refresh_token');
    localStorage.removeItem('mm_admin_user');
    
    // Redirect to login if not already there
    if (!window.location.pathname.endsWith('index.html') && 
        window.location.pathname !== '/' && 
        !window.location.pathname.includes('/admin-panel/')) {
        window.location.href = 'index.html';
    }
  },

  // Route guard
  requireAuth() {
    if (!this.isAuthenticated()) {
      window.location.href = 'index.html';
    }
  },
  
  // Inverse route guard (for login page)
  requireGuest() {
    if (this.isAuthenticated()) {
      window.location.href = 'dashboard.html';
    }
  }
};
