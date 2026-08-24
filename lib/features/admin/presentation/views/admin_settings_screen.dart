import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class AdminSettingsScreen extends ConsumerStatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  ConsumerState<AdminSettingsScreen> createState() =>
      _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends ConsumerState<AdminSettingsScreen> {
  bool _maintenanceMode = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          l10n.platformSettings,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: context.colors.background,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              l10n.general,
              style: TextStyle(
                color: context.colors.textMedium,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          SwitchListTile(
            secondary:
                Icon(Icons.build_outlined, color: context.colors.textMedium),
            title: Text(
              l10n.maintenanceMode,
              style: TextStyle(color: context.colors.textHigh, fontSize: 15),
            ),
            subtitle: Text(
              l10n.maintenanceModeDesc,
              style: TextStyle(color: context.colors.textMedium, fontSize: 13),
            ),
            value: _maintenanceMode,
            activeThumbColor: context.colors.primary,
            onChanged: (val) {
              setState(() => _maintenanceMode = val);
              /* ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.requiresBackendIntegration),
                  backgroundColor: context.colors.primary,
                ),
              ); */
            },
          ),
        ],
      ),
    );
  }
}
