/**
 * Admin panel tarjima tizimi (o'zbekcha / ruscha).
 *
 * Ishlatilishi:
 *   HTML da:  <span data-i18n="orders">Buyurtmalar</span>
 *   JS da:    i18n.t('orders')
 *   Holatlar: i18n.status('confirmed')  ->  "Tasdiqlangan" / "Подтверждён"
 *
 * Til tanlovi localStorage da saqlanadi va sahifa yangilanganda tiklanadi.
 */
const i18n = {
  _lang: localStorage.getItem('admin_lang') || 'uz',

  dict: {
    uz: {
      // Navigatsiya
      dashboard: 'Boshqaruv',
      orders: 'Buyurtmalar',
      products: 'Mahsulotlar',
      categories: 'Kategoriyalar',
      customers: 'Mijozlar',
      banners: 'Bannerlar',
      reviews: 'Sharhlar',
      notifications: 'Bildirishnomalar',
      payments: "To'lovlar",
      admins: 'Adminlar',
      logout: 'Chiqish',
      language: 'Til',

      // Umumiy
      search: 'Qidirish',
      save: 'Saqlash',
      cancel: 'Bekor qilish',
      delete: "O'chirish",
      edit: 'Tahrirlash',
      add: "Qo'shish",
      close: 'Yopish',
      loading: 'Yuklanmoqda...',
      noData: "Ma'lumot yo'q",
      total: 'Jami',
      date: 'Sana',
      status: 'Holat',
      actions: 'Amallar',
      customer: 'Mijoz',
      phone: 'Telefon',
      address: 'Manzil',
      amount: 'Summa',
      quantity: 'Miqdor',
      price: 'Narx',
      confirmDelete: "Rostdan ham o'chirmoqchimisiz?",
      error: 'Xatolik',
      success: 'Muvaffaqiyatli',

      // Dashboard
      revenue: 'Daromad',
      revenuePeriod: 'Davr daromadi',
      ordersCount: 'Buyurtmalar soni',
      avgCheck: "O'rtacha chek",
      conversionRate: "To'lov konversiyasi",
      vsPrevPeriod: 'oldingi davrga nisbatan',
      totalRevenue: 'Umumiy daromad',
      totalOrders: 'Jami buyurtmalar',
      totalCustomers: 'Jami mijozlar',
      totalProducts: 'Jami mahsulotlar',
      todayOrders: 'Bugungi buyurtmalar',
      revenueDynamics: 'Daromad dinamikasi',
      ordersByStatus: 'Buyurtmalar holati bo\'yicha',
      paymentMethods: "To'lov usullari",
      topProducts: 'Eng ko\'p daromad keltirgan mahsulotlar',
      categorySales: 'Kategoriyalar bo\'yicha savdo',
      newCustomers: 'Yangi mijozlar',
      lowStock: 'Ombordagi kam qolgan mahsulotlar',
      recentOrders: "So'nggi buyurtmalar",
      last7Days: 'Oxirgi 7 kun',
      last30Days: 'Oxirgi 30 kun',
      last90Days: 'Oxirgi 90 kun',
      last365Days: 'Oxirgi 1 yil',
      remaining: 'Qolgan',
      last90DaysShort: '90 kun',

      // Buyurtma holatlari
      st_pending: 'Kutilmoqda',
      st_processing: 'Jarayonda',
      st_confirmed: 'Tasdiqlangan',
      st_completed: 'Yakunlangan',
      st_delivered: 'Yetkazilgan',
      st_cancelled: 'Bekor qilingan',

      // To'lov holatlari
      ps_pending: 'Kutilmoqda',
      ps_waiting: 'Kutilmoqda',
      ps_paid: "To'langan",
      ps_cancelled: 'Bekor qilingan',
      ps_refunded: 'Qaytarilgan',
    },

    ru: {
      // Навигация
      dashboard: 'Панель',
      orders: 'Заказы',
      products: 'Товары',
      categories: 'Категории',
      customers: 'Клиенты',
      banners: 'Баннеры',
      reviews: 'Отзывы',
      notifications: 'Уведомления',
      payments: 'Платежи',
      admins: 'Администраторы',
      logout: 'Выйти',
      language: 'Язык',

      // Общее
      search: 'Поиск',
      save: 'Сохранить',
      cancel: 'Отмена',
      delete: 'Удалить',
      edit: 'Изменить',
      add: 'Добавить',
      close: 'Закрыть',
      loading: 'Загрузка...',
      noData: 'Нет данных',
      total: 'Итого',
      date: 'Дата',
      status: 'Статус',
      actions: 'Действия',
      customer: 'Клиент',
      phone: 'Телефон',
      address: 'Адрес',
      amount: 'Сумма',
      quantity: 'Количество',
      price: 'Цена',
      confirmDelete: 'Вы действительно хотите удалить?',
      error: 'Ошибка',
      success: 'Успешно',

      // Дашборд
      revenue: 'Выручка',
      revenuePeriod: 'Выручка за период',
      ordersCount: 'Количество заказов',
      avgCheck: 'Средний чек',
      conversionRate: 'Конверсия оплаты',
      vsPrevPeriod: 'к предыдущему периоду',
      totalRevenue: 'Общая выручка',
      totalOrders: 'Всего заказов',
      totalCustomers: 'Всего клиентов',
      totalProducts: 'Всего товаров',
      todayOrders: 'Заказы сегодня',
      revenueDynamics: 'Динамика выручки',
      ordersByStatus: 'Заказы по статусам',
      paymentMethods: 'Способы оплаты',
      topProducts: 'Топ товаров по выручке',
      categorySales: 'Продажи по категориям',
      newCustomers: 'Новые клиенты',
      lowStock: 'Товары на исходе',
      recentOrders: 'Последние заказы',
      last7Days: 'Последние 7 дней',
      last30Days: 'Последние 30 дней',
      last90Days: 'Последние 90 дней',
      last365Days: 'Последний год',
      remaining: 'Осталось',
      last90DaysShort: '90 дней',

      // Статусы заказов
      st_pending: 'В ожидании',
      st_processing: 'В обработке',
      st_confirmed: 'Подтверждён',
      st_completed: 'Завершён',
      st_delivered: 'Доставлен',
      st_cancelled: 'Отменён',

      // Статусы оплаты
      ps_pending: 'В ожидании',
      ps_waiting: 'В ожидании',
      ps_paid: 'Оплачен',
      ps_cancelled: 'Отменён',
      ps_refunded: 'Возвращён',
    },
  },

  get lang() {
    return this._lang;
  },

  /** Kalit bo'yicha tarjima. Topilmasa kalitning o'zini qaytaradi. */
  t(key) {
    const d = this.dict[this._lang] || this.dict.uz;
    return d[key] !== undefined ? d[key] : (this.dict.uz[key] !== undefined ? this.dict.uz[key] : key);
  },

  /** Buyurtma holatini tarjima qiladi (confirmed -> Tasdiqlangan). */
  status(raw) {
    if (!raw) return '—';
    return this.t('st_' + String(raw).toLowerCase().trim());
  },

  /** To'lov holatini tarjima qiladi (paid -> To'langan). */
  paymentStatus(raw) {
    if (!raw) return '—';
    return this.t('ps_' + String(raw).toLowerCase().trim());
  },

  /** Holatga mos rang klassi (badge uchun). */
  statusBadge(raw) {
    const s = String(raw || '').toLowerCase().trim();
    if (['paid', 'delivered', 'completed'].includes(s)) return 'badge-success';
    if (['cancelled', 'refunded'].includes(s)) return 'badge-danger';
    if (['confirmed', 'processing'].includes(s)) return 'badge-warning';
    return 'badge-neutral';
  },

  /** Pulni bir xil formatda ko'rsatish. */
  money(value) {
    const n = Number(value || 0);
    const formatted = Math.round(n).toLocaleString('ru-RU');
    return this._lang === 'ru' ? `${formatted} сум` : `${formatted} so'm`;
  },

  number(value) {
    return Number(value || 0).toLocaleString('ru-RU');
  },

  /** Sahifadagi barcha data-i18n elementlarini tarjima qiladi. */
  apply(root = document) {
    root.querySelectorAll('[data-i18n]').forEach((el) => {
      el.textContent = this.t(el.getAttribute('data-i18n'));
    });
    root.querySelectorAll('[data-i18n-placeholder]').forEach((el) => {
      el.placeholder = this.t(el.getAttribute('data-i18n-placeholder'));
    });
    document.documentElement.lang = this._lang;
  },

  /** Tilni almashtiradi va sahifani qayta yuklaydi. */
  setLang(lang) {
    if (!this.dict[lang]) return;
    this._lang = lang;
    localStorage.setItem('admin_lang', lang);
    window.location.reload();
  },
};
