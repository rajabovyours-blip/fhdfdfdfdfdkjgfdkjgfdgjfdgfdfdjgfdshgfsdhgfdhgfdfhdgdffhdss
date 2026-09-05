import 'dart:async';
import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/utils/app_formatters.dart';
import 'package:milliy_metr/features/catalog/presentation/providers/product_details_notifier.dart';
import 'package:milliy_metr/features/wishlist/presentation/providers/wishlist_notifier.dart';
import 'package:milliy_metr/features/cart/presentation/providers/cart_notifier.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';

import 'package:milliy_metr/features/reviews/presentation/widgets/review_card.dart';
import 'package:milliy_metr/features/reviews/presentation/widgets/review_composer_sheet.dart';
import 'package:milliy_metr/features/reviews/presentation/providers/review_providers.dart';
import 'package:milliy_metr/shared/components/product_image.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:share_plus/share_plus.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String productId;

  const ProductDetailsScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  int _selectedImageIndex = 0;
  bool _isDescriptionExpanded = false;
  bool _isAddingToCart = false;
  final TextEditingController _calcController = TextEditingController();
  double _calcResult = 0;

  @override
  @override
  void dispose() {
    _calcController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailsNotifierProvider(widget.productId));


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
          state.maybeWhen(
            loaded: (product) {
              return IconButton(
                icon: Icon(Icons.share_outlined, color: context.colors.textHigh),
                onPressed: () {
                  final title = product.name.get(Localizations.localeOf(context).languageCode);
                  SharePlus.instance.share(ShareParams(
                    text: 'Milliy Metr: $title - ${AppFormatters.currency(product.price, Localizations.localeOf(context).languageCode)}\nhttps://milliymetr.uz/products/${product.id}',
                  ),);
                },
              );
            },
            orElse: () => IconButton(
              icon: Icon(Icons.share_outlined, color: context.colors.textHigh),
              onPressed: null,
            ),
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
                                          fit: BoxFit.cover,
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
                                  fit: BoxFit.cover,
                                ),
                        ),

                        // Content
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. Brand / Manufacturer
                              Text(
                                product.brand ?? context.l10n.brandDefault,
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
                                  if (!outOfStock && product.stock > 0 && product.stock <= 5)
                                    Container(
                                      margin: const EdgeInsets.only(right: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Faqat ${product.stock} dona qoldi!',
                                        style: const TextStyle(
                                          color: Colors.orange,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
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
                              const SizedBox(height: 16),
                              
                              // Quick Facts
                              if (product.specifications != null && product.specifications!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Row(
                                    children: product.specifications!.entries.take(2).map((e) {
                                      // Determine a simple icon based on keyword
                                      IconData icon = Icons.info_outline;
                                      final keyLower = e.key.toLowerCase();
                                      if (keyLower.contains('og\'irlik') || keyLower.contains('kg')) icon = Icons.fitness_center;
                                      if (keyLower.contains('o\'lcham') || keyLower.contains('uzunlik') || keyLower.contains('mm')) icon = Icons.straighten;
                                      if (keyLower.contains('maydon') || keyLower.contains('m2')) icon = Icons.square_foot;
                                      if (keyLower.contains('hajmi') || keyLower.contains('litr')) icon = Icons.water_drop;
                                      
                                      return Container(
                                        margin: const EdgeInsets.only(right: 8),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: context.colors.primary.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(icon, size: 14, color: context.colors.primary),
                                            const SizedBox(width: 4),
                                            Text(
                                              e.value,
                                              style: TextStyle(
                                                color: context.colors.primary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),

                              const SizedBox(height: 8),

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
                                            product.hasDelivery 
                                                ? context.l10n.deliveryAvailable
                                                : context.l10n.deliveryNotAvailable,
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
                              const SizedBox(height: 16),
                              Text(
                                context.l10n.aboutProduct,
                                style: TextStyle(
                                  color: context.colors.textHigh,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Text(
                                  product.description.get(
                                    Localizations.localeOf(context).languageCode,
                                  ),
                                  maxLines: _isDescriptionExpanded ? null : 4,
                                  overflow: _isDescriptionExpanded
                                      ? null
                                      : TextOverflow.fade,
                                  style: TextStyle(
                                    color: context.colors.textMedium,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    height: 1.6,
                                  ),
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

                              // Material Calculator
                              if (['m2', 'm3', 'metr', 'kg'].contains(product.unit)) ...[
                                const SizedBox(height: 24),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: context.colors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: context.colors.outline),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(Icons.calculate, color: context.colors.primary),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Kalkulyator',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: context.colors.textHigh,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      TextField(
                                        controller: _calcController,
                                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                        decoration: InputDecoration(
                                          labelText: context.l10n.calculatorFieldLabel,
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                        ),
                                        onChanged: (val) {
                                          final parsed = double.tryParse(val) ?? 0;
                                          setState(() {
                                            _calcResult = parsed * 1.05; // 5% reserve
                                          });
                                        },
                                      ),
                                      if (_calcResult > 0) ...[
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: context.colors.background,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                context.l10n.calculatorReserve,
                                                style: TextStyle(color: context.colors.textMedium),
                                              ),
                                              Text(
                                                ' ',
                                                style: TextStyle(
                                                  color: context.colors.textHigh,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: context.colors.primary,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                            ),
                                            onPressed: () {
                                              ref.read(cartNotifierProvider.notifier).addToCart(product, _calcResult.ceil());
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text(context.l10n.calculatorAddedSnack),
                                                  backgroundColor: context.colors.success,
                                                ),
                                              );
                                            },
                                            child: Text(context.l10n.calculatorAddToCart),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                              
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
                                              CrossAxisAlignment.center,
                                          children: [
                                            Builder(
                                              builder: (context) {
                                                IconData icon = Icons.article_outlined;
                                                final keyLower = e.key.toLowerCase();
                                                if (keyLower.contains('og\'irlik') || keyLower.contains('kg') || keyLower.contains('zichlig')) icon = Icons.scale;
                                                if (keyLower.contains('o\'lcham') || keyLower.contains('uzunlik') || keyLower.contains('qalinlig') || keyLower.contains('kenglig') || keyLower.contains('diametr')) icon = Icons.straighten;
                                                if (keyLower.contains('maydon') || keyLower.contains('m2')) icon = Icons.square_foot;
                                                if (keyLower.contains('hajmi') || keyLower.contains('litr')) icon = Icons.water_drop;
                                                if (keyLower.contains('rang')) icon = Icons.palette_outlined;
                                                if (keyLower.contains('vaqt')) icon = Icons.access_time;
                                                if (keyLower.contains('material')) icon = Icons.category_outlined;
                                                return Padding(
                                                  padding: const EdgeInsets.only(right: 12.0),
                                                  child: Icon(icon, size: 20, color: context.colors.textMedium),
                                                );
                                              },
                                            ),
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
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],



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
                                                color: context.colors.surfaceVariant,
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
                child: _buildBottomBar(context, product),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, dynamic product) {
    final cartState = ref.watch(cartNotifierProvider);
    int quantityInCart = 0;
    cartState.maybeWhen(
      loaded: (items) {
        final existing = items.where((item) => item.product.id == product.id).firstOrNull;
        if (existing != null) {
          quantityInCart = existing.quantity;
        }
      },
      orElse: () {},
    );

    final bool inCart = quantityInCart > 0;
    final outOfStock = product.stock <= 0;

    return Container(
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
        border: Border(top: BorderSide(color: context.colors.outline)),
      ),
      child: Row(
        children: [
          Expanded(
            child: inCart
                ? Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: context.colors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.remove, color: Colors.white),
                            onPressed: () {
                              ref.read(cartNotifierProvider.notifier).addToCart(product, -1);
                            },
                          ),
                        ),
                        Text(
                          context.l10n.inCartWithCount(quantityInCart),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          height: 40,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: Icon(Icons.add, color: quantityInCart >= (product.stock ?? 0) ? Colors.white54 : Colors.white),
                            onPressed: quantityInCart >= (product.stock ?? 0) ? null : () {
                              ref.read(cartNotifierProvider.notifier).addToCart(product, 1);
                            },
                          ),
                        ),
                      ],
                    ),
                  )
                : ElevatedButton(
                    onPressed: outOfStock ? null : () async {
                      setState(() => _isAddingToCart = true);
                      try {
                        await ref.read(cartNotifierProvider.notifier).addToCart(product, 1);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.l10n.addedToCart),
                              backgroundColor: context.colors.success,
                              behavior: SnackBarBehavior.floating,
                              action: SnackBarAction(
                                label: context.l10n.cart,
                                textColor: Colors.white,
                                onPressed: () => context.push(AppRoutes.cart),
                              ),
                            ),
                          );
                        }
                      } finally {
                        if (mounted) {
                          setState(() => _isAddingToCart = false);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.colors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isAddingToCart
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            context.l10n.addToCart,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: outOfStock ? null : () async {
                              await ref.read(cartNotifierProvider.notifier).addToCart(product, 1);
                              if (context.mounted) {
                                unawaited(context.push(AppRoutes.checkout));
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.primary,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              context.l10n.buyNowBtn,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
        ],
      ),
    );
  }
}
