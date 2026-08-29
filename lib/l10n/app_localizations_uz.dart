// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Uzbek (`uz`).
class AppLocalizationsUz extends AppLocalizations {
  AppLocalizationsUz([String locale = 'uz']) : super(locale);

  @override
  String get appTitle => 'Milliy Metr';

  @override
  String get login => 'Kirish';

  @override
  String get sendOtp => 'SMS kodni yuborish';

  @override
  String get phoneNumber => 'Telefon raqami';

  @override
  String get welcomeTo => 'Milliy Metrga xush kelibsiz';

  @override
  String get or => 'YOKI';

  @override
  String get continueWithGoogle => 'Google orqali davom etish';

  @override
  String get continueWithApple => 'Apple orqali davom etish';

  @override
  String get verifyPhone => 'Telefonni tasdiqlash';

  @override
  String enterCode(Object phone) {
    return '$phone raqamiga yuborilgan 6 xonali kodni kiriting.';
  }

  @override
  String get verify => 'Tasdiqlash';

  @override
  String get searchHint => 'Qurilish materiallarini qidirish...';

  @override
  String get categories => 'Kategoriyalar';

  @override
  String get viewAll => 'Barchasini ko\'rish';

  @override
  String get featuredProducts => 'Tavsiya etilgan mahsulotlar';

  @override
  String get home => 'Bosh sahifa';

  @override
  String get catalog => 'Katalog';

  @override
  String get cart => 'Savat';

  @override
  String get profile => 'Profil';

  @override
  String get language => 'Til (Language)';

  @override
  String get selectLanguage => 'Tilni tanlang';

  @override
  String get systemLanguage => 'Tizim tili';

  @override
  String get orders => 'Buyurtmalar';

  @override
  String get wishlist => 'Sevimlilar';

  @override
  String get addresses => 'Manzillar';

  @override
  String get paymentMethods => 'To\'lov usullari';

  @override
  String get myReviews => 'Mening sharhlarim';

  @override
  String get notifications => 'Bildirishnomalar';

  @override
  String get securityAndPrivacy => 'Xavfsizlik va Maxfiylik';

  @override
  String get helpAndSupport => 'Yordam va Qo\'llab-quvvatlash';

  @override
  String get appearance => 'Ko\'rinish';

  @override
  String get themeSystem => 'Tizim bo\'yicha';

  @override
  String get themeLight => 'Yorug\'';

  @override
  String get themeDark => 'Qorong\'u';

  @override
  String get logout => 'Tizimdan chiqish';

  @override
  String get logoutConfirm => 'Haqiqatan ham tizimdan chiqmoqchimisiz?';

  @override
  String get cancel => 'Bekor qilish';

  @override
  String get exit => 'Chiqish';

  @override
  String get welcome => 'Xush kelibsiz!';

  @override
  String get loginToViewProfile =>
      'Profilni ko\'rish va barcha imkoniyatlardan foydalanish uchun tizimga kiring.';

  @override
  String get loginAction => 'Tizimga kirish';

  @override
  String get personalInfo => 'Shaxsiy ma\'lumotlar';

  @override
  String get user => 'Foydalanuvchi';

  @override
  String get invalidPhone => 'Iltimos, to\'g\'ri raqam kiriting';

  @override
  String socialLoginNotConfigured(Object provider) {
    return '$provider orqali tizimga kirish hozircha sozlanmagan.';
  }

  @override
  String get loginSubtitle => 'Milliy Metr hisobingizga kiring';

  @override
  String get registrationNotAvailable =>
      'Ro\'yxatdan o\'tish hozircha mavjud emas.';

  @override
  String get dontHaveAccount => 'Hisobingiz yo\'qmi?';

  @override
  String get register => 'Ro\'yxatdan o\'tish';

  @override
  String get invalidOtpLength => 'Iltimos, 6 xonali kodni kiriting';

  @override
  String get newOtpSent => 'Yangi kod yuborildi';

