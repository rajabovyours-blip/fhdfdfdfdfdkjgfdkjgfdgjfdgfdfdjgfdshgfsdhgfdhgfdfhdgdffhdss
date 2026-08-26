import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/core/providers/locale_provider.dart';
import 'package:milliy_metr/core/storage/preferences.dart';
import 'package:milliy_metr/l10n/app_localizations.dart';

class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);
    final savedLang = PreferencesManager.getLanguage();
    final isSystem = (savedLang == null || savedLang.isEmpty);

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          l10n.language,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: context.colors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.selectLanguage,
              style: TextStyle(
                color: context.colors.textHigh,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildLanguageOption(
              context: context,
              ref: ref,
              title: l10n.systemLanguage,
              code: 'system',
              isSelected: isSystem,
            ),
            _buildLanguageOption(
              context: context,
              ref: ref,
              title: "O'zbekcha",
              code: 'uz',
              isSelected: !isSystem && currentLocale.languageCode == 'uz',
            ),
            _buildLanguageOption(
              context: context,
              ref: ref,
              title: 'Русский',
              code: 'ru',
              isSelected: !isSystem && currentLocale.languageCode == 'ru',
            ),
            _buildLanguageOption(
              context: context,
              ref: ref,
              title: 'English',
              code: 'en',
              isSelected: !isSystem && currentLocale.languageCode == 'en',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String code,
    required bool isSelected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? context.colors.primary : context.colors.outline,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            color: context.colors.textHigh,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check_circle, color: context.colors.primary)
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () {
          ref.read(localeProvider.notifier).setLocale(code);
        },
      ),
    );
  }
}
