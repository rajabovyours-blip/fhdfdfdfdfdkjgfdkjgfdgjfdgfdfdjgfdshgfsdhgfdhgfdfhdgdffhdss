import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/search/presentation/providers/search_notifier.dart';
import 'package:milliy_metr/shared/components/product_filter_sheet.dart';

class FilterBottomSheet {
  static Future<void> show(BuildContext context, WidgetRef ref) async {
    final currentFilters = ref.read(searchNotifierProvider).filters;
    
    final initial = ProductFilterResult(
      minPrice: currentFilters.minPrice,
      maxPrice: currentFilters.maxPrice,
      brand: currentFilters.brand,
      unit: currentFilters.unit,
      minRating: currentFilters.minRating,
      maxMoq: currentFilters.maxMoq,
      hasCertificate: currentFilters.hasCertificate,
      hasDelivery: currentFilters.hasDelivery,
      inStock: currentFilters.inStock,
      hasDiscount: currentFilters.hasDiscount,
      sortOption: currentFilters.sortOption,
    );

    final result = await ProductFilterSheet.show(context, initialFilters: initial);
    
    if (result != null) {
      final updated = currentFilters.copyWith(
        minPrice: result.minPrice,
        maxPrice: result.maxPrice,
        brand: result.brand,
        unit: result.unit,
        minRating: result.minRating,
        maxMoq: result.maxMoq,
        hasCertificate: result.hasCertificate,
        hasDelivery: result.hasDelivery,
        inStock: result.inStock,
        hasDiscount: result.hasDiscount,
        sortOption: result.sortOption,
      );
      
      ref.read(searchNotifierProvider.notifier).updateFilters(updated);
    }
  }
}
