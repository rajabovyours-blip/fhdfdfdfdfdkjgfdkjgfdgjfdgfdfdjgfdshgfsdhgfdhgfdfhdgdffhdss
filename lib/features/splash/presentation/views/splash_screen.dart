import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';

import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Wait until auth state is determined
    while (ref.read(authProvider).maybeWhen(
          loading: () => true,
          orElse: () => false,
        )) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (!mounted) return;

    // Check auth state and redirect. Since authProvider is watched globally,
    // AuthGuard in app_router will handle the redirection automatically based on auth state.
    // However, to force router to evaluate, we can just do nothing or refresh.
    // The router's AuthGuard already redirects if unauthenticated or authenticated.
    // We shouldn't loop on splash.
    // Actually, in riverpod router, the redirect happens when the provider changes.
    // If the provider is already loaded, it might not re-trigger.
    // We can explicitly navigate to home or login based on current state here:
    const isAdminApp = bool.fromEnvironment('IS_ADMIN', defaultValue: false);
    
    if (isAdminApp) {
      context.go(AppRoutes.adminDashboard);
      return;
    }

    final authState = ref.read(authProvider);
    authState.maybeWhen(
      authenticated: (_) => context.go(AppRoutes.home),
      orElse: () => context.go(AppRoutes.home),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return const Scaffold(
        backgroundColor: Colors.transparent,
      );
    }
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/milliy_metr_logo_transparent.png',
              width: 180,
              errorBuilder: (context, error, stackTrace) {
                return Text(
                  'MILLIY METR',
                  style: TextStyle(
                    color: context.colors.textHigh,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
