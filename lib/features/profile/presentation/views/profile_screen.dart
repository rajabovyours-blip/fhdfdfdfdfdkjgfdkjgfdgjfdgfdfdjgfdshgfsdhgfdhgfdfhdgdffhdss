import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/core/providers/theme_provider.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/features/profile/presentation/widgets/account_summary_card.dart';
import 'package:milliy_metr/features/profile/presentation/widgets/profile_menu_item.dart';
import 'package:milliy_metr/shared/widgets/app_button.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          context.l10n.profile,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: context.colors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: authState.when(
        initial: () => Center(
          child: CircularProgressIndicator(color: context.colors.primary),
        ),
        loading: () => Center(
          child: CircularProgressIndicator(color: context.colors.primary),
        ),
        unauthenticated: () => _buildUnauthenticatedState(context),
        authenticated: (user) => _buildAuthenticatedState(context, ref, user),
        error: (message) => _buildErrorState(context, message, ref),
      ),
    );
  }

  Widget _buildUnauthenticatedState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: context.colors.textMedium,
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.welcome,
              style: TextStyle(
                color: context.colors.textHigh,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.loginToViewProfile,
              style: TextStyle(color: context.colors.textMedium, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: context.l10n.loginAction,
                onPressed: () => context.push(AppRoutes.login),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 80, color: context.colors.danger),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(color: context.colors.danger, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: AppButton(
                text: 'OK',
                onPressed: () => ref.read(authProvider.notifier).clearError(),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildAuthenticatedState(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
  ) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(context, user),
          const SizedBox(height: 24),
          _buildAccountSummary(context),
          const SizedBox(height: 24),
          _buildSectionDivider(context),
          _buildOrdersSection(context),
          _buildSectionDivider(context),
          _buildAccountSection(context),
          _buildSectionDivider(context),
          _buildSettingsSection(context, ref),
          _buildSectionDivider(context),
          _buildSupportSection(context),
          const SizedBox(height: 24),
          _buildLogoutButton(context, ref),
          const SizedBox(height: 48), // Bottom padding
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, dynamic user) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: context.colors.surfaceVariant,
            backgroundImage:
                user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
            child: user.avatarUrl == null
                ? Icon(Icons.person, size: 40, color: context.colors.textMedium)
                : null,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName ?? context.l10n.user,
                  style: TextStyle(
                    color: context.colors.textHigh,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (user.email != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    user.email!,
                    style: TextStyle(
                      color: context.colors.textMedium,
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  user.phone ?? '',
                  style:
                      TextStyle(color: context.colors.textMedium, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit_outlined, color: context.colors.primary),
            onPressed: () => context.push(AppRoutes.profilePersonalInfo),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSummary(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          AccountSummaryCard(
            icon: Icons.shopping_bag_outlined,
            label: context.l10n.orders,
            value: '-', 
            onTap: () => context.push(AppRoutes.orders),
          ),
          const SizedBox(width: 12),
          AccountSummaryCard(
            icon: Icons.favorite_border_rounded,
            label: context.l10n.wishlist,
            value: '-', 
            onTap: () => context.push('/wishlist'),
          ),
          const SizedBox(width: 12),
          AccountSummaryCard(
            icon: Icons.location_on_outlined,
            label: context.l10n.addresses,
            value: '-', 
            onTap: () => context.push(AppRoutes.addresses),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionDivider(BuildContext context) {
    return Container(
      height: 8,
      color: context.colors.surface,
    );
  }

  Widget _buildOrdersSection(BuildContext context) {
    return Column(
      children: [
        ProfileMenuItem(
          icon: Icons.local_shipping_outlined,
          title: context.l10n.orders,
          onTap: () => context.push(AppRoutes.orders),
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Column(
      children: [
        ProfileMenuItem(
          icon: Icons.person_outline,
          title: context.l10n.personalInfo, // Will add personal info key later
          onTap: () => context.push(AppRoutes.profilePersonalInfo),
        ),
        ProfileMenuItem(
          icon: Icons.location_on_outlined,
          title: context.l10n.addresses,
          onTap: () => context.push(AppRoutes.addresses),
        ),
        ProfileMenuItem(
          icon: Icons.payment_outlined,
          title: context.l10n.paymentMethods,
          onTap: () => context.push(AppRoutes.profilePaymentMethods),
        ),
        ProfileMenuItem(
          icon: Icons.star_outline,
          title: context.l10n.myReviews,
          onTap: () => context.push(AppRoutes.profileReviews),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        ProfileMenuItem(
          icon: Icons.palette_outlined,
          title: context.l10n.appearance,
          trailing: Row(
            children: [
              Text(
                _getThemeName(context, ref.watch(themeModeProvider)),
                style: TextStyle(
                  color: context.colors.textMedium,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: context.colors.textMedium,
                size: 20,
              ),
            ],
          ),
          onTap: () => _showAppearanceBottomSheet(context, ref),
        ),
        ProfileMenuItem(
          icon: Icons.notifications_none_outlined,
          title: context.l10n.notifications,
          onTap: () => context.push(AppRoutes.profileNotifications),
        ),
        ProfileMenuItem(
          icon: Icons.language_outlined,
          title: context.l10n.language,
          trailing: Row(
            children: [
              Text(
                context.l10n.language,
                style: TextStyle(
                  color: context.colors.textMedium,
                  fontSize: 14,
                ),
              ), // Just standard indicator
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: context.colors.textMedium,
                size: 20,
              ),
            ],
          ),
          onTap: () => context.push(AppRoutes.profileLanguage),
        ),
        ProfileMenuItem(
          icon: Icons.security_outlined,
          title: context.l10n.securityAndPrivacy,
          onTap: () => context.push(AppRoutes.profileSecurity),
        ),
      ],
    );
  }

  String _getThemeName(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return context.l10n.themeLight;
      case ThemeMode.dark:
        return context.l10n.themeDark;
      default:
        return context.l10n.themeSystem;
    }
  }

  void _showAppearanceBottomSheet(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(themeModeProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    context.l10n.appearance,
                    style: TextStyle(
                      color: context.colors.textHigh,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildThemeOption(
                  context,
                  ref,
                  context.l10n.themeSystem,
                  ThemeMode.system,
                  currentMode,
                ),
                _buildThemeOption(
                  context,
                  ref,
                  context.l10n.themeLight,
                  ThemeMode.light,
                  currentMode,
                ),
                _buildThemeOption(
                  context,
                  ref,
                  context.l10n.themeDark,
                  ThemeMode.dark,
                  currentMode,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref,
    String title,
    ThemeMode mode,
    ThemeMode currentMode,
  ) {
    final isSelected = mode == currentMode;
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? context.colors.primary : context.colors.textHigh,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle, color: context.colors.primary)
          : null,
      onTap: () {
        ref.read(themeModeProvider.notifier).setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Column(
      children: [
        ProfileMenuItem(
          icon: Icons.help_outline,
          title: context.l10n.helpAndSupport,
          onTap: () => context.push(AppRoutes.profileHelp),
        ),
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: OutlinedButton(
        onPressed: () => _showLogoutDialog(context, ref),
        style: OutlinedButton.styleFrom(
          foregroundColor: context.colors.danger,
          side: BorderSide(color: context.colors.danger),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          context.l10n.logout,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text(
          context.l10n.logout,
          style: TextStyle(color: context.colors.textHigh),
        ),
        content: Text(
          context.l10n.logoutConfirm,
          style: TextStyle(color: context.colors.textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              context.l10n.cancel,
              style: TextStyle(color: context.colors.textMedium),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            child: Text(
              context.l10n.exit,
              style: TextStyle(color: context.colors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
