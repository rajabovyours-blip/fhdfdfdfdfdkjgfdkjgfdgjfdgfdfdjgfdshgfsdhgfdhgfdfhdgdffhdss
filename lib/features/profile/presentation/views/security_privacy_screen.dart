import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class SecurityPrivacyScreen extends StatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  State<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends State<SecurityPrivacyScreen> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          l10n.securityAndPrivacy,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: context.colors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Account Security Section
          _buildSectionHeader(l10n.accountSecurity),
          _buildTile(
            icon: Icons.lock_outline,
            title: l10n.changePassword,
            onTap: () => _showChangePasswordSheet(context),
          ),
          _buildSwitchTile(
            icon: Icons.fingerprint,
            title: l10n.biometricAuth,
            subtitle: l10n.biometricAuthDesc,
            value: _biometricEnabled,
            onChanged: (val) {
              setState(() => _biometricEnabled = val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.featureAvailableSoon),
                  backgroundColor: context.colors.primary,
                ),
              );
            },
          ),
          _buildSwitchTile(
            icon: Icons.verified_user_outlined,
            title: l10n.twoFactorAuth,
            subtitle: l10n.twoFactorAuthDesc,
            value: _twoFactorEnabled,
            onChanged: (val) {
              setState(() => _twoFactorEnabled = val);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.featureAvailableSoon),
                  backgroundColor: context.colors.primary,
                ),
              );
            },
          ),
          _buildTile(
            icon: Icons.devices_outlined,
            title: l10n.activeSessions,
            subtitle: l10n.activeSessionsDesc,
            onTap: () {
              /* ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.requiresBackendIntegration),
                  backgroundColor: context.colors.primary,
                ),
              ); */
            },
          ),

          const SizedBox(height: 8),
          Container(height: 8, color: context.colors.surface),
          const SizedBox(height: 8),

          // Privacy Section
          _buildSectionHeader(l10n.privacySettings),
          _buildTile(
            icon: Icons.privacy_tip_outlined,
            title: l10n.dataPrivacy,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.featureAvailableSoon)),
              );
            },
          ),

          const SizedBox(height: 8),
          Container(height: 8, color: context.colors.surface),
          const SizedBox(height: 24),

          // Delete Account
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: () => _showDeleteAccountDialog(context),
              icon: Icon(
                Icons.delete_forever_outlined,
                color: context.colors.danger,
              ),
              label: Text(l10n.deleteAccount),
              style: OutlinedButton.styleFrom(
                foregroundColor: context.colors.danger,
                side: BorderSide(color: context.colors.danger),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          color: context.colors.textMedium,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: context.colors.textMedium),
      title: Text(
        title,
        style: TextStyle(color: context.colors.textHigh, fontSize: 15),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: context.colors.textMedium, fontSize: 13),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: context.colors.textMedium,
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, color: context.colors.textMedium),
      title: Text(
        title,
        style: TextStyle(color: context.colors.textHigh, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: context.colors.textMedium, fontSize: 13),
      ),
      value: value,
      activeThumbColor: context.colors.primary,
      onChanged: onChanged,
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final l10n = context.l10n;
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            24,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.changePassword,
                style: TextStyle(
                  color: context.colors.textHigh,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildPasswordField(currentCtrl, l10n.currentPassword),
              const SizedBox(height: 12),
              _buildPasswordField(newCtrl, l10n.newPassword),
              const SizedBox(height: 12),
              _buildPasswordField(confirmCtrl, l10n.confirmPassword),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (newCtrl.text.length < 8) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.passwordTooShort),
                        backgroundColor: context.colors.danger,
                      ),
                    );
                    return;
                  }
                  if (newCtrl.text != confirmCtrl.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.passwordsDoNotMatch),
                        backgroundColor: context.colors.danger,
                      ),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  /* ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.requiresBackendIntegration),
                      backgroundColor: context.colors.primary,
                    ),
                  ); */
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.background,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n.save),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      obscureText: true,
      style: TextStyle(color: context.colors.textHigh),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: context.colors.textMedium),
        filled: true,
        fillColor: context.colors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.primary, width: 2),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text(
          l10n.deleteAccount,
          style: TextStyle(color: context.colors.danger),
        ),
        content: Text(
          l10n.deleteAccountWarning,
          style: TextStyle(color: context.colors.textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: context.colors.textMedium),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              /* ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.requiresBackendIntegration),
                  backgroundColor: context.colors.primary,
                ),
              ); */
            },
            child: Text(
              l10n.deleteAccount,
              style: TextStyle(color: context.colors.danger),
            ),
          ),
        ],
      ),
    );
  }
}
