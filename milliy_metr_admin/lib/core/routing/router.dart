import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/users/presentation/users_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/products/presentation/import_excel_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/banners/presentation/banners_screen.dart';
import '../../features/reviews/presentation/reviews_screen.dart';
import '../../features/notifications/presentation/views/notifications_screen.dart';
import '../../shared/layouts/admin_layout.dart';
import '../../features/orders/presentation/orders_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/admin_users/presentation/admin_users_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(authStateProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isLoginRoute = state.matchedLocation == '/login';

      if (!isAuthenticated && !isLoginRoute) {
        return '/login';
      }

      if (isAuthenticated && isLoginRoute) {
        return '/dashboard';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return AdminLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/users',
            builder: (context, state) => const UsersScreen(),
          ),
          GoRoute(
            path: '/products',
            builder: (context, state) => const ProductsScreen(),
          ),
          GoRoute(
            path: '/products/import',
            builder: (context, state) => const ImportExcelScreen(),
          ),
          GoRoute(
            path: '/categories',
            builder: (context, state) => const CategoriesScreen(),
          ),
          GoRoute(
            path: '/banners',
            builder: (context, state) => const BannersScreen(),
          ),
          GoRoute(
            path: '/reviews',
            builder: (context, state) => const ReviewsScreen(),
          ),
          GoRoute(
            path: '/orders',
            builder: (context, state) => const OrdersScreen(),
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: '/admin_users',
            builder: (context, state) => const AdminUsersScreen(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => const DashboardScreen(),
  );
});

