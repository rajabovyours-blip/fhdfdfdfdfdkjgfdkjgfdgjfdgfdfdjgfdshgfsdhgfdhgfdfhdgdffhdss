
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/users/presentation/users_screen.dart';
import '../../features/sellers/presentation/sellers_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/banners/presentation/banners_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';
      
      if (!authState && !isLoggingIn) return '/login';
      if (authState && isLoggingIn) return '/dashboard';
      
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/users',
        builder: (context, state) => const UsersScreen(),
      ),
      GoRoute(
        path: '/sellers',
        builder: (context, state) => const SellersScreen(),
      ),
      GoRoute(
        path: '/products',
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/banners',
        builder: (context, state) => const BannersScreen(),
      ),
    ],
  );
});
