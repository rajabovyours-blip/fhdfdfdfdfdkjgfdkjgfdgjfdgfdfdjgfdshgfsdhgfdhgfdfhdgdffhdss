import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/state/feature_state.dart';
import 'package:milliy_metr/features/products/domain/entities/product_entity.dart';
import 'package:milliy_metr/features/wishlist/presentation/providers/wishlist_providers.dart';

class WishlistNotifier
    extends StateNotifier<FeatureState<List<ProductEntity>>> {
  final Ref _ref;

  WishlistNotifier(this._ref) : super(const FeatureState.initial()) {
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    state = const FeatureState.loading();
    final repository = _ref.read(wishlistRepositoryProvider);
    final result = await repository.getWishlist();

    if (!mounted) return;

    state = result.fold(
      (l) => FeatureState.error(l.message),
      (r) => FeatureState.loaded(r),
    );
  }

  final Set<String> _processing = {};

  Future<void> toggleWishlist(ProductEntity product) async {
    if (_processing.contains(product.id)) return;
    _processing.add(product.id);
    final currentList = state.maybeWhen(
      loaded: (data) => data,
      orElse: () => <ProductEntity>[],
    );
    final isFavorite = currentList.any((p) => p.id == product.id);

    // Optimistic update
    if (isFavorite) {
      state = FeatureState.loaded(
        currentList.where((p) => p.id != product.id).toList(),
      );
    } else {
      state = FeatureState.loaded([...currentList, product]);
    }

    final repository = _ref.read(wishlistRepositoryProvider);
    final result = isFavorite
        ? await repository.removeFromWishlist(product.id)
        : await repository.addToWishlist(product.id);

    result.fold(
      (l) {
        // Revert on error
        state = FeatureState.loaded(currentList);
      },
      (r) => null,
    );
    _processing.remove(product.id);
  }

  bool isFavorite(String productId) {
    return state.maybeWhen(
      loaded: (data) => data.any((p) => p.id == productId),
      orElse: () => false,
    );
  }
}

final wishlistNotifierProvider =
    StateNotifierProvider<WishlistNotifier, FeatureState<List<ProductEntity>>>(
        (ref) {
  return WishlistNotifier(ref);
});
