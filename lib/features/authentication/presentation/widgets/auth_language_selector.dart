import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/locale_provider.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';

class AuthLanguageSelector extends ConsumerWidget {
  const AuthLanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(localeProvider);

    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.colors.outline, width: 1),
      ),
      child: PopupMenuButton<String>(
        onSelected: (String langCode) {
          ref.read(localeProvider.notifier).setLocale(langCode);
        },
        color: context.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        offset: const Offset(0, 40),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          _buildMenuItem(context, 'uz', 'O‘zbekcha', currentLocale.languageCode == 'uz'),
          _buildMenuItem(context, 'ru', 'Русский', currentLocale.languageCode == 'ru'),
          _buildMenuItem(context, 'en', 'English', currentLocale.languageCode == 'en'),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language_rounded,
                size: 18,
                color: context.colors.textHigh,
              ),
              const SizedBox(width: 8),
              Text(
                _getLanguageName(currentLocale.languageCode),
                style: TextStyle(
                  color: context.colors.textHigh,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18,
                color: context.colors.textMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  PopupMenuItem<String> _buildMenuItem(
    BuildContext context,
    String code,
    String label,
    bool isSelected,
  ) {
    return PopupMenuItem<String>(
      value: code,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isSelected ? context.colors.primary : context.colors.textHigh,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              fontSize: 15,
            ),
          ),
          if (isSelected)
            Icon(
              Icons.check_rounded,
              color: context.colors.primary,
              size: 20,
            ),
        ],
      ),
    );
  }

  String _getLanguageName(String code) {
    switch (code) {
      case 'uz':
        return 'O‘zbekcha';
      case 'ru':
        return 'Русский';
      case 'en':
        return 'English';
      default:
        return 'O‘zbekcha';
    }
  }
}