  @override
  String get verifyCodeTitle => 'Kodni tasdiqlash';

  @override
  String otpSentMessage(Object phone) {
    return 'Biz $phone raqamiga 6 xonali SMS kod yubordik. Iltimos, uni quyida kiriting.';
  }

  @override
  String get didNotReceiveCode => 'Kodni olmadingizmi?';

  @override
  String resendCodeIn(Object seconds) {
    return 'Qayta yuborish ($seconds s)';
  }

  @override
  String get resendCode => 'Qayta yuborish';

  @override
  String get specialOffers => 'Qaynoq takliflar';

  @override
  String get salesType => 'Sotuv turi';

  @override
  String get determineLocation => 'Manzilni aniqlash';

  @override
  String get deliveryAddress => 'Yetkazib berish manzili';

  @override
  String get pleaseAllowFromSettings => 'Iltimos, sozlamalardan ruxsat bering.';

  @override
  String get settings => 'Sozlamalar';

  @override
  String get tashkentUzbekistan => 'Toshkent, O‘zbekiston';

  @override
  String get errorLoadingProducts =>
      'Mahsulotlarni yuklashda xatolik yuz berdi.';

  @override
  String get retry => 'Qayta urinish';

  @override
  String get productNotFound => 'Mahsulot topilmadi';

  @override
  String get searchWithAnotherName =>
      'Boshqa nom yoki kategoriya bilan qidirib ko‘ring.';

  @override
  String get clearFilters => 'Filtrlarni tozalash';

  @override
  String get sort => 'Saralash';

  @override
  String get sortRecommended => 'Tavsiya etilgan';

  @override
  String get sortPriceAsc => 'Narx: pastdan yuqoriga';

  @override
  String get sortPriceDesc => 'Narx: yuqoridan pastga';

  @override
  String get sortNewest => 'Yangi mahsulotlar';

  @override
  String get sortRating => 'Reyting bo‘yicha';

  @override
  String get filter => 'Filtr';

  @override
  String get priceRange => 'Narx oralig\'i (so\'m)';

  @override
  String get priceLowToHigh => 'Narx: pastdan yuqoriga';

  @override
  String get priceHighToLow => 'Narx: yuqoridan pastga';

  @override
  String get fromPrice => 'Dan (so\'m)';

  @override
  String get toPrice => 'Gacha (so\'m)';

  @override
  String get currency => 'so\'m';

  @override
  String get region => 'Hudud';

  @override
  String get all => 'Barchasi';

  @override
  String get clear => 'Tozalash';

  @override
  String get showResults => 'Natijalarni ko‘rish';

  @override
  String productCount(Object count) {
    return '$count ta mahsulot';
  }

  @override
  String get errorLoadingProductDetails => 'Mahsulotni yuklab bo\'lmadi';

  @override
  String get newStatus => 'Yangi';

  @override
  String reviewsCount(Object count) {
    return '($count sharh)';
  }

  @override
  String get outOfStock => 'Mavjud emas';

  @override
  String inStock(Object stock, Object unit) {
    return 'Omborda: $stock $unit';
  }

  @override
  String get delivery => 'Yetkazib berish';

  @override
  String get tashkent => 'Toshkent';

  @override
  String get aboutProduct => 'Mahsulot haqida';

  @override
  String get showLess => 'Qisqartirish';

  @override
  String get showMore => 'Batafsil';

  @override
  String get specifications => 'Xususiyatlari';

  @override
  String get reviews => 'Sharhlar';

  @override
  String get viewAllReviews => 'Barcha sharhlarni ko\'rish';

  @override
  String get noReviewsYet => 'Bu mahsulot hali sharhlanmagan.';

  @override
  String get beFirstToReview =>
      'Mahsulotni xarid qilgan birinchi mijoz bo\'ling.';

  @override
  String reviewsCountLabel(Object count) {
    return '$count ta sharh';
  }

  @override
  String get buyToReview =>
      'Sharh qoldirish uchun ushbu mahsulotni xarid qiling.';

