/** Yetkazib berish sozlamalari — bazada saqlanadi, ilova darhol ko'radi. */

document.addEventListener('DOMContentLoaded', () => {
  auth.requireAuth();
  layout.inject();

  loadSettings();
  document.getElementById('btn-save-settings').addEventListener('click', saveSettings);

  const resetBtn = document.getElementById('btn-reset-payme');
  if (resetBtn) resetBtn.addEventListener('click', resetPaymeKey);

  const resetTxBtn = document.getElementById('btn-reset-transactional');
  if (resetTxBtn) resetTxBtn.addEventListener('click', resetTransactionalData);
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

/**
 * QAYTARIB BO'LMAYDI: barcha buyurtma va to'lov yozuvlarini o'chiradi.
 * Mijozlar, mahsulotlar, kategoriyalar, bannerlar tegilmaydi.
 */
async function resetTransactionalData() {
  const step1 = confirm(
    "DIQQAT: Barcha buyurtma va to'lovlar butunlay o'chiriladi.\n\n" +
    "Mijozlar, mahsulotlar, kategoriyalar, bannerlar TEGILMAYDI.\n\n" +
    "Bu amalni qaytarib bo'lmaydi. Davom etasizmi?"
  );
  if (!step1) return;

  const step2 = prompt("Tasdiqlash uchun katta harflar bilan O'CHIR deb yozing:");
  if (step2 !== "O'CHIR") {
    layout.showToast('Bekor qilindi', 'error');
    return;
  }

  const btn = document.getElementById('btn-reset-transactional');
  btn.disabled = true;
  btn.textContent = 'Tozalanmoqda...';

  try {
    const res = await api.delete('/settings/admin/reset-transactional-data');
    const d = res.data || {};
    layout.showToast(
      `Tozalandi: ${d.orders_deleted || 0} buyurtma, ${d.payments_deleted || 0} to'lov o'chirildi`
    );
  } catch (err) {
    layout.showToast(err.message, 'error');
  } finally {
    btn.disabled = false;
    btn.innerHTML = '<span class="material-symbols-rounded" style="font-size:18px;">delete_forever</span> Buyurtma va to\'lovlarni butunlay tozalash';
  }
}
