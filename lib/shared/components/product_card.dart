import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/products/domain/entities/product_entity.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/core/utils/app_formatters.dart';
import 'package:milliy_metr/features/wishlist/presentation/providers/wishlist_notifier.dart';
import 'package:milliy_metr/features/cart/presentation/providers/cart_notifier.dart';
import 'package:milliy_metr/shared/components/brand_image_loader.dart';
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
              aspectRatio: 1.0,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  BrandImageLoader(
                    imageUrl: widget.product.images.isNotEmpty
                        ? widget.product.images.first
                        : null,
                    borderRadius: 0,
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
                            color: context.colors.background.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            size: 18,
                            color: isFavorite
                                ? const Color(0xFFFF7A00)
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
                          color: const Color(0xFFFF3B30),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '-${widget.product.discount!.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Rating & Seller
                        Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Color(0xFFFFB800),
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
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.product.brand ?? 'Milliy Qurilish',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.colors.textMedium,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    // Price and Action Group
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
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
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              Text(
                                AppFormatters.currency(
                                  widget.product.price,
                                  Localizations.localeOf(context).languageCode,
                                ),
                                style: const TextStyle(
                                  color: Color(0xFFFF7A00),
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: _isLoading
                              ? null
                              : (isInCart
                                  ? () => context.push(AppRoutes.cart)
                                  : _addToCart),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isInCart
                                  ? context.colors.success
                                  : const Color(0xFFFF7A00),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    isInCart
                                        ? Icons.check
                                        : Icons.add_shopping_cart_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