  @override
  String get editReview => 'Sharhni tahrirlash';

  @override
  String get leaveReview => 'Sharh qoldirish';

  @override
  String get inCart => 'Savatda';

  @override
  String get addToCart => 'Savatga qo\'shish';

  @override
  String get verifiedPurchase => 'Xarid qilingan';

  @override
  String get max5Photos => 'Maksimum 5 ta rasm yuklash mumkin';

  @override
  String get errorLoadingPhoto =>
      'Rasm yuklashda xatolik yuz berdi yoki ruxsat yo\'q';

  @override
  String get reviewSubmitted => 'Sharhingiz yuborildi';

  @override
  String get rateProduct => 'Baho bering';

  @override
  String get whatDidYouLike => 'Nimalar sizga yoqdi?';

  @override
  String get wouldYouBuyAgain => 'Bu mahsulotni yana xarid qilasizmi?';

  @override
  String get yes => 'Ha';

  @override
  String get no => 'Yo\'q';

  @override
  String get yourReview => 'Sharhingiz';

  @override
  String get writeReviewHint => 'Mahsulot haqida fikringizni yozing...';

  @override
  String get photos => 'Rasmlar';

  @override
  String get submitReview => 'Sharhni yuborish';

  @override
  String get ratingVeryBad => 'Juda yomon';

  @override
  String get ratingBad => 'Yomon';

  @override
  String get ratingAverage => 'O\'rtacha';

  @override
  String get ratingGood => 'Yaxshi';

  @override
  String get ratingExcellent => 'A\'lo';

  @override
  String get withPhotos => 'Rasmlar bilan';

  @override
  String get noReviewsAvailableYet => 'Hozircha sharhlar yo\'q';

  @override
  String get clearCartQuestion => 'Savatni tozalaysizmi?';

  @override
  String get clearCartWarning =>
      'Bu amal savatdagi barcha mahsulotlarni olib tashlaydi.';

  @override
  String get itemRemovedFromCart => 'Mahsulot savatdan olib tashlandi';

  @override
  String get undo => 'Qaytarish';

  @override
  String get clearCartTooltip => 'Savatni tozalash';

  @override
  String get cartEmpty => 'Savatingiz hozircha bo‘sh';

  @override
  String get cartEmptyDesc =>
      'Mahsulotlarni savatga qo‘shing va xaridingizni shu yerda boshqaring.';

  @override
  String get viewProducts => 'Mahsulotlarni ko‘rish';

  @override
  String get orderSummary => 'Buyurtma xulosasi';

  @override
  String get products => 'Mahsulotlar';

  @override
  String get discount => 'Chegirma';

  @override
  String get total => 'Jami';

  @override
  String get checkout => 'Rasmiylashtirish';

  @override
  String get someItemsOutOfStock => 'Ba\'zi mahsulotlar omborda yetarli emas.';

  @override
  String get errorLoadingCart => 'Savatni yuklab bo‘lmadi';

  @override
  String get checkInternetAndRetry =>
      'Internet aloqangizni tekshiring va qayta urinib ko‘ring.';

  @override
  String get selectAddress => 'Manzilni tanlang';

  @override
  String get chooseDestination => 'Manzilni tanlang';

  @override
  String get deliveryMethod => 'Yetkazib berish usuli';

  @override
  String get standardDelivery => 'Standart yetkazib berish';

  @override
  String get standardDeliveryDesc => '2-3 ish kuni';

  @override
  String get expressDelivery => 'Tezkor yetkazib berish';

  @override
  String get expressDeliveryDesc => 'Bugun yoki ertaga';

  @override
  String get pickup => 'Olib ketish';

  @override
  String get pickupDesc => 'Ombordan olib ketish';

  @override
  String get paymentMethod => 'To\'lov usuli';

  @override
  String get cashOnDelivery => 'Naqd pul bilan to\'lash';

  @override
  String get couponCode => 'Promokod';

