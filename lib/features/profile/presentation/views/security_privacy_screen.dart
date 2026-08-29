import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/shared/widgets/app_snackbar.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/core/storage/preferences.dart';

class SecurityPrivacyScreen extends StatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  State<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends State<SecurityPrivacyScreen> {
  bool _biometricEnabled = false;
  bool _twoFactorEnabled = false;

  @override
  void initState() {
    super.initState();
    _biometricEnabled = PreferencesManager.getBool('biometric_enabled');
  }

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
            onChanged: (val) async {
              if (val) {
                final LocalAuthentication auth = LocalAuthentication();
                final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
                final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
                
                if (canAuthenticate) {
                  try {
                    final bool didAuthenticate = await auth.authenticate(
                      localizedReason: 'Biometrik ma\'lumotlarni tasdiqlang',
                      options: const AuthenticationOptions(biometricOnly: true),
                    );
                    if (didAuthenticate) {
                      setState(() => _biometricEnabled = true);
                      await PreferencesManager.setBool('biometric_enabled', true);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Biometrik kirish yoqildi'),
                            backgroundColor: context.colors.success,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Biometrik xatolik: $e'), backgroundColor: context.colors.danger),
                      );
                    }
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: const Text('Qurilmada biometriya qo\'llab-quvvatlanmaydi'), backgroundColor: context.colors.danger),
                    );
                  }
                }
              } else {
                setState(() => _biometricEnabled = false);
                await PreferencesManager.setBool('biometric_enabled', false);
              }
            },
          ),
          _buildSwitchTile(
            icon: Icons.verified_user_outlined,
            title: l10n.twoFactorAuth,
            subtitle: l10n.twoFactorAuthDesc,
            value: _twoFactorEnabled,
            onChanged: (val) {
              if (val) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(l10n.smsVerification),
                    content: Text(l10n.smsVerificationDesc),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l10n.cancel)),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          setState(() => _twoFactorEnabled = true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: const Text('Ikki bosqichli autentifikatsiya yoqildi'), backgroundColor: context.colors.success),
                          );
                        },
                        child: Text(l10n.continueBtn),
                      ),
                    ],
                  ),
                );
              } else {
                setState(() => _twoFactorEnabled = false);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Ikki bosqichli autentifikatsiya o\'chirildi')),
                );
              }
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.activeSessions,
                  style: TextStyle(
                    color: context.colors.textHigh,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.colors.outline),
                  ),
                  child: ListTile(
                    leading: Icon(Icons.phone_iphone_rounded, color: context.colors.textHigh),
                    title: Text(
                      '${l10n.thisDevice} ',
                      style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                    subtitle: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: context.colors.success,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text('${l10n.activeSession} (Toshkent)', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
              bool sendErrors = true;
              bool createAd = false;
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (ctx) => StatefulBuilder(
                  builder: (context, setStateSheet) => Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(l10n.dataPrivacy, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        ListTile(
                          title: Text(l10n.sendErrorReports),
                          subtitle: Text(l10n.sendErrorReportsDesc),
                          trailing: Switch.adaptive(
                            value: sendErrors,
                            activeColor: context.colors.primary,
                            onChanged: (v) => setStateSheet(() => sendErrors = v),
                          ),
                          onTap: () => setStateSheet(() => sendErrors = !sendErrors),
                        ),
                        ListTile(
                          title: Text(l10n.createAdProfile),
                          subtitle: Text(l10n.createAdProfileDesc),
                          trailing: Switch.adaptive(
                            value: createAd,
                            activeColor: context.colors.primary,
                            onChanged: (v) => setStateSheet(() => createAd = v),
                          ),
                          onTap: () => setStateSheet(() => createAd = !createAd),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(ctx),
                            style: ElevatedButton.styleFrom(backgroundColor: context.colors.primary, foregroundColor: Colors.white),
                            child: Text(l10n.save),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
    return ListTile(
      leading: Icon(icon, color: context.colors.textMedium),
      title: Text(
        title,
        style: TextStyle(color: context.colors.textHigh, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: context.colors.textMedium, fontSize: 13),
      ),
      trailing: Switch.adaptive(
        value: value,
        activeColor: context.colors.primary,
        onChanged: onChanged,
      ),
      onTap: () => onChanged(!value),
    );
  }

  void _showChangePasswordSheet(BuildContext context) {
    final l10n = context.l10n;
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setStateSheet) {
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
                  _buildPasswordField(
                    controller: currentCtrl,
                    label: l10n.currentPassword,
                    obscureText: obscureCurrent,
                    onToggle: () => setStateSheet(() => obscureCurrent = !obscureCurrent),
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordField(
                    controller: newCtrl,
                    label: l10n.newPassword,
                    obscureText: obscureNew,
                    onToggle: () => setStateSheet(() => obscureNew = !obscureNew),
                  ),
                  const SizedBox(height: 12),
                  _buildPasswordField(
                    controller: confirmCtrl,
                    label: l10n.confirmPassword,
                    obscureText: obscureConfirm,
                    onToggle: () => setStateSheet(() => obscureConfirm = !obscureConfirm),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: isSaving ? null : () async {
                      if (newCtrl.text.length < 8) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        AppSnackBar.showError(context, l10n.passwordTooShort);
                        return;
                      }
                      if (newCtrl.text != confirmCtrl.text) {
                        AppSnackBar.showError(context, l10n.passwordsDoNotMatch);
                        return;
                      }
                      
                      setStateSheet(() => isSaving = true);
                      try {
                        final dio = ProviderScope.containerOf(context).read(dioProvider);
                        final response = await dio.post('/auth/change-password', data: {
                          'old_password': currentCtrl.text,
                          'new_password': newCtrl.text,
                        },);
                        if (response.statusCode == 200) {
                          if (context.mounted) {
                            Navigator.pop(ctx);
                            AppSnackBar.showSuccess(context, "Parol muvaffaqiyatli o'zgartirildi");
                          }
                        }
                      } catch (e) {
                        if (context.mounted) {
                          AppSnackBar.showError(context, "Xatolik yuz berdi yoxud parol noto'g'ri");
                        }
                      } finally {
                        setStateSheet(() => isSaving = false);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: context.colors.background,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSaving
                        ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: context.colors.background, strokeWidth: 2))
                        : Text(l10n.save),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: context.colors.textHigh),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: context.colors.textMedium),
        filled: true,
        fillColor: context.colors.surfaceVariant,
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: context.colors.textMedium,
          ),
          onPressed: onToggle,
        ),
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
