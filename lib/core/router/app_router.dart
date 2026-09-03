import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/core/router/guards/auth_guard.dart';

import 'package:milliy_metr/features/splash/presentation/views/splash_screen.dart';
import 'package:milliy_metr/features/authentication/presentation/views/login_screen.dart';

import 'package:milliy_metr/features/authentication/presentation/views/otp_screen.dart';
import 'package:milliy_metr/features/home/presentation/views/home_screen.dart';
import 'package:milliy_metr/features/main/presentation/views/main_screen.dart';
import 'package:milliy_metr/features/categories/presentation/views/categories_screen.dart';
import 'package:milliy_metr/features/profile/presentation/views/profile_screen.dart';
import 'package:milliy_metr/features/profile/presentation/views/language_screen.dart';
import 'package:milliy_metr/features/profile/presentation/views/personal_information_screen.dart';
import 'package:milliy_metr/features/profile/presentation/views/payment_methods_screen.dart';
import 'package:milliy_metr/features/profile/presentation/views/security_privacy_screen.dart';
import 'package:milliy_metr/features/profile/presentation/views/help_support_screen.dart';
import 'package:milliy_metr/features/profile/presentation/views/my_reviews_screen.dart';
import 'package:milliy_metr/features/catalog/presentation/views/catalog_screen.dart';
import 'package:milliy_metr/features/search/presentation/views/search_screen.dart';
import 'package:milliy_metr/features/notifications/presentation/views/notifications_screen.dart';
import 'package:milliy_metr/features/catalog/presentation/views/product_details_screen.dart';
import 'package:milliy_metr/features/catalog/presentation/views/category_products_screen.dart';
import 'package:milliy_metr/features/catalog/presentation/views/comparison_screen.dart';
import 'package:milliy_metr/features/checkout/presentation/views/cart_screen.dart';
import 'package:milliy_metr/features/checkout/presentation/views/checkout_screen.dart';
import 'package:milliy_metr/features/checkout/presentation/views/address_list_screen.dart';
import 'package:milliy_metr/features/checkout/presentation/views/add_address_screen.dart';
import 'package:milliy_metr/features/checkout/presentation/views/order_success_screen.dart';
import 'package:milliy_metr/features/checkout/presentation/views/buy_now_screen.dart';
import 'package:milliy_metr/features/checkout/presentation/views/return_request_screen.dart';
import 'package:milliy_metr/features/checkout/presentation/views/invoice_screen.dart';
import 'package:milliy_metr/features/checkout/presentation/views/delivery_tracking_screen.dart';
import 'package:milliy_metr/features/orders/presentation/views/order_history_screen.dart';
import 'package:milliy_metr/features/orders/presentation/views/order_details_screen.dart';
import 'package:milliy_metr/features/wishlist/presentation/views/wishlist_screen.dart';
import 'package:milliy_metr/features/reviews/presentation/views/all_reviews_screen.dart';
import 'package:milliy_metr/features/reviews/presentation/views/review_photo_viewer_screen.dart';

import 'package:milliy_metr/main.dart';
import 'package:milliy_metr/features/admin/presentation/views/admin_audit_logs_screen.dart';
import 'package:milliy_metr/features/admin/presentation/views/admin_categories_screen.dart';
import 'package:milliy_metr/features/admin/presentation/views/admin_complaints_screen.dart';
import 'package:milliy_metr/features/admin/presentation/views/admin_dashboard_screen.dart';
import 'package:milliy_metr/features/admin/presentation/views/admin_orders_screen.dart';
import 'package:milliy_metr/features/admin/presentation/views/admin_payments_screen.dart';
import 'package:milliy_metr/features/admin/presentation/views/admin_permissions_screen.dart';
import 'package:milliy_metr/features/admin/presentation/views/admin_reports_screen.dart';
import 'package:milliy_metr/features/admin/presentation/views/admin_roles_screen.dart';
import 'package:milliy_metr/features/admin/presentation/views/admin_products_screen.dart';
import 'package:milliy_metr/features/admin/presentation/views/admin_settings_screen.dart';
import 'package:milliy_metr/features/admin/presentation/views/admin_users_screen.dart';

import 'package:milliy_metr/core/providers/auth_provider.dart';

