import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:shimmer/shimmer.dart';

class ProductCardSkeleton extends StatelessWidget {
  final bool showCartAction;
  final bool showStock;

  const ProductCardSkeleton({
    super.key,
    this.showCartAction = false,
    this.showStock = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: context.colors.outline, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image Skeleton
          AspectRatio(
            aspectRatio: 1,
            child: Shimmer.fromColors(
              baseColor: context.colors.surfaceVariant,
              highlightColor: context.colors.outline.withValues(alpha: 0.5),
              child: Container(
                color: context.colors.textHigh,
              ),
            ),
          ),

          // Details Skeleton
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Shimmer.fromColors(
                    baseColor: context.colors.surfaceVariant,
                    highlightColor: context.colors.outline.withValues(alpha: 0.5),
                    child: Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: context.colors.textHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Shimmer.fromColors(
                    baseColor: context.colors.surfaceVariant,
                    highlightColor: context.colors.outline.withValues(alpha: 0.5),
                    child: Container(
                      height: 14,
                      width: 120,
                      decoration: BoxDecoration(
                        color: context.colors.textHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Rating & Brand
                  Shimmer.fromColors(
                    baseColor: context.colors.surfaceVariant,
                    highlightColor: context.colors.outline.withValues(alpha: 0.5),
                    child: Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: context.colors.textHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Shimmer.fromColors(
                    baseColor: context.colors.surfaceVariant,
                    highlightColor: context.colors.outline.withValues(alpha: 0.5),
                    child: Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: context.colors.textHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  if (showStock) ...[
                    const SizedBox(height: 6),
                    Shimmer.fromColors(
                      baseColor: context.colors.surfaceVariant,
                      highlightColor: context.colors.outline.withValues(alpha: 0.5),
                      child: Container(
                        height: 12,
                        width: 90,
                        decoration: BoxDecoration(
                          color: context.colors.textHigh,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],

                  const Spacer(),
                  const SizedBox(height: 12),

                  // Price
                  Shimmer.fromColors(
                    baseColor: context.colors.surfaceVariant,
                    highlightColor: context.colors.outline.withValues(alpha: 0.5),
                    child: Container(
                      height: 18,
                      width: 100,
                      decoration: BoxDecoration(
                        color: context.colors.textHigh,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),

                  if (showCartAction) ...[
                    const SizedBox(height: 8),
                    Shimmer.fromColors(
                      baseColor: context.colors.surfaceVariant,
                      highlightColor: context.colors.outline.withValues(alpha: 0.5),
                      child: Container(
                        height: 36,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: context.colors.textHigh,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