  @override
  String get enterCouponCode => 'Promokodni kiriting';

  @override
  String get orderNotes => 'Buyurtma uchun izoh';

  @override
  String get subtotal => 'Mahsulotlar';

  @override
  String get shipping => 'Yetkazib berish';

  @override
  String get tax => 'Soliq';

  @override
  String get finalTotal => 'Jami summa';

  @override
  String get placingOrder => 'Buyurtma qabul qilinmoqda...';

  @override
  String get confirmOrder => 'Buyurtmani tasdiqlash';

  @override
  String get newest => 'Yangi qo‘shilgan';

  @override
  String get rating => 'Reyting';

  @override
  String get removedFromWishlist => 'Sevimlilardan olib tashlandi';

  @override
  String get searchInWishlist => 'Sevimlilardan qidirish';

  @override
  String get wishlistEmpty => 'Sevimli mahsulotlaringiz shu yerda';

  @override
  String get wishlistEmptyDesc =>
      'Yoqtirgan mahsulotlaringizni saqlang va keyinroq osongina toping.';

  @override
  String get noSuchProductFound => 'Bunday mahsulot topilmadi';

  @override
  String get tryChangingSearchWord => 'Qidiruv so‘zini o‘zgartirib ko‘ring';

  @override
  String get errorLoadingWishlist => 'Sevimlilarni yuklab bo‘lmadi';

  @override
  String get statusPending => 'Kutilmoqda';

  @override
  String get statusConfirmed => 'Tasdiqlangan';

  @override
  String get statusPacked => 'Qadoqlangan';

  @override
  String get statusShipped => 'Yuborilgan';

  @override
  String get statusDelivered => 'Yetkazib berilgan';

  @override
  String get statusCancelled => 'Bekor qilingan';

  @override
  String get myOrders => 'Mening buyurtmalarim';

  @override
  String get searchOrders => 'Buyurtmalarni qidirish';

  @override
  String get noOrdersFound => 'Buyurtmalar topilmadi';

  @override
  String orderNumberLabel(Object number) {
    return 'Buyurtma #$number';
  }

  @override
  String get status => 'Holati';

  @override
  String get orderDate => 'Buyurtma sanasi';

  @override
  String get trackingTimeline => 'Kuzatish holati';

  @override
  String get orderPlaced => 'Buyurtma qabul qilindi';

  @override
  String get processingShipped => 'Tayyorlanmoqda/Yuborilgan';

  @override
  String get items => 'Mahsulotlar';

  @override
  String get qty => 'Soni';

  @override
  String get paymentSummary => 'To\'lov ma\'lumotlari';

  @override
  String get requestRefund => 'Qaytarishni so\'rash';

  @override
  String get adminDashboard => 'Admin paneli';

  @override
  String get userMetrics => 'Foydalanuvchilar statistikasi';

  @override
  String get totalUsers => 'Jami foydalanuvchilar';

  @override
  String get activeUsers => 'Faol';

  @override
  String get marketplaceActivity => 'Bozor faolligi';

  @override
  String get revenue => 'Tushum';

  @override
  String get totalOrders => 'Buyurtmalar';

  @override
  String get totalProducts => 'Mahsulotlar';

  @override
  String get pendingActions => 'Kutilayotgan amallar';

  @override
  String get complaints => 'Shikoyatlar';

  @override
  String get salesOverview => 'Sotuvlar xulosasi';

  @override
  String get todaySales => 'Bugungi sotuv';

  @override
  String get totalSales => 'Jami sotuv';

  @override
  String get orderManagement => 'Buyurtmalarni boshqarish';

  @override
  String get pending => 'Kutilmoqda';

  @override
  String get completed => 'Tugallangan';

  @override
  String get cancelled => 'Bekor qilingan';

  @override
  String get inventoryStatus => 'Ombor holati';

  @override
  String get lowStock => 'Kam qolgan';

  @override
  String get fullName => 'To\'liq ism';

