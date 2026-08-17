import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/utils/app_formatters.dart';
import 'package:milliy_metr/features/catalog/presentation/providers/product_details_notifier.dart';
import 'package:milliy_metr/features/wishlist/presentation/providers/wishlist_notifier.dart';
import 'package:milliy_metr/features/cart/presentation/providers/cart_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/core/providers/main_navigation_provider.dart';
import 'package:milliy_metr/features/checkout/domain/entities/cart_item_entity.dart';
import 'package:milliy_metr/features/reviews/presentation/widgets/review_card.dart';
import 'package:milliy_metr/features/reviews/presentation/widgets/review_composer_sheet.dart';
import 'package:milliy_metr/features/reviews/presentation/providers/review_providers.dart';
import 'package:milliy_metr/shared/components/product_image.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _quantity = 1;
  int _selectedImageIndex = 0;
  bool _isDescriptionExpanded = false;
  bool _isCartLoading = false;

  void _incrementQuantity(int maxStock, CartItemEntity? cartItem) {
    if (cartItem != null) {
      if (cartItem.quantity < maxStock) {
        ref
            .read(cartNotifierProvider.notifier)
            .updateCartItem(cartItem.id, cartItem.quantity + 1);
      }
    } else {
      if (_quantity < maxStock) {
        setState(() {
          _quantity++;
        });
      }
    }
  }

  void _decrementQuantity(CartItemEntity? cartItem) {
    if (cartItem != null) {
      if (cartItem.quantity > 1) {
        ref
            .read(cartNotifierProvider.notifier)
            .updateCartItem(cartItem.id, cartItem.quantity - 1);
      } else {
        ref.read(cartNotifierProvider.notifier).removeFromCart(cartItem.id);
      }
    } else {
      if (_quantity > 1) {
        setState(() {
          _quantity--;
        });
      }
    }
  }

  Future<void> _addToCart(String productId) async {
    setState(() {
      _isCartLoading = true;
    });

    try {
      await ref
          .read(cartNotifierProvider.notifier)
          .addToCart(productId, _quantity);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: context.colors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCartLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailsNotifierProvider(widget.productId));
    final cartState = ref.watch(cartNotifierProvider);

    CartItemEntity? cartItem;
    cartState.maybeWhen(
      loaded: (items) {
        try {
          cartItem =
              items.firstWhere((item) => item.product.id == widget.productId);
        } catch (_) {}
      },
      orElse: () {},
    );

    final int displayQuantity =
        cartItem != null ? cartItem!.quantity : _quantity;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.textHigh),
        toolbarHeight: 56,
        actions: [
          state.maybeWhen(
            loaded: (product) {
              return Consumer(
                builder: (context, ref, _) {
                  final isFavorite = ref.watch(wishlistNotifierProvider).maybeWhen(
                    loaded: (items) => items.any((p) => p.id == product.id),
                    orElse: () => false,
                  );
                  return IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? context.colors.primary
                          : context.colors.textHigh,
                    ),
                    onPressed: () => ref
                        .read(wishlistNotifierProvider.notifier)
                        .toggleWishlist(product),
                  );
                },
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          IconButton(
            icon: Icon(Icons.share, color: context.colors.textHigh),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(context.l10n.share),
                  backgroundColor: context.colors.primary,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: state.when(
        initial: () => Center(
          child: CircularProgressIndicator(color: context.colors.primary),
        ),
        loading: () => Center(
          child: CircularProgressIndicator(color: context.colors.primary),
        ),
        error: (e) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                context.l10n.errorLoadingProductDetails,
                style: TextStyle(color: context.colors.textHigh),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                ),
                onPressed: () => ref
                    .refresh(productDetailsNotifierProvider(widget.productId)),
                child: Text(
                  context.l10n.retry,
                  style: TextStyle(color: context.colors.textHigh),
                ),
              ),
            ],
          ),
        ),
        loaded: (product) {
          final bool outOfStock = product.stock <= 0;
          return Stack(
            children: [
              CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Gallery (Hero Section)
                        Container(
                          height: MediaQuery.of(context).size.width * 0.6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: context.colors.surface,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(24),
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: product.images.isNotEmpty
                              ? Stack(
                                  children: [
                                    PageView.builder(
                                      itemCount: product.images.length,
                                      onPageChanged: (index) {
                                        setState(() {
                                          _selectedImageIndex = index;
                                        });
                                      },
                                      itemBuilder: (context, index) {
                                        return ProductImage(
                                          imageUrl: product.images[index],
                                          fallbackSeed: product.name.get(
                                            Localizations.localeOf(context)
                                                .languageCode,
                                          ),
                                          fit: BoxFit.contain,
                                        );
                                      },
                                    ),
                                    if (product.images.length > 1)
                                      Positioned(
                                        bottom: 12,
                                        left: 0,
                                        right: 0,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                            product.images.length,
                                            (index) => Container(
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 4,
                                              ),
                                              width: _selectedImageIndex == index
                                                  ? 16
                                                  : 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: _selectedImageIndex ==
                                                        index
                                                    ? context.colors.primary
                                                    : context.colors.outline,
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                )
                              : ProductImage(
                                  imageUrl: null,
                                  fallbackSeed: product.name.get(
                                    Localizations.localeOf(context)
                                        .languageCode,
                                  ),
                                  fit: BoxFit.contain,
                                ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Seller / Manufacturer
                              Text(
                                product.brand ?? 'Milliy Qurilish',
                                style: TextStyle(
                                  color: context.colors.textMedium,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),

                              // 2. Product Title
                              Text(
                                product.name.get(
                                  Localizations.localeOf(context).languageCode,
                                ),
                                style: TextStyle(
                                  color: context.colors.textHigh,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // 3. Rating & 4. Availability
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 16,
                                    color: context.colors.warning,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    product.rating > 0
                                        ? product.rating.toStringAsFixed(1)
                                        : context.l10n.newStatus,
                                    style: TextStyle(
                                      color: context.colors.textHigh,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (product.reviewCount > 0)
                                    Text(
                                      ' ${context.l10n.reviewsCount(product.reviewCount)}',
                                      style: TextStyle(
                                        color: context.colors.textMedium,
                                        fontSize: 13,
                                      ),
                                    ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: outOfStock
                                          ? context.colors.danger.withValues(alpha: 0.1)
                                          : context.colors.success.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      outOfStock
                                          ? context.l10n.outOfStock
                                          : context.l10n.inStock(
                                              product.stock,
                                              product.unit == 'piece'
                                                  ? context.l10n.piece
                                                  : product.unit,
                                            ),
                                      style: TextStyle(
                                        color: outOfStock
                                            ? context.colors.danger
                                            : context.colors.success,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),

                              // 5. Pricing
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (product.oldPrice != null &&
                                      product.oldPrice! > product.price)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Row(
                                        children: [
                                          Text(
                                            AppFormatters.currency(
                                              product.oldPrice!,
                                              Localizations.localeOf(context)
                                                  .languageCode,
                                            ),
                                            style: TextStyle(
                                              color: context.colors.textMedium,
                                              fontSize: 14,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          if (product.discount != null &&
                                              product.discount! > 0)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: context.colors.primary,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                '-${product.discount!.toStringAsFixed(0)}%',
                                                style: TextStyle(
                                                  color:
                                                      context.colors.textHigh,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                        ],
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
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // Delivery Info Card
                              Text(
                                context.l10n.delivery,
                                style: TextStyle(
                                  color: context.colors.textHigh,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: context.colors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: context.colors.outline),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.local_shipping_outlined,
                                      color: context.colors.textMedium,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            product.location.isNotEmpty
                                                ? product.location
                                                : context.l10n.tashkent,
                                            style: TextStyle(
                                              color: context.colors.textHigh,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          if (product.deliveryInformation !=
                                              null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 2.0,),
                                              child: Text(
                                                product.deliveryInformation!,
                                                style: TextStyle(
                                                  color:
                                                      context.colors.textMedium,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Description
                              Text(
                                context.l10n.aboutProduct,
                                style: TextStyle(
                                  color: context.colors.textHigh,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                product.description.get(
                                  Localizations.localeOf(context).languageCode,
                                ),
                                maxLines: _isDescriptionExpanded ? null : 4,
                                overflow: _isDescriptionExpanded
                                    ? null
                                    : TextOverflow.fade,
                                style: TextStyle(
                                  color: context.colors.textDisabled,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                              if (product.description
                                      .get(
                                        Localizations.localeOf(context)
                                            .languageCode,
                                      )
                                      .length >
                                  150)
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isDescriptionExpanded =
                                          !_isDescriptionExpanded;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Text(
                                      _isDescriptionExpanded
                                          ? context.l10n.showLess
                                          : context.l10n.showMore,
                                      style: TextStyle(
                                        color: context.colors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),

                              // Specifications
                              if (product.specifications != null &&
                                  product.specifications!.isNotEmpty) ...[
                                const SizedBox(height: 24),
                                Text(
                                  context.l10n.specifications,
                                  style: TextStyle(
                                    color: context.colors.textHigh,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: context.colors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: context.colors.outline,
                                    ),
                                  ),
                                  child: Column(
                                    children: product.specifications!.entries
                                        .map((e) {
                                      final isLast = product.specifications!
                                              .entries.last.key ==
                                          e.key;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          border: isLast
                                              ? null
                                              : Border(
                                                  bottom: BorderSide(
                                                    color:
                                                        context.colors.outline,
                                                  ),
                                                ),
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Text(
                                                e.key,
                                                style: TextStyle(
                                                  color:
                                                      context.colors.textMedium,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                e.value,
                                                style: TextStyle(
                                                  color:
                                                      context.colors.textHigh,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 24),
                              // Reviews Section
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    context.l10n.reviews,
                                    style: TextStyle(
                                      color: context.colors.textHigh,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Consumer(
                                    builder: (context, ref, _) {
                                      final reviewsState = ref.watch(
                                        productReviewsProvider(product.id),
                                      );
                                      return reviewsState.maybeWhen(
                                        loaded: (reviews) {
                                          if (reviews.isEmpty) {
                                            return const SizedBox.shrink();
                                          }
                                          return GestureDetector(
                                            onTap: () {
                                              context.push(
                                                '/reviews/${product.id}',
                                              );
                                            },
                                            child: Text(
                                              context.l10n.viewAllReviews,
                                              style: TextStyle(
                                                color: context.colors.primary,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          );
                                        },
                                        orElse: () => const SizedBox.shrink(),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              Consumer(
                                builder: (context, ref, _) {
                                  final reviewsState = ref.watch(
                                    productReviewsProvider(product.id),
                                  );
                                  final eligibilityState = ref.watch(
                                    reviewEligibilityProvider(product.id),
                                  );
                                  final userReviewState =
                                      ref.watch(userReviewProvider(product.id));

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      reviewsState.when(
                                        initial: () => Center(
                                          child: CircularProgressIndicator(
                                            color: context.colors.primary,
                                          ),
                                        ),
                                        loading: () => Center(
                                          child: CircularProgressIndicator(
                                            color: context.colors.primary,
                                          ),
                                        ),
                                        error: (e) => Text(
                                          'Sharhlarni yuklashda xatolik: $e',
                                          style: TextStyle(
                                            color: context.colors.textHigh,
                                          ),
                                        ),
                                        loaded: (reviews) {
                                          if (reviews.isEmpty) {
                                            return Container(
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: context.colors.surface,
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: context.colors.outline,
                                                ),
                                              ),
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.rate_review_outlined,
                                                    color: context
                                                        .colors.textMedium,
                                                    size: 32,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    context.l10n.noReviewsYet,
                                                    style: TextStyle(
                                                      color: context
                                                          .colors.textHigh,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    context
                                                        .l10n.beFirstToReview,
                                                    style: TextStyle(
                                                      color: context
                                                          .colors.textMedium,
                                                      fontSize: 12,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ],
                                              ),
                                            );
                                          }

                                          return Column(
                                            children: [
                                              // Summary
                                              Row(
                                                children: [
                                                  Text(
                                                    (reviews.fold(
                                                              0.0,
                                                              (sum, item) =>
                                                                  sum +
                                                                  item.rating,
                                                            ) /
                                                            reviews.length)
                                                        .toStringAsFixed(1),
                                                    style: TextStyle(
                                                      color: context
                                                          .colors.textHigh,
                                                      fontSize: 32,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Row(
                                                        children: [
                                                          Icon(
                                                            Icons.star,
                                                            color: Color(
                                                              0xFFFFB800,
                                                            ),
                                                            size: 16,
                                                          ),
                                                          Icon(
                                                            Icons.star,
                                                            color: Color(
                                                              0xFFFFB800,
                                                            ),
                                                            size: 16,
                                                          ),
                                                          Icon(
                                                            Icons.star,
                                                            color: Color(
                                                              0xFFFFB800,
                                                            ),
                                                            size: 16,
                                                          ),
                                                          Icon(
                                                            Icons.star,
                                                            color: Color(
                                                              0xFFFFB800,
                                                            ),
                                                            size: 16,
                                                          ),
                                                          Icon(
                                                            Icons.star,
                                                            color: Color(
                                                              0xFFFFB800,
                                                            ),
                                                            size: 16,
                                                          ),
                                                        ],
                                                      ),
                                                      Text(
                                                        context.l10n
                                                            .reviewsCountLabel(
                                                          reviews.length,
                                                        ),
                                                        style: TextStyle(
                                                          color: context.colors
                                                              .textMedium,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              // Preview top 2 reviews
                                              ...reviews.take(2).map(
                                                    (review) => Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        bottom: 12,
                                                      ),
                                                      child: ReviewCard(
                                                        review: review,
                                                      ),
                                                    ),
                                                  ),
                                            ],
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      // Review CTA Action
                                      eligibilityState.when(
                                        data: (isEligible) {
                                          if (!isEligible) {
                                            return Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                  0xFF1A1A1A,
                                                ), // slight dim
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: context.colors.outline,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.info_outline,
                                                    color: context
                                                        .colors.textMedium,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Expanded(
                                                    child: Text(
                                                      context.l10n.buyToReview,
                                                      style: TextStyle(
                                                        color: context
                                                            .colors.textMedium,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }

                                          // Eligible to review
                                          final userReview =
                                              userReviewState.valueOrNull;
                                          return SizedBox(
                                            width: double.infinity,
                                            height: 48,
                                            child: OutlinedButton.icon(
                                              icon: Icon(
                                                userReview != null
                                                    ? Icons.edit
                                                    : Icons.rate_review,
                                                color: context.colors.textHigh,
                                                size: 20,
                                              ),
                                              label: Text(
                                                userReview != null
                                                    ? context.l10n.editReview
                                                    : context.l10n.leaveReview,
                                                style: TextStyle(
                                                  color:
                                                      context.colors.textHigh,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                  color: context.colors.outline,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    12,
                                                  ),
                                                ),
                                              ),
                                              onPressed: () {
                                                showReviewComposer(
                                                  context,
                                                  product.id,
                                                  product.name.get(
                                                    Localizations.localeOf(
                                                      context,
                                                    ).languageCode,
                                                  ),
                                                  existingReview: userReview,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        loading: () => const SizedBox.shrink(),
                                        error: (_, __) =>
                                            const SizedBox.shrink(),
                                      ),
                                    ],
                                  );
                                },
                              ),

                              const SizedBox(
                                height: 120,
                              ), // Padding to prevent content from hiding behind the sticky bottom bar
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Bottom Action Bar (Sticky)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 14,
                    bottom: MediaQuery.of(context).padding.bottom > 0
                        ? MediaQuery.of(context).padding.bottom
                        : 14,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    border:
                        Border(top: BorderSide(color: context.colors.outline)),
                  ),
                  child: Row(
                    children: [
                      // Compact Quantity Selector
                      Container(
                        height: 48,
                        width: 120,
                        decoration: BoxDecoration(
                          color: context.colors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: context.colors.outline),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            GestureDetector(
                              onTap: outOfStock
                                  ? null
                                  : () => _decrementQuantity(cartItem),
                              child: Container(
                                color: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 12,
                                ),
                                child: Icon(
                                  Icons.remove,
                                  size: 18,
                                  color: displayQuantity > 1
                                      ? context.colors.textHigh
                                      : context.colors.textMedium,
                                ),
                              ),
                            ),
                            Text(
                              '$displayQuantity',
                              style: TextStyle(
                                color: context.colors.textHigh,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            GestureDetector(
                              onTap: outOfStock
                                  ? null
                                  : () => _incrementQuantity(
                                        product.stock,
                                        cartItem,
                                      ),
                              child: Container(
                                color: Colors.transparent,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 12,
                                ),
                                child: Icon(
                                  Icons.add,
                                  size: 18,
                                  color: displayQuantity < product.stock
                                      ? context.colors.textHigh
                                      : context.colors.textMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Add to cart button
                      Expanded(
                        child: SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            key: const Key('add_to_cart_button'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (cartItem != null)
                                  ? context.colors.surfaceVariant
                                  : context.colors.primary,
                              foregroundColor: (cartItem != null)
                                  ? context.colors.primary
                                  : context.colors.onPrimary,
                              disabledBackgroundColor: context.colors.outline,
                              disabledForegroundColor:
                                  context.colors.textMedium,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            onPressed: (outOfStock || _isCartLoading)
                                ? null
                                : () {
                                    if (cartItem != null) {
                                      ref
                                          .read(mainTabIndexProvider.notifier)
                                          .state = 3;
                                      context.go(AppRoutes.home);
                                    } else {
                                      _addToCart(product.id);
                                    }
                                  },
                            child: (cartItem != null)
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check,
                                        size: 20,
                                        color: context.colors.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        context.l10n.inCart,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: context.colors.success,
                                        ),
                                      ),
                                      if (_isCartLoading) ...[
                                        const SizedBox(width: 8),
                                        SizedBox(
                                          height: 12,
                                          width: 12,
                                          child: CircularProgressIndicator(
                                            color: context.colors.success,
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ],
                                    ],
                                  )
                                : Text(
                                    context.l10n.addToCart,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
