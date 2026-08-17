import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:milliy_metr/features/checkout/domain/entities/address_entity.dart';
import 'package:milliy_metr/features/checkout/domain/entities/cart_item_entity.dart';
import 'package:milliy_metr/features/checkout/domain/entities/order_entity.dart';
import 'package:milliy_metr/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:milliy_metr/features/checkout/domain/usecases/place_order_usecase.dart';

import 'package:milliy_metr/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';

final checkoutRemoteDataSourceProvider =
    Provider<CheckoutRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return CheckoutRemoteDataSourceImpl(dio: dio);
});

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) {
  final remoteDataSource = ref.watch(checkoutRemoteDataSourceProvider);
  return CheckoutRepositoryImpl(remoteDataSource: remoteDataSource);
});

final placeOrderUseCaseProvider = Provider<PlaceOrderUseCase>((ref) {
  final repository = ref.watch(checkoutRepositoryProvider);
  return PlaceOrderUseCase(repository);
});

class CheckoutState {
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final List<CartItemEntity> cartItems;
  final List<AddressEntity> addresses;
  final AddressEntity? selectedAddress;
  final String deliveryMethod;
  final String paymentMethod;
  final String couponCode;
  final String notes;
  final bool selectAll;
  final OrderEntity? order;

  const CheckoutState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.cartItems = const [],
    this.addresses = const [],
    this.selectedAddress,
    this.deliveryMethod = 'Standard Delivery',
    this.paymentMethod = 'Payme',
    this.couponCode = '',
    this.notes = '',
    this.selectAll = true,
    this.order,
  });

  CheckoutState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    List<CartItemEntity>? cartItems,
    List<AddressEntity>? addresses,
    AddressEntity? selectedAddress,
    String? deliveryMethod,
    String? paymentMethod,
    String? couponCode,
    String? notes,
    bool? selectAll,
    OrderEntity? order,
  }) {
    return CheckoutState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      cartItems: cartItems ?? this.cartItems,
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      deliveryMethod: deliveryMethod ?? this.deliveryMethod,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      couponCode: couponCode ?? this.couponCode,
      notes: notes ?? this.notes,
      selectAll: selectAll ?? this.selectAll,
      order: order ?? this.order,
    );
  }
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final CheckoutRepository repository;
  final Ref ref;

  CheckoutNotifier(this.repository, this.ref) : super(const CheckoutState());

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: null);
    final addressResult = await repository.getAddresses();

    addressResult.fold(
      (addressFailure) => state =
          state.copyWith(isLoading: false, error: addressFailure.message),
      (addresses) {
        final defaultAddress =
            addresses.where((a) => a.isDefault).firstOrNull();
        state = state.copyWith(
          isLoading: false,
          addresses: addresses,
          selectedAddress: defaultAddress,
        );
      },
    );
  }

  void initializeWithCartItems(List<CartItemEntity> items) {
    state = state.copyWith(cartItems: items);
  }

  void toggleSelectAll(bool value) {
    state = state.copyWith(
      selectAll: value,
      cartItems: [
        for (final item in state.cartItems) item.copyWith(isSelected: value),
      ],
    );
  }

  void toggleItemSelection(String id, bool value) {
    state = state.copyWith(
      cartItems: [
        for (final item in state.cartItems)
          item.id == id ? item.copyWith(isSelected: value) : item,
      ],
    );
  }

  void updateQuantity(String id, int quantity) {
    state = state.copyWith(
      cartItems: [
        for (final item in state.cartItems)
          item.id == id ? item.copyWith(quantity: quantity) : item,
      ],
    );
  }

  void removeItem(String id) {
    state = state.copyWith(
      cartItems: state.cartItems.where((item) => item.id != id).toList(),
    );
  }

  void saveForLater(String id) {
    state = state.copyWith(
      cartItems: [
        for (final item in state.cartItems)
          item.id == id ? item.copyWith(isSavedForLater: true) : item,
      ],
    );
  }

  void setAddress(AddressEntity address) {
    state = state.copyWith(selectedAddress: address);
  }

  void setDeliveryMethod(String value) {
    state = state.copyWith(deliveryMethod: value);
  }

  void setPaymentMethod(String value) {
    state = state.copyWith(paymentMethod: value);
  }

  void setCouponCode(String value) {
    state = state.copyWith(couponCode: value);
  }

  void setNotes(String value) {
    state = state.copyWith(notes: value);
  }

  Future<void> placeOrder() async {
    if (state.selectedAddress == null) {
      state = state.copyWith(error: 'Please select an address');
      return;
    }

    final selectedItems =
        state.cartItems.where((item) => item.isSelected).toList();
    if (selectedItems.isEmpty) {
      state = state.copyWith(error: 'Select at least one item');
      return;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    final useCase = ref.read(placeOrderUseCaseProvider);
    final result = await useCase.call(
      items: selectedItems,
      address: state.selectedAddress!,
      paymentMethod: state.paymentMethod,
      deliveryMethod: state.deliveryMethod,
      couponCode: state.couponCode,
      notes: state.notes,
    );

    result.fold(
      (failure) =>
          state = state.copyWith(isSubmitting: false, error: failure.message),
      (order) => state = state.copyWith(isSubmitting: false, order: order),
    );
  }

  double get subtotal =>
      state.cartItems.where((item) => item.isSelected).fold<double>(
            0,
            (sum, item) => sum + (item.product.price * item.quantity),
          );

  double get shippingFee =>
      state.deliveryMethod == 'Express Delivery' ? 120000 : 50000;
  double get discount => state.couponCode.isNotEmpty ? 10000 : 0;
  double get tax => subtotal * 0.01;
  double get total => subtotal + shippingFee + tax - discount;
  int get itemCount => state.cartItems.where((item) => item.isSelected).length;
  String get estimatedDelivery =>
      state.deliveryMethod == 'Express Delivery' ? 'Today' : '2-3 days';
}

final checkoutProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref.read(checkoutRepositoryProvider), ref);
});

extension FirstOrNull<T> on Iterable<T> {
  T? firstOrNull() {
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      return iterator.current;
    }
    return null;
  }
}
