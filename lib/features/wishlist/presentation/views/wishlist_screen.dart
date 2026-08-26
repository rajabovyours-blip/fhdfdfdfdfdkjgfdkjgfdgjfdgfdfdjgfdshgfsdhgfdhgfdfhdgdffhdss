import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/shared/components/product_card.dart';
import 'package:milliy_metr/shared/components/loaders/product_card_skeleton.dart';
import 'package:milliy_metr/features/wishlist/presentation/providers/wishlist_notifier.dart';
import 'package:milliy_metr/features/products/domain/entities/product_entity.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
class WishlistScreen extends ConsumerStatefulWidget {
  const WishlistScreen({super.key});

  @override
  ConsumerState<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends ConsumerState<WishlistScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late String _sortOption;
  late List<String> _sortOptions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sortOptions = [
      context.l10n.newest,
      context.l10n.priceLowToHigh,
      context.l10n.priceHighToLow,
      context.l10n.rating,
    ];
    _sortOption = _sortOptions.first;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFavoriteToggleOverride(ProductEntity product) {
    // Optimistically remove from state
    ref.read(wishlistNotifierProvider.notifier).toggleWishlist(product);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.l10n.removedFromWishlist,
          style: TextStyle(color: context.colors.textHigh),
        ),
        backgroundColor: context.colors.surfaceVariant,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: context.l10n.undo,
          textColor: context.colors.secondary,
          onPressed: () {
            // Restore it
            ref.read(wishlistNotifierProvider.notifier).toggleWishlist(product);
          },
        ),
      ),
    );
  }

  void _showSortModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surfaceVariant,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.sort,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.colors.textHigh,
                ),
              ),
              const SizedBox(height: 16),
              ..._sortOptions.map((option) {
                final isSelected = option == _sortOption;
                return ListTile(
                  title: Text(
                    option,
                    style: TextStyle(
                      color: isSelected
                          ? context.colors.secondary
                          : context.colors.textHigh,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check, color: context.colors.secondary)
                      : null,
                  onTap: () {
                    setState(() {
                      _sortOption = option;
                    });
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  List<ProductEntity> _getFilteredAndSorted(List<ProductEntity> products) {
    List<ProductEntity> filtered = products;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (p) =>
                p.name
                    .get(Localizations.localeOf(context).languageCode)
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                (p.brand != null &&
                    p.brand!
                        .toLowerCase()
                        .contains(_searchQuery.toLowerCase())),
          )
          .toList();
    }

    if (_sortOption == context.l10n.priceLowToHigh) {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (_sortOption == context.l10n.priceHighToLow) {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    } else if (_sortOption == context.l10n.rating) {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      // newest or default
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(wishlistNotifierProvider);
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.surface,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.l10n.wishlist,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            state.maybeWhen(
              loaded: (products) => products.isNotEmpty
                  ? Text(
                      context.l10n.productCount(products.length),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.colors.textMedium,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        actions: [
          state.maybeWhen(
            loaded: (products) => products.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.sort),
                    onPressed: _showSortModal,
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: !isAuthenticated ? _buildGuestState() : RefreshIndicator(
        onRefresh: () =>
            ref.read(wishlistNotifierProvider.notifier).loadWishlist(),
        child: state.maybeWhen(
          loaded: (products) {
            if (products.isEmpty) {
              return _buildEmptyState();
            }

            final displayProducts = _getFilteredAndSorted(products);

            return Column(
              children: [
                if (products.length > 3) _buildSearchBar(),
                Expanded(
                  child: displayProducts.isEmpty
                      ? _buildNoSearchResults()
                      : _buildGrid(displayProducts),
                ),
              ],
            );
          },
          error: (e) => _buildErrorState(e),
          orElse: () => _buildLoadingState(),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: context.colors.surface,
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        style: TextStyle(color: context.colors.textHigh),
        decoration: InputDecoration(
          hintText: context.l10n.searchInWishlist,
          hintStyle: TextStyle(color: context.colors.textMedium),
          prefixIcon: Icon(Icons.search, color: context.colors.textMedium),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: context.colors.textMedium),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: context.colors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildGuestState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lock_outline,
                size: 64,
                color: context.colors.secondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.guestModeTitle,
              style: TextStyle(
                color: context.colors.textHigh,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.guestWishlistDesc,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.colors.textMedium,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 44,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.login),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  context.l10n.login,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.colors.onPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - kToolbarHeight - 100,
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border,
                size: 64,
                color: context.colors.secondary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              context.l10n.wishlistEmpty,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.colors.textHigh,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              context.l10n.wishlistEmptyDesc,
              style: TextStyle(
                color: context.colors.textMedium,
                fontSize: 15,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () => context.go('/home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  context.l10n.viewProducts,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: context.colors.textHigh,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: context.colors.textDisabled),
          const SizedBox(height: 16),
          Text(
            context.l10n.noSuchProductFound,
            style: TextStyle(fontSize: 18, color: context.colors.textHigh),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.tryChangingSearchWord,
            style: TextStyle(color: context.colors.textMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(List<ProductEntity> products) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 2;
        const crossAxisSpacing = 16.0;
        const mainAxisSpacing = 16.0;

        final availableWidth = constraints.maxWidth;
        final cardWidth = (availableWidth - (crossAxisSpacing * (crossAxisCount - 1)) - 32) / crossAxisCount; // 32 is padding

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          child: Wrap(
            spacing: crossAxisSpacing,
            runSpacing: mainAxisSpacing,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: products.map((product) {
              return SizedBox(
                width: cardWidth,
                child: ProductCard(
                  product: product,
                  showCartAction: true,
                  showStock: true,
                  onFavoriteToggleOverride: () =>
                      _onFavoriteToggleOverride(product),
                  onTap: () => context.push(
                    AppRoutes.productDetails.replaceAll(':id', product.id),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const crossAxisCount = 2;
        const crossAxisSpacing = 16.0;
        const mainAxisSpacing = 16.0;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: mainAxisSpacing,
            crossAxisSpacing: crossAxisSpacing,
            childAspectRatio: 0.63,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return const ProductCardSkeleton(
              showCartAction: true,
              showStock: true,
            );
          },
        );
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 64, color: context.colors.danger),
            const SizedBox(height: 16),
            Text(
              context.l10n.errorLoadingWishlist,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: context.colors.textHigh,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.checkInternetAndRetry,
              style: TextStyle(color: context.colors.textMedium),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              height: 44,
              child: ElevatedButton(
                onPressed: () =>
                    ref.read(wishlistNotifierProvider.notifier).loadWishlist(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  context.l10n.retry,
                  style: TextStyle(color: context.colors.textHigh),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
