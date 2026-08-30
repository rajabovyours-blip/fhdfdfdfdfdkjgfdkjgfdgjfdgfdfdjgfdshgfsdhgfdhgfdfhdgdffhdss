import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/features/catalog/presentation/providers/catalog_notifier.dart';
import 'package:milliy_metr/features/categories/presentation/providers/category_notifier.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class CatalogCategorySelector extends ConsumerWidget {
  const CatalogCategorySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(catalogNotifierProvider.select(
      (s) => s.maybeWhen(
        loaded: (data) => data.selectedCategory,
        orElse: () => 'Barchasi',
      ),
    ));

    final categoryState = ref.watch(categoryNotifierProvider);

    return SizedBox(
      height: 48,
      child: categoryState.when(
        initial: () => const Center(child: SizedBox()),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (message) => Center(child: Text(message)),
        loaded: (categoryEntities) {
          final categories = [
            {'id': 'Barchasi', 'name': context.l10n.all},
            ...categoryEntities.map((e) => {'id': e.id, 'name': e.name.get(context.l10n.localeName)}),
          ];

          return ListView.separated(
            key: const PageStorageKey('catalog_category_selector_scroll_key'),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final catId = categories[index]['id']!;
              final catName = categories[index]['name']!;
              final isSelected = catId == selectedCategory;

              return Semantics(
                selected: isSelected,
                button: true,
                label: catName,
                child: Material(
                  color: isSelected ? context.colors.primary : context.colors.surface,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () {
                      if (isSelected) return;
                      ref
                          .read(catalogNotifierProvider.notifier)
                          .setCategory(catId);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.outline,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        catName,
                        style: TextStyle(
                          color: isSelected
                              ? context.colors.textHigh
                              : context.colors.textMedium,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