  @override
  String get email => 'Elektron pochta';

  @override
  String get phone => 'Telefon';

  @override
  String get save => 'Saqlash';

  @override
  String get editProfile => 'Profilni tahrirlash';

  @override
  String get profileUpdated => 'Profil yangilandi';

  @override
  String get enterFullName => 'Ismingizni kiriting';

  @override
  String get enterEmail => 'Elektron pochtangizni kiriting';

  @override
  String get changePassword => 'Parolni o\'zgartirish';

  @override
  String get currentPassword => 'Joriy parol';

  @override
  String get newPassword => 'Yangi parol';

  @override
  String get confirmPassword => 'Parolni tasdiqlash';

  @override
  String get biometricAuth => 'Biometrik autentifikatsiya';

  @override
  String get biometricAuthDesc => 'Barmoq izi yoki yuz tanish orqali kirish';

  @override
  String get twoFactorAuth => 'Ikki bosqichli tasdiqlash';

  @override
  String get twoFactorAuthDesc => 'Hisobingizni qo\'shimcha himoyalash';

  @override
  String get activeSessions => 'Faol seanslar';

  @override
  String get activeSessionsDesc => 'Tizimga kirgan qurilmalaringiz';

  @override
  String get deleteAccount => 'Hisobni o\'chirish';

  @override
  String get deleteAccountWarning =>
      'Bu amalni qaytarib bo\'lmaydi. Barcha ma\'lumotlaringiz o\'chiriladi.';

  @override
  String get deleteAccountConfirm =>
      'Haqiqatan ham hisobingizni o\'chirmoqchimisiz?';

  @override
  String get accountSecurity => 'Hisob xavfsizligi';

  @override
  String get privacySettings => 'Maxfiylik sozlamalari';

  @override
  String get dataPrivacy => 'Ma\'lumotlar maxfiyligi';

  @override
  String get passwordsDoNotMatch => 'Parollar mos kelmadi';

  @override
  String get passwordTooShort =>
      'Parol kamida 8 belgidan iborat bo\'lishi kerak';

  @override
  String get faq => 'Ko\'p so\'raladigan savollar';

  @override
  String get contactSupport => 'Qo\'llab-quvvatlash bilan bog\'lanish';

  @override
  String get callUs => 'Bizga qo\'ng\'iroq qiling';

  @override
  String get emailUs => 'Bizga yozing';

  @override
  String get telegram => 'Telegram';

  @override
  String get aboutApp => 'Ilova haqida';

  @override
  String get appVersion => 'Ilova versiyasi';

  @override
  String get faqDelivery => 'Yetkazib berish qancha vaqt oladi?';

  @override
  String get faqDeliveryAnswer =>
      'Standart yetkazib berish 2-3 ish kunini oladi. Tezkor yetkazib berish esa 1 kun ichida amalga oshiriladi.';

  @override
  String get faqPayment => 'Qanday to\'lov usullari mavjud?';

  @override
  String get faqPaymentAnswer =>
      'Hozirda naqd pul bilan to\'lov qabul qilinadi. Boshqa to\'lov usullari tez orada qo\'shiladi.';

  @override
  String get faqReturn => 'Mahsulotni qaytarish mumkinmi?';

  @override
  String get faqReturnAnswer =>
      'Ha, 14 kun ichida mahsulotni qaytarish mumkin. Mahsulot ishlatilmagan va original qadoqda bo\'lishi kerak.';

  @override
  String get faqWarranty => 'Kafolat mavjudmi?';

  @override
  String get faqWarrantyAnswer =>
      'Barcha mahsulotlarimiz ishlab chiqaruvchi kafolati bilan ta\'minlangan.';

  @override
  String get cashOnDeliveryDesc => 'Buyurtmani qabul qilganingizda to\'lang';

  @override
  String get clickPayment => 'Click orqali to\'lov';

  @override
  String get clickPaymentDesc => 'Click ilovasi orqali to\'lang';

