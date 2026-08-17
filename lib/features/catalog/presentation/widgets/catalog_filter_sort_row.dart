import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/catalog/presentation/providers/catalog_notifier.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class CatalogFilterSortRow extends ConsumerWidget {
  final VoidCallback onFilterTap;
  final VoidCallback onSortTap;

  const CatalogFilterSortRow({
    super.key,
    required this.onFilterTap,
    required this.onSortTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(catalogNotifierProvider);
    final count = state.maybeWhen(
      loaded: (data) => data.products.length,
      orElse: () => 0,
    );
    final isLoading = state.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onFilterTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.colors.outline),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tune,
                        size: 16,
                        color: context.colors.textHigh,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.filter,
                        style: TextStyle(
                          color: context.colors.textHigh,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onSortTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: context.colors.outline),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.swap_vert,
                        size: 16,
                        color: context.colors.textHigh,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        context.l10n.sort,
                        style: TextStyle(
                          color: context.colors.textHigh,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colors.primary,
              ),
            )
          else
            Text(
              context.l10n.productCount(count),
              style: TextStyle(
                color: context.colors.textMedium,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
