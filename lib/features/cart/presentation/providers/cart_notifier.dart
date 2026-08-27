import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/state/feature_state.dart';
import 'package:milliy_metr/features/checkout/domain/entities/cart_item_entity.dart';
import 'package:milliy_metr/features/cart/presentation/providers/cart_providers.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart' as milliy_metr_auth_provider;

class CartNotifier extends StateNotifier<FeatureState<List<CartItemEntity>>> {
  final Ref _ref;

  CartNotifier(this._ref) : super(const FeatureState.initial()) {
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
      state = const FeatureState.loaded([]);
      return;
    }

    final repository = _ref.read(cartRepositoryProvider);
    final result = await repository.getCartItems();

    state = result.fold(
      (l) => FeatureState.error(l.message),
      (r) => FeatureState.loaded(r),
    );
  }

  Future<void> addToCart(String productId, int quantity) async {
    final repository = _ref.read(cartRepositoryProvider);
    final result = await repository.addToCart(productId, quantity);
    if (result.isLeft()) {
      // Graceful error handling without throwing an unhandled exception to the UI
      final message = result.fold((l) => l.message, (r) => '');
      state = FeatureState.error(message);
    } else {
      await loadCart(silent: true);
    }
  }

  Future<void> updateCartItem(String cartItemId, int quantity) async {
    final repository = _ref.read(cartRepositoryProvider);
    final result = await repository.updateCartItem(cartItemId, quantity);
    if (result.isLeft()) {
      state = FeatureState.error(result.fold((l) => l.message, (r) => ''));
    } else {
      await loadCart(silent: true);
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    final repository = _ref.read(cartRepositoryProvider);
    final result = await repository.removeFromCart(cartItemId);
    if (result.isLeft()) {
      state = FeatureState.error(result.fold((l) => l.message, (r) => ''));
    } else {
      await loadCart(silent: true);
    }
  }

  Future<void> clearCart() async {
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

  double get shippingFee => 50000;
  double get discount => 0;
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