  @override
  String get bankCard => 'Bank kartasi';

  @override
  String get bankCardDesc => 'Visa yoki Mastercard orqali to\'lang';

  @override
  String get paymentMethodSelected => 'To\'lov usuli tanlandi';

  @override
  String get defaultPayment => 'Asosiy';

  @override
  String get noReviewsWritten => 'Siz hali sharh yozmadingiz';

  @override
  String get noReviewsWrittenDesc =>
      'Xarid qilgan mahsulotlaringizga sharh qoldiring';

  @override
  String get notificationsEmpty => 'Hozircha yangi bildirishnomalar yo\'q';

  @override
  String get notificationsEmptyDesc => 'Yangi xabarlar shu yerda ko\'rinadi';

  @override
  String get markAllRead => 'Barchasini o\'qilgan deb belgilash';

  @override
  String get orderStatusChanged => 'Buyurtma holati o\'zgardi';

  @override
  String get newPromotion => 'Yangi aksiya';

  @override
  String get systemNotification => 'Tizim xabarnomasi';

  @override
  String get today => 'Bugun';

  @override
  String get yesterday => 'Kecha';

  @override
  String get earlier => 'Avvalgi';

  @override
  String get requiresBackendIntegration =>
      'Backend integratsiyasi talab qilinadi';

  @override
  String get featureAvailableSoon => 'Bu funksiya tez orada ishga tushiriladi';

  @override
  String get english => 'English';

  @override
  String get storeProducts => 'Do\'kon mahsulotlari';

  @override
  String get noProductsInStore => 'Bu do\'konda hozircha mahsulot yo\'q';

  @override
  String get platformSettings => 'Platforma sozlamalari';

  @override
  String get general => 'Umumiy';

  @override
  String get maintenanceMode => 'Texnik xizmat rejimi';

  @override
  String get maintenanceModeDesc => 'Ilovani vaqtincha o\'chirish';

  @override
  String get share => 'Ulashish';

  @override
  String get submitRequest => 'So\'rovni yuborish';

  @override
  String get refundReason => 'Qaytarish sababi';

  @override
  String get selectReason => 'Sababni tanlang';

  @override
  String get refundDescription => 'Tavsifni kiriting';

  @override
  String get refundSubmitted => 'Qaytarish so\'rovi yuborildi';

  @override
  String get addCard => 'Karta qo\'shish';

  @override
  String get cardNumber => 'Karta raqami';

  @override
  String get expiryDate => 'Amal qilish muddati';

  @override
  String get cvv => 'CVV';

  @override
  String get cardholderName => 'Karta egasining ismi';

  @override
  String payAmount(Object amount) {
    return '$amount to\'lash';
  }

  @override
  String get changeBtn => 'O\'zgartirish';

  @override
  String get editBtn => 'Tahrirlash';

  @override
  String get orderConfirmed => 'Buyurtma tasdiqlandi';

  @override
  String get paymentFailed => 'To\'lov amalga oshmadi';

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
  String get analyticsAndReports => 'Tahlil va hisobotlar';

  @override
  String get productSavedSuccessfully => 'Mahsulot muvaffaqiyatli saqlandi';

  @override
  String get startTypingToSearch => 'Qidirish uchun yozishni boshlang.';

  @override
  String get myProducts => 'Mening mahsulotlarim';

  @override
  String get noProductsAddedYet =>
      'Siz hali hech qanday mahsulot qo\'shmadingiz.';

  @override
  String get inStockOnly => 'Faqat mavjudlari';

  @override
  String get hasDiscount => 'Chegirmasi bor';

  @override
  String get wholesale => 'Ulgurji';

  @override
  String get retail => 'Chakana';

  @override
  String get applyFilters => 'Filtrlarni qo\'llash';

  @override
  String get registrationSubmitted => 'Ro\'yxatdan o\'tish yuborildi';

  @override
  String get orderDetails => 'Buyurtma tafsilotlari';

  @override
  String get verificationStatus => 'Tasdiqlash holati';

