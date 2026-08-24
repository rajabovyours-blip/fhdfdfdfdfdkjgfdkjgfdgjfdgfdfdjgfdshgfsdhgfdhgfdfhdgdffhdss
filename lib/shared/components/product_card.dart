import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/products/domain/entities/product_entity.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/core/utils/app_formatters.dart';
import 'package:milliy_metr/features/wishlist/presentation/providers/wishlist_notifier.dart';
import 'package:milliy_metr/features/cart/presentation/providers/cart_notifier.dart';
import 'package:milliy_metr/shared/components/product_image.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class ProductCard extends ConsumerStatefulWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  final bool showCartAction;
  final bool showFavorite;
  final bool showStock;
  final VoidCallback? onFavoriteToggleOverride;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.showCartAction = false,
    this.showFavorite = true,
    this.showStock = false,
    this.onFavoriteToggleOverride,
  });

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool _isLoading = false;
  bool _isOptimisticCartAdded = false;

  Future<void> _addToCart() async {
    setState(() {
      _isLoading = true;
      _isOptimisticCartAdded = true;
    });

    try {
      await ref
          .read(cartNotifierProvider.notifier)
          .addToCart(widget.product.id, 1);
    } catch (e) {
      if (mounted) {
        setState(() {
          _isOptimisticCartAdded = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.errorOccurred),
            backgroundColor: context.colors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFavorite = ref.watch(wishlistNotifierProvider).maybeWhen(
      loaded: (items) => items.any((p) => p.id == widget.product.id),
      orElse: () => false,
    );

    final bool isInCart = widget.showCartAction
        ? (ref.watch(cartNotifierProvider).maybeWhen(
              loaded: (items) => items.any((item) => item.product.id == widget.product.id),
              orElse: () => false,
            ) || _isOptimisticCartAdded)
        : false;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: context.colors.outline, width: 1),
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image Area
            AspectRatio(
              aspectRatio: 1, // Fixed aspect ratio for image
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ProductImage(
                    imageUrl: widget.product.images.isNotEmpty
                        ? widget.product.images.first
                        : null,
                    fallbackSeed: widget.product.name
                        .get(Localizations.localeOf(context).languageCode),
                  ),

                  // Favorite Button
                  if (widget.showFavorite)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: widget.onFavoriteToggleOverride ??
                            () => ref
                                .read(wishlistNotifierProvider.notifier)
                                .toggleWishlist(widget.product),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: context.colors.background
                                .withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isFavorite
                                ? context.colors.primary
                                : context.colors.onPrimary,
                          ),
                        ),
                      ),
                    ),

                  // Discount Badge
                  if (widget.product.discount != null &&
                      widget.product.discount! > 0)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${widget.product.discount!.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: context.colors.textHigh,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Details Area
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Info Group
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          widget.product.name.get(
                            Localizations.localeOf(context).languageCode,
                          ),
                          style: TextStyle(
                            color: context.colors.textHigh,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Rating
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: context.colors.warning,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.product.rating.toString(),
                              style: TextStyle(
                                color: context.colors.textHigh,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${widget.product.reviewCount})',
                              style: TextStyle(
                                color: context.colors.textMedium,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),

                        // Seller
                        Text(
                          widget.product.brand ?? 'Milliy Qurilish',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: context.colors.textMedium,
                            fontSize: 11,
                          ),
                        ),

                        if (widget.showStock) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.product.stock > 0
                                ? context.l10n.inStock(
                                    widget.product.stock,
                                    widget.product.unit == 'piece'
                                        ? context.l10n.piece
                                        : widget.product.unit,
                                  )
                                : context.l10n.outOfStock,
                            style: TextStyle(
                              color: widget.product.stock > 0
                                  ? context.colors.success
                                  : context.colors.danger,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Price and Action Group
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.product.oldPrice != null &&
                            widget.product.oldPrice! > widget.product.price)
                          Text(
                            AppFormatters.currency(
                              widget.product.oldPrice!,
                              Localizations.localeOf(context).languageCode,
                            ),
                            style: TextStyle(
                              color: context.colors.textMedium,
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          AppFormatters.currency(
                            widget.product.price,
                            Localizations.localeOf(context).languageCode,
                          ),
                          style: TextStyle(
                            color: context.colors.textHigh,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (widget.showCartAction &&
                            widget.product.stock > 0) ...[
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
                            height: 32,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : (isInCart
                                      ? () => context.push(AppRoutes.cart)
                                      : _addToCart),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isInCart
                                    ? context.colors.success
                                    : context.colors.primary,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? SizedBox(
                                      height: 14,
                                      width: 14,
                                      child: CircularProgressIndicator(
                                        color: context.colors.onPrimary,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      isInCart ? context.l10n.inCart : context.l10n.addToCart,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: context.colors.onPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
