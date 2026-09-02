/**
 * Generic API Fetch Wrapper
 * Handles token injection, JSON parsing, and basic error handling.
 */
const api = {
  async request(endpoint, options = {}) {
    const url = `${CONFIG.API_BASE_URL}${endpoint}`;
    
    // Default headers
    const headers = {
      ...options.headers,
    };

    // Handle body serialization based on type
    if (options.body instanceof FormData) {
      // Let browser set Content-Type with boundary for multipart
    } else if (options.isUrlEncoded) {
      headers['Content-Type'] = 'application/x-www-form-urlencoded';
    } else if (options.body && typeof options.body === 'object') {
      headers['Content-Type'] = 'application/json';
      options.body = JSON.stringify(options.body);
    } else if (options.body && typeof options.body === 'string' && !headers['Content-Type']) {
      // String body without explicit content-type: assume form-urlencoded if it looks like it
      if (options.body.includes('=')) {
        headers['Content-Type'] = 'application/x-www-form-urlencoded';
      }
    }

    // Clean up custom flags
    delete options.isUrlEncoded;

    // Add Auth token if available
    const token = localStorage.getItem('mm_admin_access_token');
    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    try {
      const response = await fetch(url, {
        ...options,
        headers
      });

      // Handle 401 Unauthorized globally
      if (response.status === 401) {
        // Clear token and redirect to login
        auth.logout();
        return;
      }

      // Read response
      const text = await response.text();
      let data;
      try {
        data = text ? JSON.parse(text) : {};
      } catch (e) {
        data = text;
      }

      if (!response.ok) {
        const errorMsg = data.detail || data.message || `Xatolik yuz berdi (${response.status})`;
        throw new Error(errorMsg);
      }

      return data;
    } catch (error) {
      console.error(`API Error on ${endpoint}:`, error);
      throw error;
    }
  },

  get(endpoint, options = {}) {
    return this.request(endpoint, { ...options, method: 'GET' });
  },

  post(endpoint, body, options = {}) {
    return this.request(endpoint, { ...options, method: 'POST', body });
  },

  put(endpoint, body, options = {}) {
    return this.request(endpoint, { ...options, method: 'PUT', body });
  },

  patch(endpoint, body, options = {}) {
    return this.request(endpoint, { ...options, method: 'PATCH', body });
  },

  delete(endpoint, options = {}) {
    return this.request(endpoint, { ...options, method: 'DELETE' });
  },

  // Helper to safely format image URLs
  getImageUrl(url) {
    if (!url) return '';
    if (url.startsWith('http://') || url.startsWith('https://') || url.startsWith('data:')) {
      return url;
    }
    let base = CONFIG.API_BASE_URL.replace('/api/v1', '');
    if (base.endsWith('/')) base = base.slice(0, -1);
    if (!url.startsWith('/')) url = '/' + url;
    return base + url;
  }
};
