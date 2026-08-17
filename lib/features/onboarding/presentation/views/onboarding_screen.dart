import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/storage/preferences.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/shared/widgets/app_button.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.storefront,
                      size: 120,
                      color: context.colors.primary,
                    ),
                    const SizedBox(height: 40),
                    Text(
                      context.l10n.onboardingTitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.onboardingSubtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              AppButton(
                text: context.l10n.getStarted,
                onPressed: () async {
                  await PreferencesManager.setOnboardingComplete(true);
                  if (context.mounted) {
                    context.go(AppRoutes.personalization);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
