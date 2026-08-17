import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        title: Text(
          l10n.notifications,
          style: TextStyle(
            color: context.colors.textHigh,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: IconThemeData(color: context.colors.textHigh),
        actions: [
          IconButton(
            icon: Icon(Icons.done_all, color: context.colors.primary),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.requiresBackendIntegration),
                  backgroundColor: context.colors.primary,
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: context.colors.outline),
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                size: 48,
                color: context.colors.textMedium,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.notificationsEmpty,
              style: TextStyle(
                color: context.colors.textHigh,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.notificationsEmptyDesc,
              style: TextStyle(
                color: context.colors.textMedium,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
