import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/features/products/domain/entities/product_entity.dart';
import 'package:milliy_metr/shared/components/product_card.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class ProductGrid extends StatelessWidget {
  final List<ProductEntity> products;

  const ProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 48,
                  color: context.colors.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.productNotFound,
                  style: TextStyle(
                    color: context.colors.textHigh,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.searchWithAnotherName,
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(color: context.colors.textMedium, fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      sliver: SliverLayoutBuilder(
        builder: (context, constraints) {
          const crossAxisCount = 2;
          const crossAxisSpacing = 12.0;
          const mainAxisSpacing = 16.0;

          const childAspectRatio = 0.55;

          return SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
              childAspectRatio: childAspectRatio,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onTap: () {
                    context.push(
                      AppRoutes.productDetails.replaceAll(':id', product.id),
                    );
                  },
                );
              },
              childCount: products.length,
            ),
          );
        },
      ),
    );
  }
}
