import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/catalog/presentation/providers/catalog_notifier.dart';

import 'package:milliy_metr/l10n/l10n_extension.dart';

class CatalogCategorySelector extends ConsumerWidget {
  const CatalogCategorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogNotifierProvider);
    final selectedCategory = state.maybeWhen(
      loaded: (data) => data.selectedCategory,
      orElse: () => context.l10n.all,
    );

    final categories = [
      context.l10n.all,
      'Sement va Qorishmalar',
      'G\'isht va Bloklar',
      'Armatura va Metall',
      'Yog\'och materiallari',
      'Tom yopish materiallari',
      'Qurilish asboblari',
      'Qum va Shag\'al',
      'Beton mahsulotlari',
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        key: const PageStorageKey('catalog_category_selector_scroll_key'),
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory;

          return GestureDetector(
            onTap: () {
              ref.read(catalogNotifierProvider.notifier).setCategory(category);
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.primary
                    : context.colors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isSelected
                      ? context.colors.primary
                      : context.colors.outline,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                category,
                style: TextStyle(
                  color: isSelected
                      ? context.colors.textHigh
                      : context.colors.textMedium,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
