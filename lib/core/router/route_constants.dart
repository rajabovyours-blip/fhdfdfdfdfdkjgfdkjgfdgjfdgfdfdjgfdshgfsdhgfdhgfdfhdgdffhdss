class AppRoutes {
  static const splash = '/splash';
  static const language = '/language';
  static const login = '/login';
  static const register = '/register';

  static const otp = '/otp';
  static const home = '/home';
  static const search = '/search';
  static const notifications = '/notifications';
  static const categories = '/categories';
  static const catalog = '/catalog';
  static const categoryProducts = '/catalog/category/:id';
  static const productDetails = '/catalog/product/:id';
  static const comparison = '/comparison';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const addresses = '/addresses';
  static const addAddress = '/add-address';
  static const orders = '/orders';
  static const orderDetails = '/order/:id';
  static const orderSuccess = '/order-success';
  static const profile = '/profile';

  static const profilePersonalInfo = '/profile/personal-info';
  static const profilePaymentMethods = '/profile/payment-methods';
  static const profileReviews = '/profile/reviews';
  static const profileNotifications = '/profile/notifications';
  static const profileLanguage = '/profile/language';
  static const profileSecurity = '/profile/security';
  static const profileHelp = '/profile/help';

  // Admin Routes
  static const adminDashboard = '/admin';
  static const adminUsers = '/admin/users';
  static const adminProducts = '/admin/products';
  static const adminCategories = '/admin/categories';
  static const adminOrders = '/admin/orders';
  static const adminPayments = '/admin/payments';
  static const adminComplaints = '/admin/complaints';
  static const adminReports = '/admin/reports';
  static const adminRoles = '/admin/roles';
  static const adminPermissions = '/admin/permissions';
  static const adminAuditLogs = '/admin/audit-logs';
  static const adminSettings = '/admin/settings';
}
