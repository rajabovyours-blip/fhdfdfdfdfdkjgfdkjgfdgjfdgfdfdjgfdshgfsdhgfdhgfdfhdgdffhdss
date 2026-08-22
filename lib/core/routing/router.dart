
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/users/presentation/users_screen.dart';
import '../../features/products/presentation/products_screen.dart';
import '../../features/products/presentation/import_excel_screen.dart';
import '../../features/categories/presentation/categories_screen.dart';
import '../../features/banners/presentation/banners_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/dashboard',
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
    ],
  );
});
