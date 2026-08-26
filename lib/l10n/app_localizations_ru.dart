// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Milliy Metr';

  @override
  String get login => 'Войти';

  @override
  String get sendOtp => 'Отправить SMS код';

  @override
  String get phoneNumber => 'Номер телефона';

  @override
  String get welcomeTo => 'Добро пожаловать в Milliy Metr';

  @override
  String get or => 'ИЛИ';

  @override
  String get continueWithGoogle => 'Продолжить с Google';

  @override
  String get continueWithApple => 'Продолжить с Apple';

  @override
  String get verifyPhone => 'Подтверждение телефона';

  @override
  String enterCode(Object phone) {
    return 'Введите 6-значный код, отправленный на номер $phone.';
  }

  @override
  String get verify => 'Подтвердить';

  @override
  String get searchHint => 'Поиск строительных материалов...';

  @override
  String get categories => 'Категории';

  @override
  String get viewAll => 'Смотреть все';

  @override
  String get featuredProducts => 'Рекомендуемые товары';

  @override
  String get home => 'Главная';

  @override
  String get catalog => 'Каталог';

  @override
  String get cart => 'Корзина';

  @override
  String get profile => 'Профиль';

  @override
  String get language => 'Язык (Language)';

  @override
  String get selectLanguage => 'Выберите язык';

  @override
  String get systemLanguage => 'Системный язык';

  @override
  String get orders => 'Заказы';

  @override
  String get wishlist => 'Избранное';

  @override
  String get addresses => 'Адреса';

  @override
  String get paymentMethods => 'Способы оплаты';

  @override
  String get myReviews => 'Мои отзывы';

  @override
  String get notifications => 'Уведомления';

  @override
  String get securityAndPrivacy => 'Безопасность и конфиденциальность';

  @override
  String get helpAndSupport => 'Помощь и поддержка';

  @override
  String get appearance => 'Внешний вид';

  @override
  String get themeSystem => 'Системная';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Темная';

  @override
  String get logout => 'Выйти';

  @override
  String get logoutConfirm => 'Вы действительно хотите выйти из системы?';

  @override
  String get cancel => 'Отмена';

  @override
  String get exit => 'Выход';

  @override
  String get welcome => 'Добро пожаловать!';

  @override
  String get loginToViewProfile =>
      'Войдите в систему, чтобы просматривать профиль и использовать все возможности.';

  @override
  String get loginAction => 'Войти в систему';

  @override
  String get personalInfo => 'Личные данные';

  @override
  String get user => 'Пользователь';

  @override
  String get invalidPhone => 'Пожалуйста, введите правильный номер';

  @override
  String socialLoginNotConfigured(Object provider) {
    return 'Вход через $provider пока не настроен.';
  }

  @override
  String get loginSubtitle => 'Войдите в аккаунт Milliy Metr';

  @override
  String get registrationNotAvailable => 'Регистрация пока недоступна.';

  @override
  String get dontHaveAccount => 'Нет аккаунта?';

  @override
  String get register => 'Зарегистрироваться';

  @override
  String get invalidOtpLength => 'Пожалуйста, введите 6-значный код';

  @override
  String get newOtpSent => 'Новый код отправлен';

  @override
  String get verifyCodeTitle => 'Подтверждение кода';

  @override
  String otpSentMessage(Object phone) {
    return 'Мы отправили 6-значный SMS-код на номер $phone. Пожалуйста, введите его ниже.';
  }

  @override
  String get didNotReceiveCode => 'Не получили код?';

  @override
  String resendCodeIn(Object seconds) {
    return 'Отправить снова ($seconds с)';
  }

  @override
  String get resendCode => 'Отправить снова';

  @override
  String get specialOffers => 'Специальные предложения';

  @override
  String get searchPlaceholder => 'Поиск';

  @override
  String get salesType => 'Тип продажи';

  @override
  String get determineLocation => 'Определить местоположение';

  @override
  String get deliveryAddress => 'Адрес доставки';

  @override
  String get pleaseAllowFromSettings => 'Пожалуйста, разрешите в настройках.';

  @override
  String get settings => 'Настройки';

  @override
  String get tashkentUzbekistan => 'Ташкент, Узбекистан';

  @override
  String get errorLoadingProducts => 'Ошибка при загрузке продуктов.';

  @override
  String get retry => 'Повторить попытку';

  @override
  String get productNotFound => 'Продукт не найден';

  @override
  String get searchWithAnotherName =>
      'Попробуйте поискать с другим названием или категорией.';

  @override
  String get clearFilters => 'Очистить фильтры';

  @override
  String get sort => 'Сортировка';

  @override
  String get sortRecommended => 'Рекомендуемые';

  @override
  String get sortPriceAsc => 'Цена: по возрастанию';

  @override
  String get sortPriceDesc => 'Цена: по убыванию';

  @override
  String get sortNewest => 'Новинки';

  @override
  String get sortRating => 'По рейтингу';

  @override
  String get filter => 'Фильтр';

  @override
  String get priceRange => 'Диапазон цен (UZS)';

  @override
  String get region => 'Регион';

  @override
  String get all => 'Все';

  @override
  String get clear => 'Очистить';

  @override
  String get showResults => 'Показать результаты';

  @override
  String productCount(Object count) {
    return '$count товаров';
  }

  @override
  String get errorLoadingProductDetails => 'Ошибка при загрузке товара';

  @override
  String get newStatus => 'Новый';

  @override
  String reviewsCount(Object count) {
    return '($count отзывов)';
  }

  @override
  String get outOfStock => 'Нет в наличии';

  @override
  String inStock(Object stock, Object unit) {
    return 'В наличии: $stock $unit';
  }

  @override
  String get delivery => 'Доставка';

  @override
  String get tashkent => 'Ташкент';

  @override
  String get aboutProduct => 'О товаре';

  @override
  String get showLess => 'Свернуть';

  @override
  String get showMore => 'Подробнее';

  @override
  String get specifications => 'Характеристики';

  @override
  String get reviews => 'Отзывы';

  @override
  String get viewAllReviews => 'Смотреть все отзывы';

  @override
  String get noReviewsYet => 'У этого товара пока нет отзывов.';

  @override
  String get beFirstToReview => 'Станьте первым покупателем, оставившим отзыв.';

  @override
  String reviewsCountLabel(Object count) {
    return '$count отзывов';
  }

  @override
  String get buyToReview => 'Купите этот товар, чтобы оставить отзыв.';

  @override
  String get editReview => 'Редактировать отзыв';

  @override
  String get leaveReview => 'Оставить отзыв';

  @override
  String get inCart => 'В корзине';

  @override
  String get addToCart => 'В корзину';

  @override
  String get verifiedPurchase => 'Купленный товар';

  @override
  String get max5Photos => 'Можно загрузить максимум 5 фотографий';

  @override
  String get errorLoadingPhoto => 'Ошибка при загрузке фото или нет разрешения';

  @override
  String get reviewSubmitted => 'Ваш отзыв отправлен';

  @override
  String get rateProduct => 'Оцените товар';

  @override
  String get whatDidYouLike => 'Что вам понравилось?';

  @override
  String get wouldYouBuyAgain => 'Купили бы вы этот товар снова?';

  @override
  String get yes => 'Да';

  @override
  String get no => 'Нет';

  @override
  String get yourReview => 'Ваш отзыв';

  @override
  String get writeReviewHint => 'Напишите ваше мнение о товаре...';

  @override
  String get photos => 'Фотографии';

  @override
  String get submitReview => 'Отправить отзыв';

  @override
  String get ratingVeryBad => 'Очень плохо';

  @override
  String get ratingBad => 'Плохо';

  @override
  String get ratingAverage => 'Нормально';

  @override
  String get ratingGood => 'Хорошо';

  @override
  String get ratingExcellent => 'Отлично';

  @override
  String get withPhotos => 'С фотографиями';

  @override
  String get noReviewsAvailableYet => 'Пока нет отзывов';

  @override
  String get clearCartQuestion => 'Очистить корзину?';

  @override
  String get clearCartWarning => 'Это действие удалит все товары из корзины.';

  @override
  String get itemRemovedFromCart => 'Товар удален из корзины';

  @override
  String get undo => 'Отменить';

  @override
  String get clearCartTooltip => 'Очистить корзину';

  @override
  String get cartEmpty => 'Ваша корзина пока пуста';

  @override
  String get cartEmptyDesc =>
      'Добавьте товары в корзину и управляйте покупками здесь.';

  @override
  String get viewProducts => 'Смотреть товары';

  @override
  String get orderSummary => 'Итог заказа';

  @override
  String get products => 'Товары';

  @override
  String get discount => 'Скидка';

  @override
  String get total => 'Итого';

  @override
  String get checkout => 'Оформить';

  @override
  String get someItemsOutOfStock => 'Некоторых товаров недостаточно на складе.';

  @override
  String get errorLoadingCart => 'Ошибка при загрузке корзины';

  @override
  String get checkInternetAndRetry =>
      'Проверьте интернет-соединение и повторите попытку.';

  @override
  String get selectAddress => 'Выберите адрес';

  @override
  String get chooseDestination => 'Выберите место назначения';

  @override
  String get deliveryMethod => 'Способ доставки';

  @override
  String get standardDelivery => 'Стандартная доставка';

  @override
  String get standardDeliveryDesc => '2-3 рабочих дня';

  @override
  String get expressDelivery => 'Экспресс-доставка';

  @override
  String get expressDeliveryDesc => 'Сегодня или завтра';

  @override
  String get pickup => 'Самовывоз';

  @override
  String get pickupDesc => 'Забрать со склада';

  @override
  String get paymentMethod => 'Способ оплаты';

  @override
  String get cashOnDelivery => 'Оплата при получении';

  @override
  String get couponCode => 'Промокод';

  @override
  String get enterCouponCode => 'Введите промокод';

  @override
  String get orderNotes => 'Комментарий к заказу';

  @override
  String get subtotal => 'Сумма';

  @override
  String get shipping => 'Доставка';

  @override
  String get tax => 'Налог';

  @override
  String get finalTotal => 'Итого';

  @override
  String get placingOrder => 'Оформление заказа...';

  @override
  String get confirmOrder => 'Подтвердить заказ';

  @override
  String get newest => 'Сначала новые';

  @override
  String get priceLowToHigh => 'Сначала дешевые';

  @override
  String get priceHighToLow => 'Сначала дорогие';

  @override
  String get rating => 'По рейтингу';

  @override
  String get removedFromWishlist => 'Удалено из избранного';

  @override
  String get searchInWishlist => 'Поиск в избранном';

  @override
  String get wishlistEmpty => 'Здесь будут ваши избранные товары';

  @override
  String get wishlistEmptyDesc =>
      'Сохраняйте понравившиеся товары, чтобы легко найти их позже.';

  @override
  String get noSuchProductFound => 'Такой товар не найден';

  @override
  String get tryChangingSearchWord => 'Попробуйте изменить поисковой запрос';

  @override
  String get errorLoadingWishlist => 'Ошибка при загрузке избранного';

  @override
  String get statusPending => 'Ожидается';

  @override
  String get statusConfirmed => 'Подтвержден';

  @override
  String get statusPacked => 'Упакован';

  @override
  String get statusShipped => 'Отправлен';

  @override
  String get statusDelivered => 'Доставлен';

  @override
  String get statusCancelled => 'Отменен';

  @override
  String get myOrders => 'Мои заказы';

  @override
  String get searchOrders => 'Поиск заказов';

  @override
  String get noOrdersFound => 'Заказы не найдены';

  @override
  String orderNumberLabel(Object number) {
    return 'Заказ #$number';
  }

  @override
  String get status => 'Статус';

  @override
  String get orderDate => 'Дата заказа';

  @override
  String get trackingTimeline => 'Отслеживание';

  @override
  String get orderPlaced => 'Заказ оформлен';

  @override
  String get processingShipped => 'Обработка/Отправлен';

  @override
  String get items => 'Товары';

  @override
  String get qty => 'Кол-во';

  @override
  String get paymentSummary => 'Информация об оплате';

  @override
  String get requestRefund => 'Запросить возврат';

  @override
  String get adminDashboard => 'Панель администратора';

  @override
  String get userMetrics => 'Статистика пользователей';

  @override
  String get totalUsers => 'Всего пользователей';

  @override
  String get activeUsers => 'Активные';

  @override
  String get marketplaceActivity => 'Активность маркетплейса';

  @override
  String get revenue => 'Доход';

  @override
  String get totalOrders => 'Заказы';

  @override
  String get totalProducts => 'Товары';

  @override
  String get pendingActions => 'Ожидающие действия';

  @override
  String get complaints => 'Жалобы';

  @override
  String get salesOverview => 'Обзор продаж';

  @override
  String get todaySales => 'Продажи за сегодня';

  @override
  String get totalSales => 'Всего продаж';

  @override
  String get orderManagement => 'Управление заказами';

  @override
  String get pending => 'В ожидании';

  @override
  String get completed => 'Завершено';

  @override
  String get cancelled => 'Отменено';

  @override
  String get inventoryStatus => 'Состояние склада';

  @override
  String get lowStock => 'Заканчивается';

  @override
  String get fullName => 'Полное имя';

  @override
  String get email => 'Электронная почта';

  @override
  String get phone => 'Телефон';

  @override
  String get save => 'Сохранить';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get profileUpdated => 'Профиль обновлён';

  @override
  String get enterFullName => 'Введите ваше имя';

  @override
  String get enterEmail => 'Введите электронную почту';

  @override
  String get changePassword => 'Изменить пароль';

  @override
  String get currentPassword => 'Текущий пароль';

  @override
  String get newPassword => 'Новый пароль';

  @override
  String get confirmPassword => 'Подтвердите пароль';

  @override
  String get biometricAuth => 'Биометрическая аутентификация';

  @override
  String get biometricAuthDesc =>
      'Вход по отпечатку пальца или распознаванию лица';

  @override
  String get twoFactorAuth => 'Двухфакторная аутентификация';

  @override
  String get twoFactorAuthDesc => 'Дополнительная защита вашего аккаунта';

  @override
  String get activeSessions => 'Активные сеансы';

  @override
  String get activeSessionsDesc => 'Устройства, с которых выполнен вход';

  @override
  String get deleteAccount => 'Удалить аккаунт';

  @override
  String get deleteAccountWarning =>
      'Это действие необратимо. Все ваши данные будут удалены.';

  @override
  String get deleteAccountConfirm => 'Вы действительно хотите удалить аккаунт?';

  @override
  String get accountSecurity => 'Безопасность аккаунта';

  @override
  String get privacySettings => 'Настройки конфиденциальности';

  @override
  String get dataPrivacy => 'Конфиденциальность данных';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают';

  @override
  String get passwordTooShort => 'Пароль должен содержать не менее 8 символов';

  @override
  String get faq => 'Часто задаваемые вопросы';

  @override
  String get contactSupport => 'Связаться с поддержкой';

  @override
  String get callUs => 'Позвоните нам';

  @override
  String get emailUs => 'Напишите нам';

  @override
  String get telegram => 'Telegram';

  @override
  String get aboutApp => 'О приложении';

  @override
  String get appVersion => 'Версия приложения';

  @override
  String get faqDelivery => 'Сколько времени занимает доставка?';

  @override
  String get faqDeliveryAnswer =>
      'Стандартная доставка занимает 2-3 рабочих дня. Экспресс-доставка осуществляется в течение 1 дня.';

  @override
  String get faqPayment => 'Какие способы оплаты доступны?';

  @override
  String get faqPaymentAnswer =>
      'В настоящее время принимается оплата наличными при получении. Другие способы оплаты будут добавлены в ближайшее время.';

  @override
  String get faqReturn => 'Можно ли вернуть товар?';

  @override
  String get faqReturnAnswer =>
      'Да, товар можно вернуть в течение 14 дней. Товар должен быть неиспользованным и в оригинальной упаковке.';

  @override
  String get faqWarranty => 'Есть ли гарантия?';

  @override
  String get faqWarrantyAnswer =>
      'Все наши товары обеспечены гарантией производителя.';

  @override
  String get cashOnDeliveryDesc => 'Оплата при получении заказа';

  @override
  String get clickPayment => 'Оплата через Click';

  @override
  String get clickPaymentDesc => 'Оплата через приложение Click';

  @override
  String get bankCard => 'Банковская карта';

  @override
  String get bankCardDesc => 'Оплата картой Visa или Mastercard';

  @override
  String get paymentMethodSelected => 'Способ оплаты выбран';

  @override
  String get defaultPayment => 'Основной';

  @override
  String get noReviewsWritten => 'Вы ещё не написали отзывов';

  @override
  String get noReviewsWrittenDesc => 'Оставьте отзыв на купленные товары';

  @override
  String get notificationsEmpty => 'Пока нет новых уведомлений';

  @override
  String get notificationsEmptyDesc => 'Новые сообщения появятся здесь';

  @override
  String get markAllRead => 'Отметить все как прочитанные';

  @override
  String get orderStatusChanged => 'Статус заказа изменён';

  @override
  String get newPromotion => 'Новая акция';

  @override
  String get systemNotification => 'Системное уведомление';

  @override
  String get today => 'Сегодня';

  @override
  String get yesterday => 'Вчера';

  @override
  String get earlier => 'Ранее';

  @override
  String get requiresBackendIntegration => 'Требуется интеграция с сервером';

  @override
  String get featureAvailableSoon => 'Эта функция скоро будет доступна';

  @override
  String get english => 'English';

  @override
  String get storeProducts => 'Товары магазина';

  @override
  String get noProductsInStore => 'В этом магазине пока нет товаров';

  @override
  String get platformSettings => 'Настройки платформы';

  @override
  String get general => 'Общие';

  @override
  String get maintenanceMode => 'Режим обслуживания';

  @override
  String get maintenanceModeDesc => 'Временное отключение приложения';

  @override
  String get share => 'Поделиться';

  @override
  String get submitRequest => 'Отправить заявку';

  @override
  String get refundReason => 'Причина возврата';

  @override
  String get selectReason => 'Выберите причину';

  @override
  String get refundDescription => 'Введите описание';

  @override
  String get refundSubmitted => 'Заявка на возврат отправлена';

  @override
  String get addCard => 'Добавить карту';

  @override
  String get cardNumber => 'Номер карты';

  @override
  String get expiryDate => 'Срок действия';

  @override
  String get cvv => 'CVV';

  @override
  String get cardholderName => 'Имя владельца карты';

  @override
  String payAmount(Object amount) {
    return 'Оплатить $amount';
  }

  @override
  String get changeBtn => 'Изменить';

  @override
  String get editBtn => 'Редактировать';

  @override
  String get orderConfirmed => 'Заказ подтвержден';

  @override
  String get paymentFailed => 'Оплата не прошла';

  @override
  String get payme => 'Payme';

  @override
  String get visa => 'Visa';

  @override
  String get mastercard => 'Mastercard';

  @override
  String get uzcard => 'Uzcard';

  @override
  String get humo => 'Humo';

  @override
  String get analyticsAndReports => 'Аналитика и отчеты';

  @override
  String get productSavedSuccessfully => 'Продукт успешно сохранен';

  @override
  String get startTypingToSearch => 'Начните вводить текст для поиска.';

  @override
  String get myProducts => 'Мои продукты';

  @override
  String get noProductsAddedYet => 'Вы еще не добавили ни одного продукта.';

  @override
  String get inStockOnly => 'Только в наличии';

  @override
  String get hasDiscount => 'Со скидкой';

  @override
  String get wholesale => 'Оптом';

  @override
  String get retail => 'В розницу';

  @override
  String get applyFilters => 'Применить фильтры';

  @override
  String get registrationSubmitted => 'Регистрация отправлена';

  @override
  String get orderDetails => 'Детали заказа';

  @override
  String get verificationStatus => 'Статус верификации';

  @override
  String get storeProfileUpdated => 'Профиль магазина обновлен';

  @override
  String get manageStoreProfile => 'Управление профилем магазина';

  @override
  String get personalizeYourFeed => 'Персонализация ленты';

  @override
  String get myAddresses => 'Мои адреса';

  @override
  String get noCategoriesAvailable => 'Категории недоступны';

  @override
  String get buyNow => 'Купить сейчас';

  @override
  String get addAddress => 'Добавить адрес';

  @override
  String get addressLabel => 'Название (например, Дом, Офис)';

  @override
  String get district => 'Район';

  @override
  String get streetBuilding => 'Улица/Дом';

  @override
  String get saveAddress => 'Сохранить адрес';

  @override
  String get fieldRequired => 'Обязательно';

  @override
  String get compareProducts => 'Сравнить продукты';

  @override
  String get feature => 'Характеристика';

  @override
  String get productA => 'Продукт A';

  @override
  String get productB => 'Продукт B';

  @override
  String get weight => 'Вес';

  @override
  String get grade => 'Марка';

  @override
  String get store => 'Магазин';

  @override
  String get damagedItem => 'Поврежденный товар';

  @override
  String get wrongItem => 'Не тот товар';

  @override
  String get lateDelivery => 'Поздняя доставка';

  @override
  String get invoice => 'Счет-фактура';

  @override
  String get noReviewsYetStore => 'Пока нет отзывов.';

  @override
  String get accountNotFound => 'Аккаунт с этим номером не найден';

  @override
  String get fillAllFields => 'Пожалуйста, заполните все поля';

  @override
  String get accountExists => 'Этот номер уже зарегистрирован';

  @override
  String get registrationSubtitle => 'Создайте новый аккаунт';

  @override
  String get nameHint => 'Введите ваше имя';

  @override
  String get surnameHint => 'Введите вашу фамилию';

  @override
  String get alreadyHaveAccount => 'У вас уже есть аккаунт?';

  @override
  String get name => 'Имя';

  @override
  String get surname => 'Фамилия';

  @override
  String get whatMaterials => 'Какие материалы вы ищете?';

  @override
  String get selectCategories =>
      'Выберите интересующие вас категории, чтобы мы могли персонализировать вашу ленту.';

  @override
  String get continueAction => 'Продолжить';

  @override
  String get categoryCement => 'Цемент и раствор';

  @override
  String get categoryBricks => 'Кирпичи и блоки';

  @override
  String get categorySteel => 'Арматура';

  @override
  String get categorySand => 'Песок и гравий';

  @override
  String get categoryConcrete => 'Бетон';

  @override
  String get categoryRoofing => 'Кровельные материалы';

  @override
  String get categoryWood => 'Дерево и фанера';

  @override
  String get categoryPlumbing => 'Сантехника и трубы';

  @override
  String get categoryElectrical => 'Электрические материалы';

  @override
  String get categoryPaint => 'Краска и отделка';

  @override
  String get authRequiredToContinue =>
      'Войдите в аккаунт, чтобы продолжить оформление заказа.';

  @override
  String get onboardingTitle => 'Все Строительные Материалы в Одном Месте';

  @override
  String get onboardingSubtitle =>
      'Покупайте цемент, кирпичи и сталь у проверенных поставщиков по оптовым ценам.';

  @override
  String get getStarted => 'Начать';

  @override
  String get errorOccurred => 'Произошла ошибка';

  @override
  String get categoriesNotFound => 'Категории не найдены';

  @override
  String get piece => 'шт';

  @override
  String get guestModeTitle => 'Войдите в систему';

  @override
  String get guestCartDesc => 'Войдите, чтобы просмотреть корзину.';

  @override
  String get guestWishlistDesc =>
      'Войдите, чтобы просмотреть избранные товары.';

  @override
  String get discountsChip => 'Скидки';

  @override
  String get expressDeliveryChip => 'Быстрая доставка';

  @override
  String get directFactoryChip => 'Напрямую с завода';

  @override
  String get popularChip => 'Популярное';

  @override
  String get servicesChip => 'Услуги мастеров';

  @override
  String get qualityGuaranteeBadge => '100% Гарантия качества';

  @override
  String get fastDeliveryBadge => 'Быстрая доставка';

  @override
  String get securePaymentBadge => 'Безопасная оплата';

  @override
  String get orderStatusAll => 'Все';

  @override
  String get orderStatusPending => 'В ожидании';

  @override
  String get orderStatusConfirmed => 'Подтвержден';

  @override
  String get orderStatusProcessing => 'В обработке';

  @override
  String get orderStatusDelivered => 'Доставлен';

  @override
  String get orderStatusCancelled => 'Отменен';
}
