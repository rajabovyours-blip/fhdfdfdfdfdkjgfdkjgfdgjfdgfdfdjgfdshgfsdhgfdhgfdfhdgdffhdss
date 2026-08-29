import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/state/feature_state.dart';
import 'package:milliy_metr/features/checkout/domain/entities/cart_item_entity.dart';
import 'package:milliy_metr/features/products/domain/entities/product_entity.dart';
import 'package:milliy_metr/features/cart/presentation/providers/cart_providers.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart' as milliy_metr_auth_provider;

class CartNotifier extends StateNotifier<FeatureState<List<CartItemEntity>>> {
  final Ref _ref;

  bool _wasAuthenticated = false;

  CartNotifier(this._ref) : super(const FeatureState.initial()) {
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
        mergeGuestCartOnLogin();
      } else if (_wasAuthenticated && !isNowAuthenticated) {
        state = const FeatureState.loaded([]);
      }
      _wasAuthenticated = isNowAuthenticated;
    });

    loadCart();
  }

  Future<void> loadCart({bool silent = false}) async {
    if (!silent) state = const FeatureState.loading();
    
    // Check auth state directly
    final authState = _ref.read(milliy_metr_auth_provider.authProvider);
    final isAuthenticated = authState.maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );
    
    if (!isAuthenticated) {
      // Preserve guest cart in memory
      state.maybeWhen(
        loaded: (items) { if (items.isEmpty) state = const FeatureState.loaded([]); },
        orElse: () => state = const FeatureState.loaded([]),
      );
      return;
    }

    final repository = _ref.read(cartRepositoryProvider);
    final result = await repository.getCartItems();

    state = result.fold(
      (l) {
        // Local-first: retain existing items if remote fetch fails
        final currentItems = state.maybeWhen(
          loaded: (items) => items,
          orElse: () => <CartItemEntity>[],
        );
        return FeatureState.loaded(currentItems);
      },
      (r) => FeatureState.loaded(r),
    );
  }


  Future<void> mergeGuestCartOnLogin() async {
    final guestItems = state.maybeWhen(
      loaded: (items) => List<CartItemEntity>.from(items),
      orElse: () => <CartItemEntity>[],
    );
    
    // First, load authenticated cart
    final repository = _ref.read(cartRepositoryProvider);
    await repository.getCartItems();
    
    if (guestItems.isNotEmpty) {
      // Sync guest items to remote
      for (final item in guestItems) {
        await repository.addToCart(item.product.id, item.quantity);
      }
    }
    
    // Final fetch to get merged state
    await loadCart(silent: true);
  }

  Future<void> addToCart(ProductEntity product, int quantity) async {
    final currentItems = state.maybeWhen(
      loaded: (items) => List<CartItemEntity>.from(items),
      orElse: () => <CartItemEntity>[],
    );
    
    final existingIndex = currentItems.indexWhere((i) => i.product.id == product.id);
    if (existingIndex >= 0) {
      currentItems[existingIndex] = currentItems[existingIndex].copyWith(
        quantity: currentItems[existingIndex].quantity + quantity,
      );
    } else {
      currentItems.add(CartItemEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
        quantity: quantity,
        isSelected: true,
        isSavedForLater: false,
        isWholesale: false,
        minimumOrderQuantity: 1,
        maximumQuantity: 99,
        warehouseName: 'Asosiy ombor',
      ),);
    }
    
    state = FeatureState.loaded(currentItems);
    
    final isAuthenticated = _ref.read(milliy_metr_auth_provider.authProvider).maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );
    
    if (isAuthenticated) {
      final repository = _ref.read(cartRepositoryProvider);
      await repository.addToCart(product.id, quantity);
    }
  }

  Future<void> updateCartItem(String cartItemId, int quantity) async {
    final isAuthenticated = _ref.read(milliy_metr_auth_provider.authProvider).maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );
    
    if (!isAuthenticated) {
      state.maybeWhen(
        loaded: (items) {
          final newItems = List<CartItemEntity>.from(items);
          final index = newItems.indexWhere((i) => i.id == cartItemId);
          if (index >= 0) {
            newItems[index] = newItems[index].copyWith(quantity: quantity);
            state = FeatureState.loaded(newItems);
          }
        },
        orElse: () {},
      );
      return;
    }

    final repository = _ref.read(cartRepositoryProvider);
    final result = await repository.updateCartItem(cartItemId, quantity);
    if (result.isLeft()) {
      state = FeatureState.error(result.fold((l) => l.message, (r) => ''));
    } else {
      await loadCart(silent: true);
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    final isAuthenticated = _ref.read(milliy_metr_auth_provider.authProvider).maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );
    
    if (!isAuthenticated) {
      state.maybeWhen(
        loaded: (items) {
          final newItems = List<CartItemEntity>.from(items);
          newItems.removeWhere((i) => i.id == cartItemId);
          state = FeatureState.loaded(newItems);
        },
        orElse: () {},
      );
      return;
    }

    final repository = _ref.read(cartRepositoryProvider);
    final result = await repository.removeFromCart(cartItemId);
    if (result.isLeft()) {
      state = FeatureState.error(result.fold((l) => l.message, (r) => ''));
    } else {
      await loadCart(silent: true);
    }
  }

  Future<void> clearCart() async {
    final isAuthenticated = _ref.read(milliy_metr_auth_provider.authProvider).maybeWhen(
      authenticated: (_) => true,
      orElse: () => false,
    );
    
    if (!isAuthenticated) {
      state = const FeatureState.loaded([]);
      return;
    }

    final repository = _ref.read(cartRepositoryProvider);
    final result = await repository.clearCart();
    if (result.isLeft()) {
      state = FeatureState.error(result.fold((l) => l.message, (r) => ''));
    } else {
      await loadCart(silent: true);
    }
  }

  void toggleItemSelection(String id, bool value) {
    state.maybeWhen(
      loaded: (items) {
        state = FeatureState.loaded(
          items
              .map((e) => e.id == id ? e.copyWith(isSelected: value) : e)
              .toList(),
        );
      },
      orElse: () {},
    );
  }

  void toggleSelectAll(bool value) {
    state.maybeWhen(
      loaded: (items) {
        state = FeatureState.loaded(
          items.map((e) => e.copyWith(isSelected: value)).toList(),
        );
      },
      orElse: () {},
    );
  }

  void saveForLater(String id) {
    state.maybeWhen(
      loaded: (items) {
        state = FeatureState.loaded(
          items
              .map((e) => e.id == id ? e.copyWith(isSavedForLater: true) : e)
              .toList(),
        );
      },
      orElse: () {},
    );
  }

  double get subtotal {
    return state.maybeWhen(
      loaded: (items) => items
          .where((e) => e.isSelected)
          .fold(0, (sum, item) => sum + (item.product.price * item.quantity)),
      orElse: () => 0.0,
    );
  }

  double get shippingFee => 0.0;
  double get discount {
    return state.maybeWhen(
      loaded: (items) {
        double d = 0;
        for (var e in items.where((i) => i.isSelected)) {
          if (e.quantity >= 10) {
            d += (e.product.price * e.quantity) * 0.05;
          }
        }
        return d;
      },
      orElse: () => 0.0,
    );
  }
  double get tax => subtotal * 0.01;
  double get total => subtotal + shippingFee + tax - discount;
  int get itemCount => state.maybeWhen(
        loaded: (items) => items.where((e) => e.isSelected).length,
        orElse: () => 0,
      );
  bool get selectAll => state.maybeWhen(
        loaded: (items) => items.isNotEmpty && items.every((e) => e.isSelected),
        orElse: () => false,
      );

  bool isInCart(String productId) {
    return state.maybeWhen(
      loaded: (items) => items.any((item) => item.product.id == productId),
      orElse: () => false,
    );
  }
}

final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, FeatureState<List<CartItemEntity>>>(
        (ref) {
  return CartNotifier(ref);
});
