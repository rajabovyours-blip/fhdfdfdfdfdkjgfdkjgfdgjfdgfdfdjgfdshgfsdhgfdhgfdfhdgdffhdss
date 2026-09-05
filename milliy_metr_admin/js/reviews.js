document.addEventListener('DOMContentLoaded', () => {
  auth.requireAuth();
  
  layout.inject();
  loadReviews();
});

async function loadReviews() {
  const list = document.getElementById('reviews-list');
  try {
    const data = await api.get('/admin/reviews');
    
    if (data.length === 0) {
      list.innerHTML = '<tr><td colspan="6" class="text-center text-medium">Sharhlar topilmadi</td></tr>';
      return;
    }
    
    list.innerHTML = data.map(r => {
      const date = new Date(r.created_at || new Date()).toLocaleString('uz-UZ');
      
      let stars = '';
      const rating = Math.round(parseFloat(r.rating || 0));
      for (let i = 1; i <= 5; i++) {
        stars += `<span class="material-symbols-rounded star" style="color: ${i <= rating ? '#FFB800' : '#E0E0E0'};">star</span>`;
      }
      
      return `
        <tr>
          <td style="white-space: nowrap;">${date}</td>
          <td>${r.product_name || (r.product ? r.product.name?.uz || r.product.name : 'Noma\'lum')}</td>
          <td>${r.user_name || (r.user ? r.user.full_name : 'Noma\'lum')}</td>
          <td style="white-space: nowrap;">${stars}</td>
          <td>${r.comment || ''}</td>
          <td class="text-center">
            <button class="btn btn-sm btn-outline" style="padding: 0 8px; color: var(--color-danger); border-color: var(--color-danger);" onclick="deleteReview('${r.id}')" title="O'chirish">
              <span class="material-symbols-rounded" style="font-size: 18px;">delete</span>
            </button>
          </td>
        </tr>
      `;
    }).join('');
  } catch (err) {
    list.innerHTML = '<tr><td colspan="6" class="text-center text-danger">Xatolik yuz berdi</td></tr>';
    layout.showToast(err.message, 'error');
  }
}

async function deleteReview(id) {
  if (!confirm('Haqiqatan ham ushbu sharhni o\'chirmoqchimisiz?')) return;
  
  try {
    await api.delete(`/admin/reviews/${id}`);
    layout.showToast('Sharh o\'chirildi');
    loadReviews();
  } catch (err) {
    layout.showToast(err.message, 'error');
  }
}
