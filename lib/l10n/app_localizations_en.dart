// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Milliy Metr';

  @override
  String get login => 'Log In';

  @override
  String get sendOtp => 'Send SMS Code';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get welcomeTo => 'Welcome to Milliy Metr';

  @override
  String get or => 'OR';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get verifyPhone => 'Verify Phone';

  @override
  String enterCode(Object phone) {
    return 'Enter the 6-digit code sent to $phone.';
  }

  @override
  String get verify => 'Verify';

  @override
  String get searchHint => 'Search construction materials...';

  @override
  String get categories => 'Categories';

  @override
  String get viewAll => 'View All';

  @override
  String get featuredProducts => 'Featured Products';

  @override
  String get home => 'Home';

  @override
  String get catalog => 'Catalog';

  @override
  String get cart => 'Cart';

  @override
  String get profile => 'Profile';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get systemLanguage => 'System Language';

  @override
  String get orders => 'Orders';

  @override
  String get wishlist => 'Wishlist';

  @override
  String get addresses => 'Addresses';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get myReviews => 'My Reviews';

  @override
  String get notifications => 'Notifications';

  @override
  String get securityAndPrivacy => 'Security & Privacy';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get appearance => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get logout => 'Log Out';

  @override
  String get logoutConfirm => 'Are you sure you want to log out?';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Log Out';

  @override
  String get welcome => 'Welcome!';

  @override
  String get loginToViewProfile =>
      'Log in to view your profile and access all features.';

  @override
  String get loginAction => 'Log In';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get user => 'User';

  @override
  String get invalidPhone => 'Please enter a valid phone number';

  @override
  String socialLoginNotConfigured(Object provider) {
    return 'Login via $provider is not yet configured.';
  }

  @override
  String get loginSubtitle => 'Sign in to your Milliy Metr account';

  @override
  String get registrationNotAvailable => 'Registration is not available yet.';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get register => 'Register';

  @override
  String get invalidOtpLength => 'Please enter the 6-digit code';

  @override
  String get newOtpSent => 'New code sent';

  @override
  String get verifyCodeTitle => 'Verify Code';

  @override
  String otpSentMessage(Object phone) {
    return 'We sent a 6-digit SMS code to $phone. Please enter it below.';
  }

  @override
  String get didNotReceiveCode => 'Didn\'t receive the code?';

  @override
  String resendCodeIn(Object seconds) {
    return 'Resend ($seconds s)';
  }

  @override
  String get resendCode => 'Resend';

  @override
  String get specialOffers => 'Special Offers';

  @override
  String get salesType => 'Sales Type';

  @override
  String get determineLocation => 'Determine Location';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get pleaseAllowFromSettings => 'Please allow access from settings.';

  @override
  String get settings => 'Settings';

  @override
  String get tashkentUzbekistan => 'Tashkent, Uzbekistan';

  @override
  String get errorLoadingProducts => 'Error loading products.';

  @override
  String get retry => 'Retry';

  @override
  String get productNotFound => 'Product not found';

  @override
  String get searchWithAnotherName =>
      'Try searching with a different name or category.';

  @override
  String get clearFilters => 'Clear Filters';

  @override
  String get sort => 'Sort';

  @override
  String get sortRecommended => 'Recommended';

  @override
  String get sortPriceAsc => 'Price: Low to High';

  @override
  String get sortPriceDesc => 'Price: High to Low';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortRating => 'By Rating';

  @override
  String get filter => 'Filter';

  @override
  String get priceRange => 'Price Range (UZS)';

  @override
  String get priceLowToHigh => 'Price: Low to High';

  @override
  String get priceHighToLow => 'Price: High to Low';

  @override
  String get fromPrice => 'From (UZS)';

  @override
  String get toPrice => 'To (UZS)';

  @override
  String get currency => 'UZS';

  @override
  String get region => 'Region';

  @override
  String get all => 'All';

  @override
  String get clear => 'Clear';

  @override
  String get showResults => 'Show Results';

  @override
  String productCount(Object count) {
    return '$count products';
  }

  @override
  String get errorLoadingProductDetails => 'Could not load product';

  @override
  String get newStatus => 'New';

  @override
  String reviewsCount(Object count) {
    return '($count reviews)';
  }

  @override
  String get outOfStock => 'Out of Stock';

  @override
  String inStock(Object stock, Object unit) {
    return 'In stock: $stock $unit';
  }

  @override
  String get delivery => 'Delivery';

  @override
  String get tashkent => 'Tashkent';

  @override
  String get aboutProduct => 'About Product';

  @override
  String get showLess => 'Show Less';

  @override
  String get showMore => 'Show More';

  @override
  String get specifications => 'Specifications';

  @override
  String get reviews => 'Reviews';

  @override
  String get viewAllReviews => 'View All Reviews';

  @override
  String get noReviewsYet => 'No reviews yet for this product.';

  @override
  String get beFirstToReview => 'Be the first customer to review this product.';

  @override
  String reviewsCountLabel(Object count) {
    return '$count reviews';
  }

  @override
  String get buyToReview => 'Purchase this product to leave a review.';

  @override
  String get editReview => 'Edit Review';

  @override
  String get leaveReview => 'Leave a Review';

  @override
  String get inCart => 'In Cart';

  @override
  String get addToCart => 'Add to Cart';

  @override
  String get verifiedPurchase => 'Verified Purchase';

  @override
  String get max5Photos => 'Maximum 5 photos allowed';

  @override
  String get errorLoadingPhoto => 'Error loading photo or permission denied';

  @override
  String get reviewSubmitted => 'Your review has been submitted';

  @override
  String get rateProduct => 'Rate this product';

  @override
  String get whatDidYouLike => 'What did you like?';

  @override
  String get wouldYouBuyAgain => 'Would you buy this product again?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get yourReview => 'Your Review';

  @override
  String get writeReviewHint => 'Write your thoughts about the product...';

  @override
  String get photos => 'Photos';

  @override
  String get submitReview => 'Submit Review';

  @override
  String get ratingVeryBad => 'Very Bad';

  @override
  String get ratingBad => 'Bad';

  @override
  String get ratingAverage => 'Average';

  @override
  String get ratingGood => 'Good';

  @override
  String get ratingExcellent => 'Excellent';

  @override
  String get withPhotos => 'With Photos';

  @override
  String get noReviewsAvailableYet => 'No reviews available yet';

  @override
  String get clearCartQuestion => 'Clear cart?';

  @override
  String get clearCartWarning => 'This will remove all products from the cart.';

  @override
  String get itemRemovedFromCart => 'Product removed from cart';

  @override
  String get undo => 'Undo';

  @override
  String get clearCartTooltip => 'Clear Cart';

  @override
  String get cartEmpty => 'Your cart is empty';

  @override
  String get cartEmptyDesc =>
      'Add products to your cart and manage your purchases here.';

  @override
  String get viewProducts => 'View Products';

  @override
  String get orderSummary => 'Order Summary';

  @override
  String get products => 'Products';

  @override
  String get discount => 'Discount';

  @override
  String get total => 'Total';

  @override
  String get checkout => 'Checkout';

  @override
  String get someItemsOutOfStock => 'Some items are out of stock.';

  @override
  String get errorLoadingCart => 'Could not load cart';

  @override
  String get checkInternetAndRetry =>
      'Check your internet connection and try again.';

  @override
  String get selectAddress => 'Select Address';

  @override
  String get chooseDestination => 'Choose destination';

  @override
  String get deliveryMethod => 'Delivery Method';

  @override
  String get standardDelivery => 'Standard Delivery';

  @override
  String get standardDeliveryDesc => '2-3 business days';

  @override
  String get expressDelivery => 'Express Delivery';

  @override
  String get expressDeliveryDesc => 'Today or tomorrow';

  @override
  String get pickup => 'Pickup';

  @override
  String get pickupDesc => 'Pick up from warehouse';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get cashOnDelivery => 'Cash on Delivery';

  @override
  String get couponCode => 'Promo Code';

  @override
  String get enterCouponCode => 'Enter promo code';

  @override
  String get orderNotes => 'Order Notes';

  @override
  String get subtotal => 'Products';

  @override
  String get shipping => 'Shipping';

  @override
  String get tax => 'Tax';

  @override
  String get finalTotal => 'Total Amount';

  @override
  String get placingOrder => 'Placing order...';

  @override
  String get confirmOrder => 'Confirm Order';

  @override
  String get newest => 'Newest';

  @override
  String get rating => 'Rating';

  @override
  String get removedFromWishlist => 'Removed from wishlist';

  @override
  String get searchInWishlist => 'Search in wishlist';

  @override
  String get wishlistEmpty => 'Your favorite products are here';

  @override
  String get wishlistEmptyDesc =>
      'Save products you like and find them easily later.';

  @override
  String get noSuchProductFound => 'No such product found';

  @override
  String get tryChangingSearchWord => 'Try changing the search word';

  @override
  String get errorLoadingWishlist => 'Could not load wishlist';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusConfirmed => 'Confirmed';

  @override
  String get statusPacked => 'Packed';

  @override
  String get statusShipped => 'Shipped';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get myOrders => 'My Orders';

  @override
  String get searchOrders => 'Search orders';

  @override
  String get noOrdersFound => 'No orders found';

  @override
  String orderNumberLabel(Object number) {
    return 'Order #$number';
  }

  @override
  String get status => 'Status';

  @override
  String get orderDate => 'Order Date';

  @override
  String get trackingTimeline => 'Tracking Status';

  @override
  String get orderPlaced => 'Order placed';

  @override
  String get processingShipped => 'Processing/Shipped';

  @override
  String get items => 'Items';

  @override
  String get qty => 'Qty';

  @override
  String get paymentSummary => 'Payment Summary';

  @override
  String get requestRefund => 'Request Refund';

  @override
  String get adminDashboard => 'Admin Dashboard';

  @override
  String get userMetrics => 'User Metrics';

  @override
  String get totalUsers => 'Total Users';

  @override
  String get activeUsers => 'Active';

  @override
  String get marketplaceActivity => 'Marketplace Activity';

  @override
  String get revenue => 'Revenue';

  @override
  String get totalOrders => 'Orders';

  @override
  String get totalProducts => 'Products';

  @override
  String get pendingActions => 'Pending Actions';

  @override
  String get complaints => 'Complaints';

  @override
  String get salesOverview => 'Sales Overview';

  @override
  String get todaySales => 'Today\'s Sales';

  @override
  String get totalSales => 'Total Sales';

  @override
  String get orderManagement => 'Order Management';

  @override
  String get pending => 'Pending';

  @override
  String get completed => 'Completed';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get inventoryStatus => 'Inventory Status';

  @override
  String get lowStock => 'Low Stock';

  @override
  String get fullName => 'Full Name';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get save => 'Save';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get profileUpdated => 'Profile updated';

  @override
  String get enterFullName => 'Enter your name';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get changePassword => 'Change Password';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get biometricAuth => 'Biometric Authentication';

  @override
  String get biometricAuthDesc => 'Login with fingerprint or face recognition';

  @override
  String get twoFactorAuth => 'Two-Factor Authentication';

  @override
  String get twoFactorAuthDesc => 'Extra protection for your account';

  @override
  String get activeSessions => 'Active Sessions';

  @override
  String get activeSessionsDesc => 'Devices where you are logged in';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountWarning =>
      'This action cannot be undone. All your data will be deleted.';

  @override
  String get deleteAccountConfirm =>
      'Are you sure you want to delete your account?';

  @override
  String get accountSecurity => 'Account Security';

  @override
  String get privacySettings => 'Privacy Settings';

  @override
  String get dataPrivacy => 'Data Privacy';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get faq => 'FAQ';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get callUs => 'Call Us';

  @override
  String get emailUs => 'Email Us';

  @override
  String get telegram => 'Telegram';

  @override
  String get aboutApp => 'About App';

  @override
  String get appVersion => 'App Version';

  @override
  String get faqDelivery => 'How long does delivery take?';

  @override
  String get faqDeliveryAnswer =>
      'Standard delivery takes 2-3 business days. Express delivery is completed within 1 day.';

  @override
  String get faqPayment => 'What payment methods are available?';

  @override
  String get faqPaymentAnswer =>
      'Currently, cash on delivery is accepted. Other payment methods will be added soon.';

  @override
  String get faqReturn => 'Can I return a product?';

  @override
  String get faqReturnAnswer =>
      'Yes, you can return a product within 14 days. The product must be unused and in its original packaging.';

  @override
  String get faqWarranty => 'Is there a warranty?';

  @override
  String get faqWarrantyAnswer =>
      'All our products are covered by manufacturer warranty.';

  @override
  String get cashOnDeliveryDesc => 'Pay when you receive your order';

  @override
  String get clickPayment => 'Pay via Click';

  @override
  String get clickPaymentDesc => 'Pay through the Click app';

  @override
  String get bankCard => 'Bank Card';

  @override
  String get bankCardDesc => 'Pay with Visa or Mastercard';

  @override
  String get paymentMethodSelected => 'Payment method selected';

  @override
  String get defaultPayment => 'Default';

  @override
  String get noReviewsWritten => 'You haven\'t written any reviews yet';

  @override
  String get noReviewsWrittenDesc =>
      'Leave reviews for products you\'ve purchased';

  @override
  String get notificationsEmpty => 'No new notifications';

  @override
  String get notificationsEmptyDesc => 'New messages will appear here';

  @override
  String get markAllRead => 'Mark all as read';

  @override
  String get orderStatusChanged => 'Order status changed';

  @override
  String get newPromotion => 'New promotion';

  @override
  String get systemNotification => 'System notification';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get earlier => 'Earlier';

  @override
  String get requiresBackendIntegration => 'Requires backend integration';

  @override
  String get featureAvailableSoon => 'This feature will be available soon';

  @override
  String get english => 'English';

  @override
  String get storeProducts => 'Store Products';

  @override
  String get noProductsInStore => 'No products in this store yet';

  @override
  String get platformSettings => 'Platform Settings';

  @override
  String get general => 'General';

  @override
  String get maintenanceMode => 'Maintenance Mode';

  @override
  String get maintenanceModeDesc => 'Temporarily disable the application';

  @override
  String get share => 'Share';

  @override
  String get submitRequest => 'Submit Request';

  @override
  String get refundReason => 'Reason for Return';

  @override
  String get selectReason => 'Select a reason';

  @override
  String get refundDescription => 'Enter description';

  @override
  String get refundSubmitted => 'Return request submitted';

  @override
  String get addCard => 'Add Card';

  @override
  String get cardNumber => 'Card Number';

  @override
  String get expiryDate => 'Expiry Date';

  @override
  String get cvv => 'CVV';

  @override
  String get cardholderName => 'Cardholder Name';

  @override
  String payAmount(Object amount) {
    return 'Pay $amount';
  }

  @override
  String get changeBtn => 'Change';

  @override
  String get editBtn => 'Edit';

  @override
  String get orderConfirmed => 'Order Confirmed';

  @override
  String get paymentFailed => 'Payment Failed';

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
  String get analyticsAndReports => 'Analytics & Reports';

  @override
  String get productSavedSuccessfully => 'Product saved successfully';

  @override
  String get startTypingToSearch => 'Start typing to search.';

  @override
  String get myProducts => 'My Products';

  @override
  String get noProductsAddedYet => 'You have not added any products yet.';

  @override
  String get inStockOnly => 'In Stock Only';

  @override
  String get hasDiscount => 'Has Discount';

  @override
  String get wholesale => 'Wholesale';

  @override
  String get retail => 'Retail';

  @override
  String get applyFilters => 'Apply Filters';

  @override
  String get registrationSubmitted => 'Registration submitted';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get verificationStatus => 'Verification Status';

  @override
  String get storeProfileUpdated => 'Store Profile Updated';

  @override
  String get manageStoreProfile => 'Manage Store Profile';

  @override
  String get personalizeYourFeed => 'Personalize Your Feed';

  @override
  String get myAddresses => 'My Addresses';

  @override
  String get noCategoriesAvailable => 'No categories available';

  @override
  String get buyNow => 'Buy Now';

  @override
  String get addAddress => 'Add Address';

  @override
  String get addressLabel => 'Label (e.g. Home, Office)';

  @override
  String get district => 'District';

  @override
  String get streetBuilding => 'Street/Building';

  @override
  String get saveAddress => 'Save Address';

  @override
  String get fieldRequired => 'Required';

  @override
  String get compareProducts => 'Compare Products';

  @override
  String get feature => 'Feature';

  @override
  String get productA => 'Product A';

  @override
  String get productB => 'Product B';

  @override
  String get weight => 'Weight';

  @override
  String get grade => 'Grade';

  @override
  String get store => 'Store';

  @override
  String get damagedItem => 'Damaged item';

  @override
  String get wrongItem => 'Wrong item';

  @override
  String get lateDelivery => 'Late delivery';

  @override
  String get invoice => 'Invoice';

  @override
  String get noReviewsYetStore => 'No reviews yet.';

  @override
  String get accountNotFound => 'Account not found with this number';

  @override
  String get fillAllFields => 'Please fill in all fields';

  @override
  String get accountExists => 'This number is already registered';

  @override
  String get registrationSubtitle => 'Create a new account';

  @override
  String get nameHint => 'Enter your name';

  @override
  String get surnameHint => 'Enter your surname';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get name => 'Name';

  @override
  String get surname => 'Surname';

  @override
  String get whatMaterials => 'What materials are you looking for?';

  @override
  String get selectCategories =>
      'Select the categories you are interested in so we can tailor your experience.';

  @override
  String get continueAction => 'Continue';

  @override
  String get categoryCement => 'Cement & Mortar';

  @override
  String get categoryBricks => 'Bricks & Blocks';

  @override
  String get categorySteel => 'Reinforcement Steel';

  @override
  String get categorySand => 'Sand & Gravel';

  @override
  String get categoryConcrete => 'Concrete';

  @override
  String get categoryRoofing => 'Roofing Materials';

  @override
  String get categoryWood => 'Wood & Plywood';

  @override
  String get categoryPlumbing => 'Plumbing & Pipes';

  @override
  String get categoryElectrical => 'Electrical Materials';

  @override
  String get categoryPaint => 'Paint & Finishes';

  @override
  String get authRequiredToContinue =>
      'Please sign in to continue with your order.';

  @override
  String get onboardingTitle => 'All Construction Materials\nin One Place';

  @override
  String get onboardingSubtitle =>
      'Buy cement, bricks, and steel from verified suppliers at wholesale prices.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get errorOccurred => 'An error occurred';

  @override
  String get categoriesNotFound => 'Categories not found';

  @override
  String get piece => 'piece';

  @override
  String get guestModeTitle => 'Please Log In';

  @override
  String get guestCartDesc => 'Log in to view and manage your cart.';

  @override
  String get guestWishlistDesc => 'Log in to view your favorite products.';

  @override
  String get discountsChip => 'Discounts';

  @override
  String get expressDeliveryChip => 'Fast Delivery';

  @override
  String get directFactoryChip => 'Direct from Factory';

  @override
  String get popularChip => 'Popular';

  @override
  String get servicesChip => 'Master Services';

  @override
  String get qualityGuaranteeBadge => '100% Quality Guarantee';

  @override
  String get fastDeliveryBadge => 'Express Shipping';

  @override
  String get securePaymentBadge => 'Secure Payment';

  @override
  String get orderStatusAll => 'All';

  @override
  String get orderStatusPending => 'Pending';

  @override
  String get orderStatusConfirmed => 'Confirmed';

  @override
  String get orderStatusProcessing => 'Processing';

  @override
  String get orderStatusDelivered => 'Delivered';

  @override
  String get orderStatusCancelled => 'Cancelled';

  @override
  String get addedToCart => 'Added to cart';

  @override
  String get promoBannerTitle => 'Qurilish uchun kerakli';

  @override
  String get promoBannerSubtitle => 'Eng yaxshi narxlar kafolati';

  @override
  String get promoBannerButton => 'Shop now';

  @override
  String get popularProductsSection => 'Popular Products';

  @override
  String get recentSearches => 'Recent searches';

  @override
  String get bulkDiscount => 'Buy 10+ items: 5% discount';

  @override
  String get specificationsLabel => 'Specifications';

  @override
  String get warranty => 'Warranty';

  @override
  String get manufacturer => 'Manufacturer';

  @override
  String get deliveryLabel => 'Delivery';

  @override
  String get leaveReviewBtn => 'Leave a review';

  @override
  String get buyNowBtn => 'Buy Now';

  @override
  String get taxFee => 'Tax / Fee';

  @override
  String get deliveryService => 'Delivery Service';

  @override
  String get pickupFromWarehouse => 'Pickup from warehouse';

  @override
  String get smsVerification => 'SMS Verification';

  @override
  String get smsVerificationDesc =>
      'To enable two-factor authentication, an SMS code will be sent to your phone. Do you want to continue?';

  @override
  String get continueBtn => 'Continue';

  @override
  String get thisDevice => 'This device:';

  @override
  String get activeSession => 'Active session';

  @override
  String get sendErrorReports => 'Send error reports';

  @override
  String get sendErrorReportsDesc =>
      'Send anonymous error data to improve the app.';

  @override
  String get createAdProfile => 'Create advertising profile';

  @override
  String get createAdProfileDesc => 'To show you personalized ads.';

  @override
  String get contactViaTelegram => 'Contact via Telegram';

  @override
  String get ourInstagramPage => 'Our Instagram page';

  @override
  String get customerSupport => 'Customer Support';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsOfUse => 'Terms of Use';

  @override
  String get brandDefault => 'No brand';
}
