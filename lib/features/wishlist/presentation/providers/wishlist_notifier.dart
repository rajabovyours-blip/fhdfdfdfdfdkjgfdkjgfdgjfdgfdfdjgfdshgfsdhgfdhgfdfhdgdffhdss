import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/state/feature_state.dart';
import 'package:milliy_metr/features/products/domain/entities/product_entity.dart';
import 'package:milliy_metr/features/wishlist/presentation/providers/wishlist_providers.dart';

import 'package:milliy_metr/core/providers/auth_provider.dart' as milliy_metr_auth_provider;

class WishlistNotifier
    extends StateNotifier<FeatureState<List<ProductEntity>>> {
  final Ref _ref;
  bool _wasAuthenticated = false;

  WishlistNotifier(this._ref) : super(const FeatureState.initial()) {
    _wasAuthenticated = _ref.read(milliy_metr_auth_provider.authProvider).maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );

    _ref.listen(milliy_metr_auth_provider.authProvider, (previous, next) {
      final isNowAuthenticated = next.maybeWhen(
        authenticated: (_) => true,
        orElse: () => false,
      );
      if (!_wasAuthenticated && isNowAuthenticated) {
        mergeGuestWishlistOnLogin();
      } else if (_wasAuthenticated && !isNowAuthenticated) {
        state = const FeatureState.loaded([]);
      }
      _wasAuthenticated = isNowAuthenticated;
    });

    loadWishlist();
  }

  Future<void> loadWishlist({bool silent = false}) async {
    if (!silent) state = const FeatureState.loading();
    
    final isAuthenticated = _ref.read(milliy_metr_auth_provider.authProvider).maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );
    
    if (!isAuthenticated) {
      state.maybeWhen(
        loaded: (items) { if (items.isEmpty) state = const FeatureState.loaded([]); },
        orElse: () => state = const FeatureState.loaded([]),
      );
      return;
    }

    final repository = _ref.read(wishlistRepositoryProvider);
    final result = await repository.getWishlist();

    if (!mounted) return;

    state = result.fold(
      (l) {
        final currentItems = state.maybeWhen(
          loaded: (items) => items,
          orElse: () => <ProductEntity>[],
        );
        return FeatureState.loaded(currentItems);
      },
      (r) => FeatureState.loaded(r),
    );
  }

  Future<void> mergeGuestWishlistOnLogin() async {
    final guestItems = state.maybeWhen(
      loaded: (items) => List<ProductEntity>.from(items),
      orElse: () => <ProductEntity>[],
    );
    
    final repository = _ref.read(wishlistRepositoryProvider);
    await repository.getWishlist();
    
    if (guestItems.isNotEmpty) {
      for (final item in guestItems) {
        await repository.addToWishlist(item.id);
      }
    }
    
    await loadWishlist(silent: true);
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

    final isAuthenticated = _ref.read(milliy_metr_auth_provider.authProvider).maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );
    
    if (isAuthenticated) {
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
    }
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
