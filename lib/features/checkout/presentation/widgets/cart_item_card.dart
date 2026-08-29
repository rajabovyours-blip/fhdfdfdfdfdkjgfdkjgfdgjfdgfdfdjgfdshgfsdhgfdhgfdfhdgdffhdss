import 'package:flutter/material.dart';
import 'package:milliy_metr/core/utils/app_formatters.dart';
import 'package:milliy_metr/features/checkout/domain/entities/cart_item_entity.dart';
import 'package:milliy_metr/shared/components/product_image.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class CartItemCard extends StatelessWidget {
  final CartItemEntity item;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.item,
    required this.onIncrement,
    required this.onDecrement,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;
    final isOutOfStock = product.stock == 0;
    final maxQty = product.stock > 0 ? product.stock : 99;
    final isMaxQuantity =
        item.quantity >= maxQty || item.quantity >= item.maximumQuantity;

    String getLocalizedUnit(String unit, String langCode) {
      if (unit == 'dona') {
        if (langCode == 'en') return 'pcs';
        if (langCode == 'ru') return 'шт';
        return 'dona';
      } else if (unit == 'qop') {
        if (langCode == 'en') return 'bag';
        if (langCode == 'ru') return 'мешок';
        return 'qop';
      }
      return unit;
    }
    
    final locUnit = getLocalizedUnit(product.unit, Localizations.localeOf(context).languageCode);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: context.colors.surface, // context.colors.surface
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.outline,
          width: 1,
        ), // context.colors.outline
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: context.colors.background,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: ProductImage(
                    imageUrl:
                        product.images.isNotEmpty ? product.images.first : null,
                    fallbackSeed: product.name
                        .get(Localizations.localeOf(context).languageCode),
                  ),
                ),
                const SizedBox(width: 12),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              product.name.get(
                                Localizations.localeOf(context).languageCode,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: context
                                    .colors.textHigh, // context.colors.textHigh
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: onRemove,
                            behavior: HitTestBehavior.opaque,
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(
                                Icons.close,
                                color: context.colors
                                    .textMedium, // context.colors.textMedium
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.brand ?? 'Milliy Qurilish',
                        style: TextStyle(
                          color: context.colors.textMedium,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (product.oldPrice != null &&
                                    product.oldPrice! > product.price)
                                  Text(
                                    AppFormatters.currency(
                                      product.oldPrice!,
                                      Localizations.localeOf(context)
                                          .languageCode,
                                    ),
                                    style: TextStyle(
                                      color: context.colors.textMedium,
                                      fontSize: 11,
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                Text(
                                  AppFormatters.currency(
                                    product.price,
                                    Localizations.localeOf(context)
                                        .languageCode,
                                  ),
                                  style: TextStyle(
                                    color: context.colors.textHigh,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Action Bar (Quantity & Stock Status)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Stock Status
                if (isOutOfStock)
                  Text(
                    context.l10n.outOfStock,
                    style: TextStyle(
                      color: context.colors.danger,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else if (isMaxQuantity && product.stock > 0)
                  Text(
                    context.l10n.inStock(product.stock, locUnit),
                    style: TextStyle(
                      color: context.colors.warning,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                else
                  Text(
                    context.l10n.inStock(product.stock, locUnit),
                    style:
                        TextStyle(color: context.colors.success, fontSize: 12),
                  ),

                // Quantity Control
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onTap: onDecrement,
                      semanticLabel: 'Mahsulot sonini kamaytirish',
                    ),
                    Container(
                      width: 40,
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style: TextStyle(
                          color: context.colors.textHigh,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onTap:
                          (isMaxQuantity || isOutOfStock) ? null : onIncrement,
                      semanticLabel: 'Mahsulot sonini oshirish',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String semanticLabel;

  const _QuantityButton({
    required this.icon,
    this.onTap,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = onTap == null;
    return Semantics(
      label: semanticLabel,
      button: true,
      enabled: !disabled,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(
                color: disabled
                    ? context.colors.outline
                    : context.colors.textMedium.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 18,
              color:
                  disabled ? context.colors.textMedium : context.colors.textHigh,
            ),
          ),
        ),
      ),
    );
  }
}
