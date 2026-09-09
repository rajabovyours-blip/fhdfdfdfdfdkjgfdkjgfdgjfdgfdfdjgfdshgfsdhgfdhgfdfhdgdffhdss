/** Yetkazib berish sozlamalari — bazada saqlanadi, ilova darhol ko'radi. */

document.addEventListener('DOMContentLoaded', () => {
  auth.requireAuth();
  layout.inject();

  loadSettings();
  document.getElementById('btn-save-settings').addEventListener('click', saveSettings);
});

async function loadSettings() {
  try {
    const res = await api.get('/settings/admin');
    const d = res.data || {};
    document.getElementById('delivery-enabled').checked = d.deliveryEnabled !== false;
    document.getElementById('free-threshold').value = d.freeShippingThreshold ?? 0;
    document.getElementById('default-fee').value = d.shippingFee ?? 0;
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