  @override
  String get storeProfileUpdated => 'Do\'kon profili yangilandi';

  @override
  String get manageStoreProfile => 'Do\'kon profilini boshqarish';

  @override
  String get personalizeYourFeed => 'Lentangizni moslashtirish';

  @override
  String get myAddresses => 'Mening manzillarim';

  @override
  String get noCategoriesAvailable => 'Kategoriyalar mavjud emas';

  @override
  String get buyNow => 'Hozir xarid qilish';

  @override
  String get addAddress => 'Manzil qo\'shish';

  @override
  String get addressLabel => 'Nomi (masalan, Uy, Ishxona)';

  @override
  String get district => 'Tuman';

  @override
  String get streetBuilding => 'Ko\'cha/Uy';

  @override
  String get saveAddress => 'Manzilni saqlash';

  @override
  String get fieldRequired => 'Majburiy';

  @override
  String get compareProducts => 'Mahsulotlarni taqqoslash';

  @override
  String get feature => 'Xususiyat';

  @override
  String get productA => 'Mahsulot A';

  @override
  String get productB => 'Mahsulot B';

  @override
  String get weight => 'Og\'irligi';

  @override
  String get grade => 'Markasi';

  @override
  String get store => 'Do\'kon';

  @override
  String get damagedItem => 'Shikastlangan mahsulot';

  @override
  String get wrongItem => 'Noto\'g\'ri mahsulot';

  @override
  String get lateDelivery => 'Kech yetkazib berish';

  @override
  String get invoice => 'Hisob-faktura';

  @override
  String get noReviewsYetStore => 'Hozircha sharhlar yo\'q.';

  @override
  String get accountNotFound => 'Bu raqam bilan hisob topilmadi';

  @override
  String get fillAllFields => 'Iltimos, barcha maydonlarni to\'ldiring';

  @override
  String get accountExists => 'Bu raqam allaqachon ro\'yxatdan o\'tgan';

  @override
  String get registrationSubtitle => 'Yangi hisob yarating';

  @override
  String get nameHint => 'Ismingizni kiriting';

  @override
  String get surnameHint => 'Familiyangizni kiriting';

  @override
  String get alreadyHaveAccount => 'Hisobingiz mavjudmi?';

  @override
  String get name => 'Ism';

  @override
  String get surname => 'Familiya';

  @override
  String get whatMaterials => 'Qanday materiallarni qidiryapsiz?';

  @override
  String get selectCategories =>
      'Tajribangizni moslashtirishimiz uchun sizni qiziqtirgan kategoriyalarni tanlang.';

  @override
  String get continueAction => 'Davom etish';

  @override
  String get categoryCement => 'Sement va Qorishma';

  @override
  String get categoryBricks => 'G\'isht va Bloklar';

  @override
  String get categorySteel => 'Armatura';

  @override
  String get categorySand => 'Qum va Shag\'al';

  @override
  String get categoryConcrete => 'Beton';

  @override
  String get categoryRoofing => 'Tom yopish materiallari';

  @override
  String get categoryWood => 'Yog\'och va Fanera';

  @override
  String get categoryPlumbing => 'Santexnika va Qvurlar';

  @override
  String get categoryElectrical => 'Elektr materiallari';

  @override
  String get categoryPaint => 'Bo\'yoq va Pardozlash';

  @override
  String get authRequiredToContinue =>
      'Buyurtmani davom ettirish uchun tizimga kiring.';

  @override
  String get onboardingTitle => 'Barcha Qurilish Materiallari Bitta Joyda';

  @override
  String get onboardingSubtitle =>
      'Sement, g\'isht va po\'latni ishonchli yetkazib beruvchilardan ulgurji narxlarda xarid qiling.';

  @override
  String get getStarted => 'Boshlash';

  @override
  String get errorOccurred => 'Xatolik yuz berdi';

  @override
  String get categoriesNotFound => 'Kategoriyalar topilmadi';

