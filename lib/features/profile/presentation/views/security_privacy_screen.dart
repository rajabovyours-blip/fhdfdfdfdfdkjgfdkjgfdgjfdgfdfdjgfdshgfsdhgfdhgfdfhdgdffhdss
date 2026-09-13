import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:local_auth/local_auth.dart';
import 'package:milliy_metr/core/storage/preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class SecurityPrivacyScreen extends StatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  State<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends State<SecurityPrivacyScreen> {
  bool _biometricEnabled = false;
  String _deviceModel = '';
  String _cityName = '';

  @override
  void initState() {
    super.initState();
    _biometricEnabled = PreferencesManager.getBool('biometric_enabled');
    _loadDeviceInfo();
    _loadLocation();
  }

  Future<void> _loadDeviceInfo() async {
    // dart:io Platform ishlamaydi (veb sahifada "Unsupported operation"
    // xatosi bilan qulab tushadi) — veb brauzerda qurilma modeli o'rniga
    // brauzer haqidagi ma'lumotni ko'rsatamiz.
    if (kIsWeb) {
      final deviceInfo = DeviceInfoPlugin();
      String model = 'Veb brauzer';
      try {
        final webInfo = await deviceInfo.webBrowserInfo;
        model = webInfo.browserName.name.isNotEmpty
            ? '${webInfo.browserName.name[0].toUpperCase()}${webInfo.browserName.name.substring(1)} brauzeri'
            : 'Veb brauzer';
      } catch (_) {
        // Brauzer ma'lumotini olib bo'lmasa ham, ekran ishlashda davom etadi
      }
      if (mounted) {
        setState(() => _deviceModel = model);
      }
      return;
    }

    final deviceInfo = DeviceInfoPlugin();
    String model;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final iosInfo = await deviceInfo.iosInfo;
      model = iosInfo.utsname.machine; // e.g. iPhone15,2
      // Map to human-readable names
      model = _mapIosModel(iosInfo.utsname.machine, iosInfo.model);
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      final androidInfo = await deviceInfo.androidInfo;
      model = '${androidInfo.brand} ${androidInfo.model}';
    } else {
      model = 'Unknown';
    }
    if (mounted) {
      setState(() => _deviceModel = model);
    }
  }

  String _mapIosModel(String machine, String fallback) {
    // Common iOS device mappings
    final Map<String, String> models = {
      'iPhone14,2': 'iPhone 13 Pro',
      'iPhone14,3': 'iPhone 13 Pro Max',
      'iPhone14,4': 'iPhone 13 mini',
      'iPhone14,5': 'iPhone 13',
      'iPhone14,7': 'iPhone 14',
      'iPhone14,8': 'iPhone 14 Plus',
      'iPhone15,2': 'iPhone 14 Pro',
      'iPhone15,3': 'iPhone 14 Pro Max',
      'iPhone15,4': 'iPhone 15',
      'iPhone15,5': 'iPhone 15 Plus',
      'iPhone16,1': 'iPhone 15 Pro',
      'iPhone16,2': 'iPhone 15 Pro Max',
      'iPhone17,1': 'iPhone 16 Pro',
      'iPhone17,2': 'iPhone 16 Pro Max',
      'iPhone17,3': 'iPhone 16',
      'iPhone17,4': 'iPhone 16 Plus',
      'iPhone17,5': 'iPhone 16e',
    };
    return models[machine] ?? fallback;
  }

  Future<void> _loadLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        if (mounted) setState(() => _cityName = '');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      );
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        final city = place.locality ?? place.subAdministrativeArea ?? place.administrativeArea ?? '';
        if (mounted) {
          setState(() => _cityName = city);
        }
      }
    } catch (_) {
      // Location not available — leave empty
    }
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // Account Security Section
          _buildSectionHeader(l10n.accountSecurity),
          _buildSwitchTile(
            icon: Icons.fingerprint,
            title: l10n.biometricAuth,
            subtitle: l10n.biometricAuthDesc,
            value: _biometricEnabled,
            onChanged: (val) async {
              // local_auth veb brauzerda ilova qilinmagan (native plagin
              // topilmadi xatosi bilan qulaydi) — veb saytda bu funksiya
              // faqat mobil ilovada mavjudligini bildiramiz.
              if (kIsWeb) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bu funksiya faqat mobil ilovada mavjud'),
                  ),
                );
                return;
              }
              if (val) {
                // Eagerly update to avoid bounce back
                setState(() => _biometricEnabled = true);
                final LocalAuthentication auth = LocalAuthentication();
                final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
                final bool canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
                
                if (canAuthenticate) {
                  try {
                    await Future.delayed(const Duration(milliseconds: 150));
                    final bool didAuthenticate = await auth.authenticate(
                      localizedReason: 'Biometrik ma\'lumotlarni tasdiqlang',
                      options: const AuthenticationOptions(biometricOnly: true),
                    );
                    if (didAuthenticate) {
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
                    } else {
                      // Revert if cancelled
                      setState(() => _biometricEnabled = false);
                    }
                  } catch (e) {
                    setState(() => _biometricEnabled = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('''${context.l10n.biometricError}: $e'''), backgroundColor: context.colors.danger),
                      );
                    }
                  }
                } else {
                  setState(() => _biometricEnabled = false);
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

          // Active Sessions
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
                    leading: Icon(
                      kIsWeb
                          ? Icons.language_rounded
                          : (defaultTargetPlatform == TargetPlatform.iOS
                              ? Icons.phone_iphone_rounded
                              : Icons.phone_android_rounded),
                      color: context.colors.textHigh,
                    ),
                    title: Text(
                      _deviceModel.isNotEmpty ? _deviceModel : '...',
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
                        Text(
                          '${l10n.activeSession}${_cityName.isNotEmpty ? ' ($_cityName)' : ''}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
        ),
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


  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
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
      activeTrackColor: context.colors.primary,
      onChanged: onChanged,
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
