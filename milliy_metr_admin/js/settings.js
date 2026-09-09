/** Yetkazib berish sozlamalari — bazada saqlanadi, ilova darhol ko'radi. */

document.addEventListener('DOMContentLoaded', () => {
  auth.requireAuth();
  layout.inject();

  loadSettings();
  document.getElementById('btn-save-settings').addEventListener('click', saveSettings);

  const resetBtn = document.getElementById('btn-reset-payme');
  if (resetBtn) resetBtn.addEventListener('click', resetPaymeKey);
});

async function loadSettings() {
  try {
    const res = await api.get('/settings/admin');
    const d = res.data || {};
    document.getElementById('delivery-enabled').checked = d.deliveryEnabled !== false;
    document.getElementById('free-threshold').value = d.freeShippingThreshold ?? 0;
    document.getElementById('default-fee').value = d.shippingFee ?? 0;

    const badge = document.getElementById('payme-key-state');
    if (badge) {
      badge.textContent = d.paymeKeyOverridden
        ? 'Payme paroli almashtirilgan'
        : 'Payme paroli standart (Render sozlamasi)';
      badge.className = 'badge ' + (d.paymeKeyOverridden ? 'badge-warning' : 'badge-neutral');
    }
  } catch (err) {
    layout.showToast(err.message, 'error');
  }
}

async function saveSettings() {
  const btn = document.getElementById('btn-save-settings');
  btn.disabled = true;

  const payload = {
    deliveryEnabled: document.getElementById('delivery-enabled').checked,
    freeShippingThreshold: parseFloat(document.getElementById('free-threshold').value) || 0,
    shippingFee: parseFloat(document.getElementById('default-fee').value) || 0,
  };

  try {
    await api.put('/settings/admin', payload);
    layout.showToast(i18n.t('success'));
  } catch (err) {
    layout.showToast(err.message, 'error');
  } finally {
    btn.disabled = false;
  }
}

/**
 * Payme ChangePassword orqali o'rnatilgan parolni bekor qiladi.
 * Shundan keyin Render'dagi PAYME_KEY / PAYME_TEST_KEY yana ishlaydi.
 */
async function resetPaymeKey() {
  if (!confirm("Payme paroli Render sozlamasiga qaytariladi. Davom etilsinmi?")) return;

  const btn = document.getElementById('btn-reset-payme');
  btn.disabled = true;
  try {
    await api.delete('/settings/admin/payme-key');
    layout.showToast(i18n.t('success'));
    loadSettings();
  } catch (err) {
    layout.showToast(err.message, 'error');
  } finally {
    btn.disabled = false;
  }
}
