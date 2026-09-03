import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/features/catalog/presentation/providers/catalog_notifier.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/features/search/domain/entities/search_filter_state.dart';
import 'package:milliy_metr/shared/components/product_filter_sheet.dart';

class CatalogBottomSheets {
  static void showSortSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final state = ref.read(catalogNotifierProvider);
        final currentSort = state.maybeWhen(
          loaded: (data) => data.sortOption,
          orElse: () => null,
        );

        Widget buildSortOption(String label, String value) {
          final isSelected = currentSort == value;
          return ListTile(
            title: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? context.colors.primary
                    : context.colors.textHigh,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check, color: context.colors.primary)
                : null,
            onTap: () {
              ref.read(catalogNotifierProvider.notifier).setSortOption(value);
              Navigator.pop(context);
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  context.l10n.sort,
                  style: TextStyle(
                    color: context.colors.textHigh,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(color: context.colors.outline, height: 1),
              buildSortOption(context.l10n.sortRecommended, 'recommended'),
              buildSortOption(context.l10n.sortPriceAsc, 'price_asc'),
              buildSortOption(context.l10n.sortPriceDesc, 'price_desc'),
              buildSortOption(context.l10n.sortNewest, 'newest'),
              buildSortOption(context.l10n.sortRating, 'rating'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  static Future<void> showFilterSheet(BuildContext context, WidgetRef ref) async {
    final state = ref.read(catalogNotifierProvider);
    
    ProductFilterResult? initial;
    state.maybeWhen(
      loaded: (data) {
        initial = ProductFilterResult(
          minPrice: data.minPrice,
          maxPrice: data.maxPrice,
          brand: data.brand,
          unit: data.unit,
          minRating: data.minRating,
          maxMoq: data.maxMoq,
          hasCertificate: data.hasCertificate,
          hasDelivery: data.hasDelivery,
          sortOption: data.sortOption != null 
            ? SortOption.values.firstWhere(
                (e) => e.apiValue == data.sortOption, 
                orElse: () => SortOption.relevance,
              )
            : SortOption.relevance,
        );
      },
      orElse: () {
        initial = ProductFilterResult();
      },
    );

    final result = await ProductFilterSheet.show(context, initialFilters: initial!, showSort: false);
    
    if (result != null) {
      ref.read(catalogNotifierProvider.notifier).setFilters(
        minPrice: result.minPrice,
        maxPrice: result.maxPrice,
        brand: result.brand,
        unit: result.unit,
        minRating: result.minRating,
        maxMoq: result.maxMoq,
        hasCertificate: result.hasCertificate,
        hasDelivery: result.hasDelivery,
      );
    }
  }
}
