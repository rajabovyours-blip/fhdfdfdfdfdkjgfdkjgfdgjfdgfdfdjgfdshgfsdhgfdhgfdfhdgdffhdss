import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_uz.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
    Locale('uz')
  ];

  /// No description provided for @appTitle.
  ///
  /// In uz, this message translates to:
  /// **'Milliy Metr'**
  String get appTitle;

  /// No description provided for @login.
  ///
  /// In uz, this message translates to:
  /// **'Kirish'**
  String get login;

  /// No description provided for @sendOtp.
  ///
  /// In uz, this message translates to:
  /// **'SMS kodni yuborish'**
  String get sendOtp;

  /// No description provided for @phoneNumber.
  ///
  /// In uz, this message translates to:
  /// **'Telefon raqami'**
  String get phoneNumber;

  /// No description provided for @welcomeTo.
  ///
  /// In uz, this message translates to:
  /// **'Milliy Metrga xush kelibsiz'**
  String get welcomeTo;

  /// No description provided for @or.
  ///
  /// In uz, this message translates to:
  /// **'YOKI'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In uz, this message translates to:
  /// **'Google orqali davom etish'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In uz, this message translates to:
  /// **'Apple orqali davom etish'**
  String get continueWithApple;

  /// No description provided for @verifyPhone.
  ///
  /// In uz, this message translates to:
  /// **'Telefonni tasdiqlash'**
  String get verifyPhone;

  /// No description provided for @enterCode.
  ///
  /// In uz, this message translates to:
  /// **'{phone} raqamiga yuborilgan 6 xonali kodni kiriting.'**
  String enterCode(Object phone);

  /// No description provided for @verify.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash'**
  String get verify;

  /// No description provided for @searchHint.
  ///
  /// In uz, this message translates to:
  /// **'Qurilish materiallarini qidirish...'**
  String get searchHint;

  /// No description provided for @categories.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyalar'**
  String get categories;

  /// No description provided for @viewAll.
  ///
  /// In uz, this message translates to:
  /// **'Barchasini ko\'rish'**
  String get viewAll;

  /// No description provided for @featuredProducts.
  ///
  /// In uz, this message translates to:
  /// **'Tavsiya etilgan mahsulotlar'**
  String get featuredProducts;

  /// No description provided for @home.
  ///
  /// In uz, this message translates to:
  /// **'Bosh sahifa'**
  String get home;

  /// No description provided for @catalog.
  ///
  /// In uz, this message translates to:
  /// **'Katalog'**
  String get catalog;

  /// No description provided for @cart.
  ///
  /// In uz, this message translates to:
  /// **'Savat'**
  String get cart;

  /// No description provided for @profile.
  ///
  /// In uz, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @language.
  ///
  /// In uz, this message translates to:
  /// **'Til (Language)'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Tilni tanlang'**
  String get selectLanguage;

  /// No description provided for @systemLanguage.
  ///
  /// In uz, this message translates to:
  /// **'Tizim tili'**
  String get systemLanguage;

  /// No description provided for @orders.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalar'**
  String get orders;

  /// No description provided for @wishlist.
  ///
  /// In uz, this message translates to:
  /// **'Sevimlilar'**
  String get wishlist;

  /// No description provided for @addresses.
  ///
  /// In uz, this message translates to:
  /// **'Manzillar'**
  String get addresses;

  /// No description provided for @paymentMethods.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov usullari'**
  String get paymentMethods;

  /// No description provided for @myReviews.
  ///
  /// In uz, this message translates to:
  /// **'Mening sharhlarim'**
  String get myReviews;

  /// No description provided for @notifications.
  ///
  /// In uz, this message translates to:
  /// **'Bildirishnomalar'**
  String get notifications;

  /// No description provided for @securityAndPrivacy.
  ///
  /// In uz, this message translates to:
  /// **'Xavfsizlik va Maxfiylik'**
  String get securityAndPrivacy;

  /// No description provided for @helpAndSupport.
  ///
  /// In uz, this message translates to:
  /// **'Yordam va Qo\'llab-quvvatlash'**
  String get helpAndSupport;

  /// No description provided for @appearance.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'rinish'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In uz, this message translates to:
  /// **'Tizim bo\'yicha'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In uz, this message translates to:
  /// **'Yorug\''**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In uz, this message translates to:
  /// **'Qorong\'u'**
  String get themeDark;

  /// No description provided for @logout.
  ///
  /// In uz, this message translates to:
  /// **'Tizimdan chiqish'**
  String get logout;

  /// No description provided for @logoutConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Haqiqatan ham tizimdan chiqmoqchimisiz?'**
  String get logoutConfirm;

  /// No description provided for @cancel.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilish'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In uz, this message translates to:
  /// **'Chiqish'**
  String get exit;

  /// No description provided for @welcome.
  ///
  /// In uz, this message translates to:
  /// **'Xush kelibsiz!'**
  String get welcome;

  /// No description provided for @loginToViewProfile.
  ///
  /// In uz, this message translates to:
  /// **'Profilni ko\'rish va barcha imkoniyatlardan foydalanish uchun tizimga kiring.'**
  String get loginToViewProfile;

  /// No description provided for @loginAction.
  ///
  /// In uz, this message translates to:
  /// **'Tizimga kirish'**
  String get loginAction;

  /// No description provided for @personalInfo.
  ///
  /// In uz, this message translates to:
  /// **'Shaxsiy ma\'lumotlar'**
  String get personalInfo;

  /// No description provided for @user.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchi'**
  String get user;

  /// No description provided for @invalidPhone.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, to\'g\'ri raqam kiriting'**
  String get invalidPhone;

  /// No description provided for @socialLoginNotConfigured.
  ///
  /// In uz, this message translates to:
  /// **'{provider} orqali tizimga kirish hozircha sozlanmagan.'**
  String socialLoginNotConfigured(Object provider);

  /// No description provided for @loginSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Milliy Metr hisobingizga kiring'**
  String get loginSubtitle;

  /// No description provided for @registrationNotAvailable.
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxatdan o\'tish hozircha mavjud emas.'**
  String get registrationNotAvailable;

  /// No description provided for @dontHaveAccount.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingiz yo\'qmi?'**
  String get dontHaveAccount;

  /// No description provided for @register.
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxatdan o\'tish'**
  String get register;

  /// No description provided for @invalidOtpLength.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, 6 xonali kodni kiriting'**
  String get invalidOtpLength;

  /// No description provided for @newOtpSent.
  ///
  /// In uz, this message translates to:
  /// **'Yangi kod yuborildi'**
  String get newOtpSent;

  /// No description provided for @verifyCodeTitle.
  ///
  /// In uz, this message translates to:
  /// **'Kodni tasdiqlash'**
  String get verifyCodeTitle;

  /// No description provided for @otpSentMessage.
  ///
  /// In uz, this message translates to:
  /// **'Biz {phone} raqamiga 6 xonali SMS kod yubordik. Iltimos, uni quyida kiriting.'**
  String otpSentMessage(Object phone);

  /// No description provided for @didNotReceiveCode.
  ///
  /// In uz, this message translates to:
  /// **'Kodni olmadingizmi?'**
  String get didNotReceiveCode;

  /// No description provided for @resendCodeIn.
  ///
  /// In uz, this message translates to:
  /// **'Qayta yuborish ({seconds} s)'**
  String resendCodeIn(Object seconds);

  /// No description provided for @resendCode.
  ///
  /// In uz, this message translates to:
  /// **'Qayta yuborish'**
  String get resendCode;

  /// No description provided for @specialOffers.
  ///
  /// In uz, this message translates to:
  /// **'Maxsus takliflar'**
  String get specialOffers;

  /// No description provided for @searchPlaceholder.
  ///
  /// In uz, this message translates to:
  /// **'Qidirish'**
  String get searchPlaceholder;

  /// No description provided for @salesType.
  ///
  /// In uz, this message translates to:
  /// **'Sotuv turi'**
  String get salesType;

  /// No description provided for @determineLocation.
  ///
  /// In uz, this message translates to:
  /// **'Manzilni aniqlash'**
  String get determineLocation;

  /// No description provided for @deliveryAddress.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazib berish manzili'**
  String get deliveryAddress;

  /// No description provided for @pleaseAllowFromSettings.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, sozlamalardan ruxsat bering.'**
  String get pleaseAllowFromSettings;

  /// No description provided for @settings.
  ///
  /// In uz, this message translates to:
  /// **'Sozlamalar'**
  String get settings;

  /// No description provided for @tashkentUzbekistan.
  ///
  /// In uz, this message translates to:
  /// **'Toshkent, O‘zbekiston'**
  String get tashkentUzbekistan;

  /// No description provided for @errorLoadingProducts.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlarni yuklashda xatolik yuz berdi.'**
  String get errorLoadingProducts;

  /// No description provided for @retry.
  ///
  /// In uz, this message translates to:
  /// **'Qayta urinish'**
  String get retry;

  /// No description provided for @productNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot topilmadi'**
  String get productNotFound;

  /// No description provided for @searchWithAnotherName.
  ///
  /// In uz, this message translates to:
  /// **'Boshqa nom yoki kategoriya bilan qidirib ko‘ring.'**
  String get searchWithAnotherName;

  /// No description provided for @clearFilters.
  ///
  /// In uz, this message translates to:
  /// **'Filtrlarni tozalash'**
  String get clearFilters;

  /// No description provided for @sort.
  ///
  /// In uz, this message translates to:
  /// **'Saralash'**
  String get sort;

  /// No description provided for @sortRecommended.
  ///
  /// In uz, this message translates to:
  /// **'Tavsiya etilgan'**
  String get sortRecommended;

  /// No description provided for @sortPriceAsc.
  ///
  /// In uz, this message translates to:
  /// **'Narx: pastdan yuqoriga'**
  String get sortPriceAsc;

  /// No description provided for @sortPriceDesc.
  ///
  /// In uz, this message translates to:
  /// **'Narx: yuqoridan pastga'**
  String get sortPriceDesc;

  /// No description provided for @sortNewest.
  ///
  /// In uz, this message translates to:
  /// **'Yangi mahsulotlar'**
  String get sortNewest;

  /// No description provided for @sortRating.
  ///
  /// In uz, this message translates to:
  /// **'Reyting bo‘yicha'**
  String get sortRating;

  /// No description provided for @filter.
  ///
  /// In uz, this message translates to:
  /// **'Filtr'**
  String get filter;

  /// No description provided for @priceRange.
  ///
  /// In uz, this message translates to:
  /// **'Narx oralig‘i (UZS)'**
  String get priceRange;

  /// No description provided for @region.
  ///
  /// In uz, this message translates to:
  /// **'Hudud'**
  String get region;

  /// No description provided for @all.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get all;

  /// No description provided for @clear.
  ///
  /// In uz, this message translates to:
  /// **'Tozalash'**
  String get clear;

  /// No description provided for @showResults.
  ///
  /// In uz, this message translates to:
  /// **'Natijalarni ko‘rish'**
  String get showResults;

  /// No description provided for @productCount.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta mahsulot'**
  String productCount(Object count);

  /// No description provided for @errorLoadingProductDetails.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotni yuklab bo\'lmadi'**
  String get errorLoadingProductDetails;

  /// No description provided for @newStatus.
  ///
  /// In uz, this message translates to:
  /// **'Yangi'**
  String get newStatus;

  /// No description provided for @reviewsCount.
  ///
  /// In uz, this message translates to:
  /// **'({count} sharh)'**
  String reviewsCount(Object count);

  /// No description provided for @outOfStock.
  ///
  /// In uz, this message translates to:
  /// **'Mavjud emas'**
  String get outOfStock;

  /// No description provided for @inStock.
  ///
  /// In uz, this message translates to:
  /// **'Mavjud: {stock} {unit}'**
  String inStock(Object stock, Object unit);

  /// No description provided for @delivery.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazib berish'**
  String get delivery;

  /// No description provided for @tashkent.
  ///
  /// In uz, this message translates to:
  /// **'Toshkent'**
  String get tashkent;

  /// No description provided for @aboutProduct.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot haqida'**
  String get aboutProduct;

  /// No description provided for @showLess.
  ///
  /// In uz, this message translates to:
  /// **'Qisqartirish'**
  String get showLess;

  /// No description provided for @showMore.
  ///
  /// In uz, this message translates to:
  /// **'Batafsil'**
  String get showMore;

  /// No description provided for @specifications.
  ///
  /// In uz, this message translates to:
  /// **'Xususiyatlari'**
  String get specifications;

  /// No description provided for @reviews.
  ///
  /// In uz, this message translates to:
  /// **'Sharhlar'**
  String get reviews;

  /// No description provided for @viewAllReviews.
  ///
  /// In uz, this message translates to:
  /// **'Barcha sharhlarni ko\'rish'**
  String get viewAllReviews;

  /// No description provided for @noReviewsYet.
  ///
  /// In uz, this message translates to:
  /// **'Bu mahsulot hali sharhlanmagan.'**
  String get noReviewsYet;

  /// No description provided for @beFirstToReview.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotni xarid qilgan birinchi mijoz bo\'ling.'**
  String get beFirstToReview;

  /// No description provided for @reviewsCountLabel.
  ///
  /// In uz, this message translates to:
  /// **'{count} ta sharh'**
  String reviewsCountLabel(Object count);

  /// No description provided for @buyToReview.
  ///
  /// In uz, this message translates to:
  /// **'Sharh qoldirish uchun ushbu mahsulotni xarid qiling.'**
  String get buyToReview;

  /// No description provided for @editReview.
  ///
  /// In uz, this message translates to:
  /// **'Sharhni tahrirlash'**
  String get editReview;

  /// No description provided for @leaveReview.
  ///
  /// In uz, this message translates to:
  /// **'Sharh qoldirish'**
  String get leaveReview;

  /// No description provided for @inCart.
  ///
  /// In uz, this message translates to:
  /// **'Savatda'**
  String get inCart;

  /// No description provided for @addToCart.
  ///
  /// In uz, this message translates to:
  /// **'Savatga qo\'shish'**
  String get addToCart;

  /// No description provided for @verifiedPurchase.
  ///
  /// In uz, this message translates to:
  /// **'Xarid qilingan'**
  String get verifiedPurchase;

  /// No description provided for @max5Photos.
  ///
  /// In uz, this message translates to:
  /// **'Maksimum 5 ta rasm yuklash mumkin'**
  String get max5Photos;

  /// No description provided for @errorLoadingPhoto.
  ///
  /// In uz, this message translates to:
  /// **'Rasm yuklashda xatolik yuz berdi yoki ruxsat yo\'q'**
  String get errorLoadingPhoto;

  /// No description provided for @reviewSubmitted.
  ///
  /// In uz, this message translates to:
  /// **'Sharhingiz yuborildi'**
  String get reviewSubmitted;

  /// No description provided for @rateProduct.
  ///
  /// In uz, this message translates to:
  /// **'Baho bering'**
  String get rateProduct;

  /// No description provided for @whatDidYouLike.
  ///
  /// In uz, this message translates to:
  /// **'Nimalar sizga yoqdi?'**
  String get whatDidYouLike;

  /// No description provided for @wouldYouBuyAgain.
  ///
  /// In uz, this message translates to:
  /// **'Bu mahsulotni yana xarid qilasizmi?'**
  String get wouldYouBuyAgain;

  /// No description provided for @yes.
  ///
  /// In uz, this message translates to:
  /// **'Ha'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In uz, this message translates to:
  /// **'Yo\'q'**
  String get no;

  /// No description provided for @yourReview.
  ///
  /// In uz, this message translates to:
  /// **'Sharhingiz'**
  String get yourReview;

  /// No description provided for @writeReviewHint.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot haqida fikringizni yozing...'**
  String get writeReviewHint;

  /// No description provided for @photos.
  ///
  /// In uz, this message translates to:
  /// **'Rasmlar'**
  String get photos;

  /// No description provided for @submitReview.
  ///
  /// In uz, this message translates to:
  /// **'Sharhni yuborish'**
  String get submitReview;

  /// No description provided for @ratingVeryBad.
  ///
  /// In uz, this message translates to:
  /// **'Juda yomon'**
  String get ratingVeryBad;

  /// No description provided for @ratingBad.
  ///
  /// In uz, this message translates to:
  /// **'Yomon'**
  String get ratingBad;

  /// No description provided for @ratingAverage.
  ///
  /// In uz, this message translates to:
  /// **'O\'rtacha'**
  String get ratingAverage;

  /// No description provided for @ratingGood.
  ///
  /// In uz, this message translates to:
  /// **'Yaxshi'**
  String get ratingGood;

  /// No description provided for @ratingExcellent.
  ///
  /// In uz, this message translates to:
  /// **'A\'lo'**
  String get ratingExcellent;

  /// No description provided for @withPhotos.
  ///
  /// In uz, this message translates to:
  /// **'Rasmlar bilan'**
  String get withPhotos;

  /// No description provided for @noReviewsAvailableYet.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha sharhlar yo\'q'**
  String get noReviewsAvailableYet;

  /// No description provided for @clearCartQuestion.
  ///
  /// In uz, this message translates to:
  /// **'Savatni tozalaysizmi?'**
  String get clearCartQuestion;

  /// No description provided for @clearCartWarning.
  ///
  /// In uz, this message translates to:
  /// **'Bu amal savatdagi barcha mahsulotlarni olib tashlaydi.'**
  String get clearCartWarning;

  /// No description provided for @itemRemovedFromCart.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot savatdan olib tashlandi'**
  String get itemRemovedFromCart;

  /// No description provided for @undo.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarish'**
  String get undo;

  /// No description provided for @clearCartTooltip.
  ///
  /// In uz, this message translates to:
  /// **'Savatni tozalash'**
  String get clearCartTooltip;

  /// No description provided for @cartEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Savatingiz hozircha bo‘sh'**
  String get cartEmpty;

  /// No description provided for @cartEmptyDesc.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlarni savatga qo‘shing va xaridingizni shu yerda boshqaring.'**
  String get cartEmptyDesc;

  /// No description provided for @viewProducts.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlarni ko‘rish'**
  String get viewProducts;

  /// No description provided for @orderSummary.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma xulosasi'**
  String get orderSummary;

  /// No description provided for @products.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar'**
  String get products;

  /// No description provided for @discount.
  ///
  /// In uz, this message translates to:
  /// **'Chegirma'**
  String get discount;

  /// No description provided for @total.
  ///
  /// In uz, this message translates to:
  /// **'Jami'**
  String get total;

  /// No description provided for @checkout.
  ///
  /// In uz, this message translates to:
  /// **'Rasmiylashtirish'**
  String get checkout;

  /// No description provided for @someItemsOutOfStock.
  ///
  /// In uz, this message translates to:
  /// **'Ba\'zi mahsulotlar omborda yetarli emas.'**
  String get someItemsOutOfStock;

  /// No description provided for @errorLoadingCart.
  ///
  /// In uz, this message translates to:
  /// **'Savatni yuklab bo‘lmadi'**
  String get errorLoadingCart;

  /// No description provided for @checkInternetAndRetry.
  ///
  /// In uz, this message translates to:
  /// **'Internet aloqangizni tekshiring va qayta urinib ko‘ring.'**
  String get checkInternetAndRetry;

  /// No description provided for @selectAddress.
  ///
  /// In uz, this message translates to:
  /// **'Manzilni tanlang'**
  String get selectAddress;

  /// No description provided for @chooseDestination.
  ///
  /// In uz, this message translates to:
  /// **'Manzilni tanlang'**
  String get chooseDestination;

  /// No description provided for @deliveryMethod.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazib berish usuli'**
  String get deliveryMethod;

  /// No description provided for @standardDelivery.
  ///
  /// In uz, this message translates to:
  /// **'Standart yetkazib berish'**
  String get standardDelivery;

  /// No description provided for @standardDeliveryDesc.
  ///
  /// In uz, this message translates to:
  /// **'2-3 ish kuni'**
  String get standardDeliveryDesc;

  /// No description provided for @expressDelivery.
  ///
  /// In uz, this message translates to:
  /// **'Tezkor yetkazib berish'**
  String get expressDelivery;

  /// No description provided for @expressDeliveryDesc.
  ///
  /// In uz, this message translates to:
  /// **'Bugun yoki ertaga'**
  String get expressDeliveryDesc;

  /// No description provided for @pickup.
  ///
  /// In uz, this message translates to:
  /// **'Olib ketish'**
  String get pickup;

  /// No description provided for @pickupDesc.
  ///
  /// In uz, this message translates to:
  /// **'Ombordan olib ketish'**
  String get pickupDesc;

  /// No description provided for @paymentMethod.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov usuli'**
  String get paymentMethod;

  /// No description provided for @cashOnDelivery.
  ///
  /// In uz, this message translates to:
  /// **'Naqd pul bilan to\'lash'**
  String get cashOnDelivery;

  /// No description provided for @couponCode.
  ///
  /// In uz, this message translates to:
  /// **'Promokod'**
  String get couponCode;

  /// No description provided for @enterCouponCode.
  ///
  /// In uz, this message translates to:
  /// **'Promokodni kiriting'**
  String get enterCouponCode;

  /// No description provided for @orderNotes.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma uchun izoh'**
  String get orderNotes;

  /// No description provided for @subtotal.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar'**
  String get subtotal;

  /// No description provided for @shipping.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazib berish'**
  String get shipping;

  /// No description provided for @tax.
  ///
  /// In uz, this message translates to:
  /// **'Soliq'**
  String get tax;

  /// No description provided for @finalTotal.
  ///
  /// In uz, this message translates to:
  /// **'Jami summa'**
  String get finalTotal;

  /// No description provided for @placingOrder.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma qabul qilinmoqda...'**
  String get placingOrder;

  /// No description provided for @confirmOrder.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani tasdiqlash'**
  String get confirmOrder;

  /// No description provided for @newest.
  ///
  /// In uz, this message translates to:
  /// **'Yangi qo‘shilgan'**
  String get newest;

  /// No description provided for @priceLowToHigh.
  ///
  /// In uz, this message translates to:
  /// **'Narx: pastdan yuqoriga'**
  String get priceLowToHigh;

  /// No description provided for @priceHighToLow.
  ///
  /// In uz, this message translates to:
  /// **'Narx: yuqoridan pastga'**
  String get priceHighToLow;

  /// No description provided for @rating.
  ///
  /// In uz, this message translates to:
  /// **'Reyting'**
  String get rating;

  /// No description provided for @removedFromWishlist.
  ///
  /// In uz, this message translates to:
  /// **'Sevimlilardan olib tashlandi'**
  String get removedFromWishlist;

  /// No description provided for @searchInWishlist.
  ///
  /// In uz, this message translates to:
  /// **'Sevimlilardan qidirish'**
  String get searchInWishlist;

  /// No description provided for @wishlistEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Sevimli mahsulotlaringiz shu yerda'**
  String get wishlistEmpty;

  /// No description provided for @wishlistEmptyDesc.
  ///
  /// In uz, this message translates to:
  /// **'Yoqtirgan mahsulotlaringizni saqlang va keyinroq osongina toping.'**
  String get wishlistEmptyDesc;

  /// No description provided for @noSuchProductFound.
  ///
  /// In uz, this message translates to:
  /// **'Bunday mahsulot topilmadi'**
  String get noSuchProductFound;

  /// No description provided for @tryChangingSearchWord.
  ///
  /// In uz, this message translates to:
  /// **'Qidiruv so‘zini o‘zgartirib ko‘ring'**
  String get tryChangingSearchWord;

  /// No description provided for @errorLoadingWishlist.
  ///
  /// In uz, this message translates to:
  /// **'Sevimlilarni yuklab bo‘lmadi'**
  String get errorLoadingWishlist;

  /// No description provided for @statusPending.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda'**
  String get statusPending;

  /// No description provided for @statusConfirmed.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlangan'**
  String get statusConfirmed;

  /// No description provided for @statusPacked.
  ///
  /// In uz, this message translates to:
  /// **'Qadoqlangan'**
  String get statusPacked;

  /// No description provided for @statusShipped.
  ///
  /// In uz, this message translates to:
  /// **'Yuborilgan'**
  String get statusShipped;

  /// No description provided for @statusDelivered.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazib berilgan'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilingan'**
  String get statusCancelled;

  /// No description provided for @myOrders.
  ///
  /// In uz, this message translates to:
  /// **'Mening buyurtmalarim'**
  String get myOrders;

  /// No description provided for @searchOrders.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalarni qidirish'**
  String get searchOrders;

  /// No description provided for @noOrdersFound.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalar topilmadi'**
  String get noOrdersFound;

  /// No description provided for @orderNumberLabel.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma #{number}'**
  String orderNumberLabel(Object number);

  /// No description provided for @status.
  ///
  /// In uz, this message translates to:
  /// **'Holati'**
  String get status;

  /// No description provided for @orderDate.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma sanasi'**
  String get orderDate;

  /// No description provided for @trackingTimeline.
  ///
  /// In uz, this message translates to:
  /// **'Kuzatish holati'**
  String get trackingTimeline;

  /// No description provided for @orderPlaced.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma qabul qilindi'**
  String get orderPlaced;

  /// No description provided for @processingShipped.
  ///
  /// In uz, this message translates to:
  /// **'Tayyorlanmoqda/Yuborilgan'**
  String get processingShipped;

  /// No description provided for @items.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar'**
  String get items;

  /// No description provided for @qty.
  ///
  /// In uz, this message translates to:
  /// **'Soni'**
  String get qty;

  /// No description provided for @paymentSummary.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov ma\'lumotlari'**
  String get paymentSummary;

  /// No description provided for @requestRefund.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarishni so\'rash'**
  String get requestRefund;

  /// No description provided for @adminDashboard.
  ///
  /// In uz, this message translates to:
  /// **'Admin paneli'**
  String get adminDashboard;

  /// No description provided for @userMetrics.
  ///
  /// In uz, this message translates to:
  /// **'Foydalanuvchilar statistikasi'**
  String get userMetrics;

  /// No description provided for @totalUsers.
  ///
  /// In uz, this message translates to:
  /// **'Jami foydalanuvchilar'**
  String get totalUsers;

  /// No description provided for @activeUsers.
  ///
  /// In uz, this message translates to:
  /// **'Faol'**
  String get activeUsers;

  /// No description provided for @marketplaceActivity.
  ///
  /// In uz, this message translates to:
  /// **'Bozor faolligi'**
  String get marketplaceActivity;

  /// No description provided for @revenue.
  ///
  /// In uz, this message translates to:
  /// **'Tushum'**
  String get revenue;

  /// No description provided for @totalOrders.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalar'**
  String get totalOrders;

  /// No description provided for @totalProducts.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlar'**
  String get totalProducts;

  /// No description provided for @pendingActions.
  ///
  /// In uz, this message translates to:
  /// **'Kutilayotgan amallar'**
  String get pendingActions;

  /// No description provided for @complaints.
  ///
  /// In uz, this message translates to:
  /// **'Shikoyatlar'**
  String get complaints;

  /// No description provided for @sellerDashboard.
  ///
  /// In uz, this message translates to:
  /// **'Sotuvchi paneli'**
  String get sellerDashboard;

  /// No description provided for @salesOverview.
  ///
  /// In uz, this message translates to:
  /// **'Sotuvlar xulosasi'**
  String get salesOverview;

  /// No description provided for @todaySales.
  ///
  /// In uz, this message translates to:
  /// **'Bugungi sotuv'**
  String get todaySales;

  /// No description provided for @totalSales.
  ///
  /// In uz, this message translates to:
  /// **'Jami sotuv'**
  String get totalSales;

  /// No description provided for @orderManagement.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmalarni boshqarish'**
  String get orderManagement;

  /// No description provided for @pending.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda'**
  String get pending;

  /// No description provided for @completed.
  ///
  /// In uz, this message translates to:
  /// **'Tugallangan'**
  String get completed;

  /// No description provided for @cancelled.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilingan'**
  String get cancelled;

  /// No description provided for @inventoryStatus.
  ///
  /// In uz, this message translates to:
  /// **'Ombor holati'**
  String get inventoryStatus;

  /// No description provided for @lowStock.
  ///
  /// In uz, this message translates to:
  /// **'Kam qolgan'**
  String get lowStock;

  /// No description provided for @fullName.
  ///
  /// In uz, this message translates to:
  /// **'To\'liq ism'**
  String get fullName;

  /// No description provided for @email.
  ///
  /// In uz, this message translates to:
  /// **'Elektron pochta'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In uz, this message translates to:
  /// **'Telefon'**
  String get phone;

  /// No description provided for @save.
  ///
  /// In uz, this message translates to:
  /// **'Saqlash'**
  String get save;

  /// No description provided for @editProfile.
  ///
  /// In uz, this message translates to:
  /// **'Profilni tahrirlash'**
  String get editProfile;

  /// No description provided for @profileUpdated.
  ///
  /// In uz, this message translates to:
  /// **'Profil yangilandi'**
  String get profileUpdated;

  /// No description provided for @enterFullName.
  ///
  /// In uz, this message translates to:
  /// **'Ismingizni kiriting'**
  String get enterFullName;

  /// No description provided for @enterEmail.
  ///
  /// In uz, this message translates to:
  /// **'Elektron pochtangizni kiriting'**
  String get enterEmail;

  /// No description provided for @changePassword.
  ///
  /// In uz, this message translates to:
  /// **'Parolni o\'zgartirish'**
  String get changePassword;

  /// No description provided for @currentPassword.
  ///
  /// In uz, this message translates to:
  /// **'Joriy parol'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In uz, this message translates to:
  /// **'Yangi parol'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In uz, this message translates to:
  /// **'Parolni tasdiqlash'**
  String get confirmPassword;

  /// No description provided for @biometricAuth.
  ///
  /// In uz, this message translates to:
  /// **'Biometrik autentifikatsiya'**
  String get biometricAuth;

  /// No description provided for @biometricAuthDesc.
  ///
  /// In uz, this message translates to:
  /// **'Barmoq izi yoki yuz tanish orqali kirish'**
  String get biometricAuthDesc;

  /// No description provided for @twoFactorAuth.
  ///
  /// In uz, this message translates to:
  /// **'Ikki bosqichli tasdiqlash'**
  String get twoFactorAuth;

  /// No description provided for @twoFactorAuthDesc.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingizni qo\'shimcha himoyalash'**
  String get twoFactorAuthDesc;

  /// No description provided for @activeSessions.
  ///
  /// In uz, this message translates to:
  /// **'Faol seanslar'**
  String get activeSessions;

  /// No description provided for @activeSessionsDesc.
  ///
  /// In uz, this message translates to:
  /// **'Tizimga kirgan qurilmalaringiz'**
  String get activeSessionsDesc;

  /// No description provided for @deleteAccount.
  ///
  /// In uz, this message translates to:
  /// **'Hisobni o\'chirish'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In uz, this message translates to:
  /// **'Bu amalni qaytarib bo\'lmaydi. Barcha ma\'lumotlaringiz o\'chiriladi.'**
  String get deleteAccountWarning;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In uz, this message translates to:
  /// **'Haqiqatan ham hisobingizni o\'chirmoqchimisiz?'**
  String get deleteAccountConfirm;

  /// No description provided for @accountSecurity.
  ///
  /// In uz, this message translates to:
  /// **'Hisob xavfsizligi'**
  String get accountSecurity;

  /// No description provided for @privacySettings.
  ///
  /// In uz, this message translates to:
  /// **'Maxfiylik sozlamalari'**
  String get privacySettings;

  /// No description provided for @dataPrivacy.
  ///
  /// In uz, this message translates to:
  /// **'Ma\'lumotlar maxfiyligi'**
  String get dataPrivacy;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In uz, this message translates to:
  /// **'Parollar mos kelmadi'**
  String get passwordsDoNotMatch;

  /// No description provided for @passwordTooShort.
  ///
  /// In uz, this message translates to:
  /// **'Parol kamida 8 belgidan iborat bo\'lishi kerak'**
  String get passwordTooShort;

  /// No description provided for @faq.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'p so\'raladigan savollar'**
  String get faq;

  /// No description provided for @contactSupport.
  ///
  /// In uz, this message translates to:
  /// **'Qo\'llab-quvvatlash bilan bog\'lanish'**
  String get contactSupport;

  /// No description provided for @callUs.
  ///
  /// In uz, this message translates to:
  /// **'Bizga qo\'ng\'iroq qiling'**
  String get callUs;

  /// No description provided for @emailUs.
  ///
  /// In uz, this message translates to:
  /// **'Bizga yozing'**
  String get emailUs;

  /// No description provided for @telegram.
  ///
  /// In uz, this message translates to:
  /// **'Telegram'**
  String get telegram;

  /// No description provided for @aboutApp.
  ///
  /// In uz, this message translates to:
  /// **'Ilova haqida'**
  String get aboutApp;

  /// No description provided for @appVersion.
  ///
  /// In uz, this message translates to:
  /// **'Ilova versiyasi'**
  String get appVersion;

  /// No description provided for @faqDelivery.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazib berish qancha vaqt oladi?'**
  String get faqDelivery;

  /// No description provided for @faqDeliveryAnswer.
  ///
  /// In uz, this message translates to:
  /// **'Standart yetkazib berish 2-3 ish kunini oladi. Tezkor yetkazib berish esa 1 kun ichida amalga oshiriladi.'**
  String get faqDeliveryAnswer;

  /// No description provided for @faqPayment.
  ///
  /// In uz, this message translates to:
  /// **'Qanday to\'lov usullari mavjud?'**
  String get faqPayment;

  /// No description provided for @faqPaymentAnswer.
  ///
  /// In uz, this message translates to:
  /// **'Hozirda naqd pul bilan to\'lov qabul qilinadi. Boshqa to\'lov usullari tez orada qo\'shiladi.'**
  String get faqPaymentAnswer;

  /// No description provided for @faqReturn.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotni qaytarish mumkinmi?'**
  String get faqReturn;

  /// No description provided for @faqReturnAnswer.
  ///
  /// In uz, this message translates to:
  /// **'Ha, 14 kun ichida mahsulotni qaytarish mumkin. Mahsulot ishlatilmagan va original qadoqda bo\'lishi kerak.'**
  String get faqReturnAnswer;

  /// No description provided for @faqWarranty.
  ///
  /// In uz, this message translates to:
  /// **'Kafolat mavjudmi?'**
  String get faqWarranty;

  /// No description provided for @faqWarrantyAnswer.
  ///
  /// In uz, this message translates to:
  /// **'Barcha mahsulotlarimiz ishlab chiqaruvchi kafolati bilan ta\'minlangan.'**
  String get faqWarrantyAnswer;

  /// No description provided for @cashOnDeliveryDesc.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani qabul qilganingizda to\'lang'**
  String get cashOnDeliveryDesc;

  /// No description provided for @clickPayment.
  ///
  /// In uz, this message translates to:
  /// **'Click orqali to\'lov'**
  String get clickPayment;

  /// No description provided for @clickPaymentDesc.
  ///
  /// In uz, this message translates to:
  /// **'Click ilovasi orqali to\'lang'**
  String get clickPaymentDesc;

  /// No description provided for @bankCard.
  ///
  /// In uz, this message translates to:
  /// **'Bank kartasi'**
  String get bankCard;

  /// No description provided for @bankCardDesc.
  ///
  /// In uz, this message translates to:
  /// **'Visa yoki Mastercard orqali to\'lang'**
  String get bankCardDesc;

  /// No description provided for @paymentMethodSelected.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov usuli tanlandi'**
  String get paymentMethodSelected;

  /// No description provided for @defaultPayment.
  ///
  /// In uz, this message translates to:
  /// **'Asosiy'**
  String get defaultPayment;

  /// No description provided for @noReviewsWritten.
  ///
  /// In uz, this message translates to:
  /// **'Siz hali sharh yozmadingiz'**
  String get noReviewsWritten;

  /// No description provided for @noReviewsWrittenDesc.
  ///
  /// In uz, this message translates to:
  /// **'Xarid qilgan mahsulotlaringizga sharh qoldiring'**
  String get noReviewsWrittenDesc;

  /// No description provided for @notificationsEmpty.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha yangi bildirishnomalar yo\'q'**
  String get notificationsEmpty;

  /// No description provided for @notificationsEmptyDesc.
  ///
  /// In uz, this message translates to:
  /// **'Yangi xabarlar shu yerda ko\'rinadi'**
  String get notificationsEmptyDesc;

  /// No description provided for @markAllRead.
  ///
  /// In uz, this message translates to:
  /// **'Barchasini o\'qilgan deb belgilash'**
  String get markAllRead;

  /// No description provided for @orderStatusChanged.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma holati o\'zgardi'**
  String get orderStatusChanged;

  /// No description provided for @newPromotion.
  ///
  /// In uz, this message translates to:
  /// **'Yangi aksiya'**
  String get newPromotion;

  /// No description provided for @systemNotification.
  ///
  /// In uz, this message translates to:
  /// **'Tizim xabarnomasi'**
  String get systemNotification;

  /// No description provided for @today.
  ///
  /// In uz, this message translates to:
  /// **'Bugun'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In uz, this message translates to:
  /// **'Kecha'**
  String get yesterday;

  /// No description provided for @earlier.
  ///
  /// In uz, this message translates to:
  /// **'Avvalgi'**
  String get earlier;

  /// No description provided for @requiresBackendIntegration.
  ///
  /// In uz, this message translates to:
  /// **'Backend integratsiyasi talab qilinadi'**
  String get requiresBackendIntegration;

  /// No description provided for @featureAvailableSoon.
  ///
  /// In uz, this message translates to:
  /// **'Bu funksiya tez orada ishga tushiriladi'**
  String get featureAvailableSoon;

  /// No description provided for @english.
  ///
  /// In uz, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @storeProducts.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon mahsulotlari'**
  String get storeProducts;

  /// No description provided for @noProductsInStore.
  ///
  /// In uz, this message translates to:
  /// **'Bu do\'konda hozircha mahsulot yo\'q'**
  String get noProductsInStore;

  /// No description provided for @platformSettings.
  ///
  /// In uz, this message translates to:
  /// **'Platforma sozlamalari'**
  String get platformSettings;

  /// No description provided for @general.
  ///
  /// In uz, this message translates to:
  /// **'Umumiy'**
  String get general;

  /// No description provided for @maintenanceMode.
  ///
  /// In uz, this message translates to:
  /// **'Texnik xizmat rejimi'**
  String get maintenanceMode;

  /// No description provided for @maintenanceModeDesc.
  ///
  /// In uz, this message translates to:
  /// **'Ilovani vaqtincha o\'chirish'**
  String get maintenanceModeDesc;

  /// No description provided for @share.
  ///
  /// In uz, this message translates to:
  /// **'Ulashish'**
  String get share;

  /// No description provided for @submitRequest.
  ///
  /// In uz, this message translates to:
  /// **'So\'rovni yuborish'**
  String get submitRequest;

  /// No description provided for @refundReason.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarish sababi'**
  String get refundReason;

  /// No description provided for @selectReason.
  ///
  /// In uz, this message translates to:
  /// **'Sababni tanlang'**
  String get selectReason;

  /// No description provided for @refundDescription.
  ///
  /// In uz, this message translates to:
  /// **'Tavsifni kiriting'**
  String get refundDescription;

  /// No description provided for @refundSubmitted.
  ///
  /// In uz, this message translates to:
  /// **'Qaytarish so\'rovi yuborildi'**
  String get refundSubmitted;

  /// No description provided for @addCard.
  ///
  /// In uz, this message translates to:
  /// **'Karta qo\'shish'**
  String get addCard;

  /// No description provided for @cardNumber.
  ///
  /// In uz, this message translates to:
  /// **'Karta raqami'**
  String get cardNumber;

  /// No description provided for @expiryDate.
  ///
  /// In uz, this message translates to:
  /// **'Amal qilish muddati'**
  String get expiryDate;

  /// No description provided for @cvv.
  ///
  /// In uz, this message translates to:
  /// **'CVV'**
  String get cvv;

  /// No description provided for @cardholderName.
  ///
  /// In uz, this message translates to:
  /// **'Karta egasining ismi'**
  String get cardholderName;

  /// No description provided for @payAmount.
  ///
  /// In uz, this message translates to:
  /// **'{amount} to\'lash'**
  String payAmount(Object amount);

  /// No description provided for @changeBtn.
  ///
  /// In uz, this message translates to:
  /// **'O\'zgartirish'**
  String get changeBtn;

  /// No description provided for @editBtn.
  ///
  /// In uz, this message translates to:
  /// **'Tahrirlash'**
  String get editBtn;

  /// No description provided for @orderConfirmed.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma tasdiqlandi'**
  String get orderConfirmed;

  /// No description provided for @paymentFailed.
  ///
  /// In uz, this message translates to:
  /// **'To\'lov amalga oshmadi'**
  String get paymentFailed;

  /// No description provided for @payme.
  ///
  /// In uz, this message translates to:
  /// **'Payme'**
  String get payme;

  /// No description provided for @visa.
  ///
  /// In uz, this message translates to:
  /// **'Visa'**
  String get visa;

  /// No description provided for @mastercard.
  ///
  /// In uz, this message translates to:
  /// **'Mastercard'**
  String get mastercard;

  /// No description provided for @uzcard.
  ///
  /// In uz, this message translates to:
  /// **'Uzcard'**
  String get uzcard;

  /// No description provided for @humo.
  ///
  /// In uz, this message translates to:
  /// **'Humo'**
  String get humo;

  /// No description provided for @analyticsAndReports.
  ///
  /// In uz, this message translates to:
  /// **'Tahlil va hisobotlar'**
  String get analyticsAndReports;

  /// No description provided for @productSavedSuccessfully.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot muvaffaqiyatli saqlandi'**
  String get productSavedSuccessfully;

  /// No description provided for @startTypingToSearch.
  ///
  /// In uz, this message translates to:
  /// **'Qidirish uchun yozishni boshlang.'**
  String get startTypingToSearch;

  /// No description provided for @myProducts.
  ///
  /// In uz, this message translates to:
  /// **'Mening mahsulotlarim'**
  String get myProducts;

  /// No description provided for @noProductsAddedYet.
  ///
  /// In uz, this message translates to:
  /// **'Siz hali hech qanday mahsulot qo\'shmadingiz.'**
  String get noProductsAddedYet;

  /// No description provided for @inStockOnly.
  ///
  /// In uz, this message translates to:
  /// **'Faqat mavjudlari'**
  String get inStockOnly;

  /// No description provided for @hasDiscount.
  ///
  /// In uz, this message translates to:
  /// **'Chegirmasi bor'**
  String get hasDiscount;

  /// No description provided for @wholesale.
  ///
  /// In uz, this message translates to:
  /// **'Ulgurji'**
  String get wholesale;

  /// No description provided for @retail.
  ///
  /// In uz, this message translates to:
  /// **'Chakana'**
  String get retail;

  /// No description provided for @applyFilters.
  ///
  /// In uz, this message translates to:
  /// **'Filtrlarni qo\'llash'**
  String get applyFilters;

  /// No description provided for @registrationSubmitted.
  ///
  /// In uz, this message translates to:
  /// **'Ro\'yxatdan o\'tish yuborildi'**
  String get registrationSubmitted;

  /// No description provided for @becomeASeller.
  ///
  /// In uz, this message translates to:
  /// **'Sotuvchi bo\'lish'**
  String get becomeASeller;

  /// No description provided for @orderDetails.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtma tafsilotlari'**
  String get orderDetails;

  /// No description provided for @verificationStatus.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlash holati'**
  String get verificationStatus;

  /// No description provided for @storeProfileUpdated.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon profili yangilandi'**
  String get storeProfileUpdated;

  /// No description provided for @manageStoreProfile.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon profilini boshqarish'**
  String get manageStoreProfile;

  /// No description provided for @personalizeYourFeed.
  ///
  /// In uz, this message translates to:
  /// **'Lentangizni moslashtirish'**
  String get personalizeYourFeed;

  /// No description provided for @myAddresses.
  ///
  /// In uz, this message translates to:
  /// **'Mening manzillarim'**
  String get myAddresses;

  /// No description provided for @noCategoriesAvailable.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyalar mavjud emas'**
  String get noCategoriesAvailable;

  /// No description provided for @buyNow.
  ///
  /// In uz, this message translates to:
  /// **'Hozir xarid qilish'**
  String get buyNow;

  /// No description provided for @addAddress.
  ///
  /// In uz, this message translates to:
  /// **'Manzil qo\'shish'**
  String get addAddress;

  /// No description provided for @addressLabel.
  ///
  /// In uz, this message translates to:
  /// **'Nomi (masalan, Uy, Ishxona)'**
  String get addressLabel;

  /// No description provided for @district.
  ///
  /// In uz, this message translates to:
  /// **'Tuman'**
  String get district;

  /// No description provided for @streetBuilding.
  ///
  /// In uz, this message translates to:
  /// **'Ko\'cha/Uy'**
  String get streetBuilding;

  /// No description provided for @saveAddress.
  ///
  /// In uz, this message translates to:
  /// **'Manzilni saqlash'**
  String get saveAddress;

  /// No description provided for @fieldRequired.
  ///
  /// In uz, this message translates to:
  /// **'Majburiy'**
  String get fieldRequired;

  /// No description provided for @compareProducts.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulotlarni taqqoslash'**
  String get compareProducts;

  /// No description provided for @feature.
  ///
  /// In uz, this message translates to:
  /// **'Xususiyat'**
  String get feature;

  /// No description provided for @productA.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot A'**
  String get productA;

  /// No description provided for @productB.
  ///
  /// In uz, this message translates to:
  /// **'Mahsulot B'**
  String get productB;

  /// No description provided for @weight.
  ///
  /// In uz, this message translates to:
  /// **'Og\'irligi'**
  String get weight;

  /// No description provided for @grade.
  ///
  /// In uz, this message translates to:
  /// **'Markasi'**
  String get grade;

  /// No description provided for @store.
  ///
  /// In uz, this message translates to:
  /// **'Do\'kon'**
  String get store;

  /// No description provided for @damagedItem.
  ///
  /// In uz, this message translates to:
  /// **'Shikastlangan mahsulot'**
  String get damagedItem;

  /// No description provided for @wrongItem.
  ///
  /// In uz, this message translates to:
  /// **'Noto\'g\'ri mahsulot'**
  String get wrongItem;

  /// No description provided for @lateDelivery.
  ///
  /// In uz, this message translates to:
  /// **'Kech yetkazib berish'**
  String get lateDelivery;

  /// No description provided for @invoice.
  ///
  /// In uz, this message translates to:
  /// **'Hisob-faktura'**
  String get invoice;

  /// No description provided for @noReviewsYetStore.
  ///
  /// In uz, this message translates to:
  /// **'Hozircha sharhlar yo\'q.'**
  String get noReviewsYetStore;

  /// No description provided for @accountNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Bu raqam bilan hisob topilmadi'**
  String get accountNotFound;

  /// No description provided for @fillAllFields.
  ///
  /// In uz, this message translates to:
  /// **'Iltimos, barcha maydonlarni to\'ldiring'**
  String get fillAllFields;

  /// No description provided for @accountExists.
  ///
  /// In uz, this message translates to:
  /// **'Bu raqam allaqachon ro\'yxatdan o\'tgan'**
  String get accountExists;

  /// No description provided for @registrationSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Yangi hisob yarating'**
  String get registrationSubtitle;

  /// No description provided for @nameHint.
  ///
  /// In uz, this message translates to:
  /// **'Ismingizni kiriting'**
  String get nameHint;

  /// No description provided for @surnameHint.
  ///
  /// In uz, this message translates to:
  /// **'Familiyangizni kiriting'**
  String get surnameHint;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In uz, this message translates to:
  /// **'Hisobingiz mavjudmi?'**
  String get alreadyHaveAccount;

  /// No description provided for @name.
  ///
  /// In uz, this message translates to:
  /// **'Ism'**
  String get name;

  /// No description provided for @surname.
  ///
  /// In uz, this message translates to:
  /// **'Familiya'**
  String get surname;

  /// No description provided for @whatMaterials.
  ///
  /// In uz, this message translates to:
  /// **'Qanday materiallarni qidiryapsiz?'**
  String get whatMaterials;

  /// No description provided for @selectCategories.
  ///
  /// In uz, this message translates to:
  /// **'Tajribangizni moslashtirishimiz uchun sizni qiziqtirgan kategoriyalarni tanlang.'**
  String get selectCategories;

  /// No description provided for @continueAction.
  ///
  /// In uz, this message translates to:
  /// **'Davom etish'**
  String get continueAction;

  /// No description provided for @categoryCement.
  ///
  /// In uz, this message translates to:
  /// **'Sement va Qorishma'**
  String get categoryCement;

  /// No description provided for @categoryBricks.
  ///
  /// In uz, this message translates to:
  /// **'G\'isht va Bloklar'**
  String get categoryBricks;

  /// No description provided for @categorySteel.
  ///
  /// In uz, this message translates to:
  /// **'Armatura'**
  String get categorySteel;

  /// No description provided for @categorySand.
  ///
  /// In uz, this message translates to:
  /// **'Qum va Shag\'al'**
  String get categorySand;

  /// No description provided for @categoryConcrete.
  ///
  /// In uz, this message translates to:
  /// **'Beton'**
  String get categoryConcrete;

  /// No description provided for @categoryRoofing.
  ///
  /// In uz, this message translates to:
  /// **'Tom yopish materiallari'**
  String get categoryRoofing;

  /// No description provided for @categoryWood.
  ///
  /// In uz, this message translates to:
  /// **'Yog\'och va Fanera'**
  String get categoryWood;

  /// No description provided for @categoryPlumbing.
  ///
  /// In uz, this message translates to:
  /// **'Santexnika va Qvurlar'**
  String get categoryPlumbing;

  /// No description provided for @categoryElectrical.
  ///
  /// In uz, this message translates to:
  /// **'Elektr materiallari'**
  String get categoryElectrical;

  /// No description provided for @categoryPaint.
  ///
  /// In uz, this message translates to:
  /// **'Bo\'yoq va Pardozlash'**
  String get categoryPaint;

  /// No description provided for @authRequiredToContinue.
  ///
  /// In uz, this message translates to:
  /// **'Buyurtmani davom ettirish uchun tizimga kiring.'**
  String get authRequiredToContinue;

  /// No description provided for @onboardingTitle.
  ///
  /// In uz, this message translates to:
  /// **'Barcha Qurilish Materiallari Bitta Joyda'**
  String get onboardingTitle;

  /// No description provided for @onboardingSubtitle.
  ///
  /// In uz, this message translates to:
  /// **'Sement, g\'isht va po\'latni ishonchli yetkazib beruvchilardan ulgurji narxlarda xarid qiling.'**
  String get onboardingSubtitle;

  /// No description provided for @getStarted.
  ///
  /// In uz, this message translates to:
  /// **'Boshlash'**
  String get getStarted;

  /// No description provided for @errorOccurred.
  ///
  /// In uz, this message translates to:
  /// **'Xatolik yuz berdi'**
  String get errorOccurred;

  /// No description provided for @categoriesNotFound.
  ///
  /// In uz, this message translates to:
  /// **'Kategoriyalar topilmadi'**
  String get categoriesNotFound;

  /// No description provided for @piece.
  ///
  /// In uz, this message translates to:
  /// **'dona'**
  String get piece;

  /// No description provided for @guestModeTitle.
  ///
  /// In uz, this message translates to:
  /// **'Tizimga kiring'**
  String get guestModeTitle;

  /// No description provided for @guestCartDesc.
  ///
  /// In uz, this message translates to:
  /// **'Savatchani ko\'rish uchun tizimga kiring.'**
  String get guestCartDesc;

  /// No description provided for @guestWishlistDesc.
  ///
  /// In uz, this message translates to:
  /// **'Sevimlilarni ko\'rish uchun tizimga kiring.'**
  String get guestWishlistDesc;

  /// No description provided for @discountsChip.
  ///
  /// In uz, this message translates to:
  /// **'Aksiyalar'**
  String get discountsChip;

  /// No description provided for @expressDeliveryChip.
  ///
  /// In uz, this message translates to:
  /// **'Tezkor yetkazish'**
  String get expressDeliveryChip;

  /// No description provided for @directFactoryChip.
  ///
  /// In uz, this message translates to:
  /// **'To\'g\'ridan-to\'g\'ri zavoddan'**
  String get directFactoryChip;

  /// No description provided for @popularChip.
  ///
  /// In uz, this message translates to:
  /// **'Ommabop'**
  String get popularChip;

  /// No description provided for @servicesChip.
  ///
  /// In uz, this message translates to:
  /// **'Usta xizmati'**
  String get servicesChip;

  /// No description provided for @qualityGuaranteeBadge.
  ///
  /// In uz, this message translates to:
  /// **'100% Sifat kafolati'**
  String get qualityGuaranteeBadge;

  /// No description provided for @fastDeliveryBadge.
  ///
  /// In uz, this message translates to:
  /// **'Tezkor yetkazib berish'**
  String get fastDeliveryBadge;

  /// No description provided for @securePaymentBadge.
  ///
  /// In uz, this message translates to:
  /// **'Xavfsiz to\'lov'**
  String get securePaymentBadge;

  /// No description provided for @orderStatusAll.
  ///
  /// In uz, this message translates to:
  /// **'Barchasi'**
  String get orderStatusAll;

  /// No description provided for @orderStatusPending.
  ///
  /// In uz, this message translates to:
  /// **'Kutilmoqda'**
  String get orderStatusPending;

  /// No description provided for @orderStatusConfirmed.
  ///
  /// In uz, this message translates to:
  /// **'Tasdiqlangan'**
  String get orderStatusConfirmed;

  /// No description provided for @orderStatusProcessing.
  ///
  /// In uz, this message translates to:
  /// **'Jarayonda'**
  String get orderStatusProcessing;

  /// No description provided for @orderStatusDelivered.
  ///
  /// In uz, this message translates to:
  /// **'Yetkazildi'**
  String get orderStatusDelivered;

  /// No description provided for @orderStatusCancelled.
  ///
  /// In uz, this message translates to:
  /// **'Bekor qilingan'**
  String get orderStatusCancelled;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru', 'uz'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
    case 'uz':
      return AppLocalizationsUz();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