// Removed rootNavigatorKey to prevent Navigator global key duplication crashes

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(
      authProvider,
      (previous, next) {
        notifyListeners();
      },
    );
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);
  const isAdminApp = bool.fromEnvironment('IS_ADMIN', defaultValue: false);

  return GoRouter(
    initialLocation: isAdminApp ? AppRoutes.adminDashboard : AppRoutes.splash,
    refreshListenable: notifier,
    redirect: (context, state) {
      // Clear snackbars on route change to prevent them sticking
      WidgetsBinding.instance.addPostFrameCallback((_) {
        scaffoldMessengerKey.currentState?.clearSnackBars();
      });
      // COMPLETELY REMOVE AUTHENTICATION GUARDS FOR ADMIN
      if (isAdminApp) return null;
      return AuthGuard.redirect(context, state, ref);
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => LoginScreen(
          redirect: state.uri.queryParameters['redirect'],
        ),
      ),

      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          final redirect = state.uri.queryParameters['redirect'];
          return OtpScreen(phone: phone, redirect: redirect);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScreen(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.catalog,
                builder: (context, state) => CatalogScreen(
                  categoryId: state.uri.queryParameters['category_id'],
                  filterOption: state.uri.queryParameters['filter'],
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/wishlist',
                builder: (context, state) => const WishlistScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cart,
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.search,
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.categoryProducts,
        builder: (context, state) => CategoryProductsScreen(
          categoryId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.productDetails,
        builder: (context, state) => ProductDetailsScreen(
          productId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.comparison,
        builder: (context, state) => const ComparisonScreen(),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.addresses,
        builder: (context, state) => const AddressListScreen(),
      ),
      GoRoute(
        path: '/add-address',
        builder: (context, state) => const AddAddressScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderSuccess,
        builder: (context, state) => const OrderSuccessScreen(),
      ),
      GoRoute(
        path: AppRoutes.orders,
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/buy-now/:id',
        builder: (context, state) =>
            BuyNowScreen(productId: state.pathParameters['id']!),
      ),

      GoRoute(
        path: '/return-request',
        builder: (context, state) => const ReturnRequestScreen(),
      ),
      GoRoute(
        path: '/invoice/:id',
        builder: (context, state) =>
            InvoiceScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/tracking/:id',
        builder: (context, state) =>
            DeliveryTrackingScreen(orderId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.orderDetails,
        builder: (context, state) =>
            OrderDetailsScreen(orderId: state.pathParameters['id']!),
      ),
      // Profile is handled in ShellRoute, keeping this just in case anything routes directly here.
      // Removed the duplicate profile route to avoid conflict with ShellRoute branch.
      GoRoute(
        path: AppRoutes.profilePersonalInfo,
        builder: (context, state) => const PersonalInformationScreen(),
      ),
      GoRoute(
        path: AppRoutes.profilePaymentMethods,
        builder: (context, state) => const PaymentMethodsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileReviews,
        builder: (context, state) => MyReviewsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileNotifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileLanguage,
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSecurity,
        builder: (context, state) => const SecurityPrivacyScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileHelp,
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/reviews/:id',
        builder: (context, state) =>
            AllReviewsScreen(productId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/review-photo',
        builder: (context, state) =>
            ReviewPhotoViewerScreen(photoUrl: state.extra as String),
      ),

      // Admin Login Route has been COMPLETELY REMOVED per user instructions
      GoRoute(
        path: AppRoutes.adminDashboard,
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminUsers,
        builder: (context, state) => const AdminUsersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminProducts,
        builder: (context, state) => const AdminProductsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminCategories,
        builder: (context, state) => const AdminCategoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminOrders,
        builder: (context, state) => const AdminOrdersScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminPayments,
        builder: (context, state) => const AdminPaymentsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminComplaints,
        builder: (context, state) => const AdminComplaintsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminReports,
        builder: (context, state) => const AdminReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminRoles,
        builder: (context, state) => const AdminRolesScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminPermissions,
        builder: (context, state) => const AdminPermissionsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminAuditLogs,
        builder: (context, state) => const AdminAuditLogsScreen(),
      ),
      GoRoute(
        path: AppRoutes.adminSettings,
        builder: (context, state) => const AdminSettingsScreen(),
      ),
    ],
  );
});
