import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';

class AuthGuard {
  static bool _isProtectedRoute(String path) {
    // Exclude admin paths from customer auth guard
    if (path.startsWith('/admin')) {
      return false;
    }

    final protectedPrefixes = [
      AppRoutes.checkout,
      AppRoutes.addresses,
      AppRoutes.addAddress,
      AppRoutes.orders,
      '/order/',
      AppRoutes.orderSuccess,
      '/buy-now/',
      '/return-request',
      '/invoice/',
      '/tracking/',
      AppRoutes.profilePersonalInfo,
      AppRoutes.profilePaymentMethods,
      AppRoutes.profileReviews,
      AppRoutes.profileNotifications,
      AppRoutes.profileSecurity,
    ];

    return protectedPrefixes.any((prefix) => path.startsWith(prefix));
  }

  static Future<String?> redirect(
    BuildContext context,
    GoRouterState state,
    Ref ref,
  ) async {
    final authState = ref.read(authProvider);
    final currentPath = state.uri.path;

    final isGoingToLogin = currentPath == AppRoutes.login;
    final isGoingToSplash = currentPath == AppRoutes.splash;

    final isGoingToOtp = currentPath == AppRoutes.otp;
    final isGoingToRegister = currentPath == AppRoutes.register;



    return authState.maybeWhen(
      initial: () => AppRoutes.splash,
      loading: () => null,
      unauthenticated: () {
        // If it's a protected route, force login and pass the original URL as redirect
        if (_isProtectedRoute(currentPath)) {
          return '${AppRoutes.login}?redirect=${Uri.encodeComponent(state.uri.toString())}';
        }
        return null;
      },
      authenticated: (_) {
        if (isGoingToLogin ||
            isGoingToSplash ||
            isGoingToOtp ||
            isGoingToRegister) {
          
          final redirect = state.uri.queryParameters['redirect'];
          if (redirect != null && redirect.isNotEmpty) {
            return redirect;
          }
          return AppRoutes.home;
        }
        return null;
      },
      orElse: () => null,
    );
  }
}