  @override
  String get piece => 'dona';

  @override
  String get guestModeTitle => 'Tizimga kiring';

  @override
  String get guestCartDesc => 'Savatchani ko\'rish uchun tizimga kiring.';

  @override
  String get guestWishlistDesc => 'Sevimlilarni ko\'rish uchun tizimga kiring.';

  @override
  String get discountsChip => 'Aksiyalar';

  @override
  String get expressDeliveryChip => 'Tezkor yetkazish';

  @override
  String get directFactoryChip => 'To\'g\'ridan-to\'g\'ri zavoddan';

  @override
  String get popularChip => 'Ommabop';

  @override
  String get servicesChip => 'Usta xizmati';

  @override
  String get qualityGuaranteeBadge => '100% Sifat kafolati';

  @override
  String get fastDeliveryBadge => 'Tezkor yetkazib berish';

  @override
  String get securePaymentBadge => 'Xavfsiz to\'lov';

  @override
  String get orderStatusAll => 'Barchasi';

  @override
  String get orderStatusPending => 'Kutilmoqda';

  @override
  String get orderStatusConfirmed => 'Tasdiqlangan';

  @override
  String get orderStatusProcessing => 'Jarayonda';

  @override
  String get orderStatusDelivered => 'Yetkazildi';

  @override
  String get orderStatusCancelled => 'Bekor qilingan';

  @override
  String get addedToCart => 'Savatga qo\'shildi';

  @override
  String get promoBannerTitle => 'Qurilish uchun kerakli';

  @override
  String get promoBannerSubtitle => 'Eng yaxshi narxlar kafolati';

  @override
  String get promoBannerButton => 'Xarid qilish';

  @override
  String get popularProductsSection => 'Ommabop mahsulotlar';

  @override
  String get recentSearches => 'So\'nggi qidiruvlar';

  @override
  String get bulkDiscount => '10+ dona olinsa: 5% chegirma';

  @override
  String get specificationsLabel => 'Xususiyatlari';

  @override
  String get warranty => 'Kafolat';

  @override
  String get manufacturer => 'Ishlab chiqaruvchi';

  @override
  String get deliveryLabel => 'Yetkazib berish';

  @override
  String get leaveReviewBtn => 'Sharh qoldirish';

  @override
  String get buyNowBtn => 'Hozir xarid qilish';

  @override
  String get taxFee => 'Soliq / Yig\'im';

  @override
  String get deliveryService => 'Yetkazib berish xizmati';

  @override
  String get pickupFromWarehouse => 'Ombordan o\'zi olib ketish';

  @override
  String get smsVerification => 'SMS Tasdiqlash';

  @override
  String get smsVerificationDesc =>
      'Ikki bosqichli autentifikatsiyani yoqish uchun telefon raqamingizga SMS kod yuboriladi. Davom etishni xohlaysizmi?';

  @override
  String get continueBtn => 'Davom etish';

  @override
  String get thisDevice => 'Ushbu qurilma:';

  @override
  String get activeSession => 'Faol seans';

  @override
  String get sendErrorReports => 'Xatolik hisobotlarini yuborish';

  @override
  String get sendErrorReportsDesc =>
      'Ilovani yaxshilash uchun anonim xatolik ma\'lumotlarini yuborish.';

  @override
  String get createAdProfile => 'Reklama profilini yaratish';

  @override
  String get createAdProfileDesc =>
      'Sizga moslashtirilgan reklamalarni ko\'rsatish uchun.';

  @override
  String get contactViaTelegram => 'Telegram orqali bog\'lanish';

  @override
  String get ourInstagramPage => 'Instagram sahifamiz';

  @override
  String get customerSupport => 'Mijozlarni qo\'llab-quvvatlash';

  @override
  String get privacyPolicy => 'Maxfiylik siyosati';

  @override
  String get termsOfUse => 'Foydalanish shartlari';

  @override
  String get brandDefault => 'Brend kiritilmagan';
}
