import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/checkout/data/repositories/checkout_repository_impl.dart';
import 'package:milliy_metr/features/checkout/domain/entities/address_entity.dart';
import 'package:milliy_metr/features/checkout/domain/entities/cart_item_entity.dart';
import 'package:milliy_metr/features/checkout/domain/entities/order_entity.dart';
import 'package:milliy_metr/features/checkout/domain/repositories/checkout_repository.dart';
import 'package:milliy_metr/features/checkout/domain/usecases/place_order_usecase.dart';

import 'package:milliy_metr/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'dart:convert';
import 'package:milliy_metr/core/storage/preferences.dart';
import 'package:milliy_metr/features/cart/presentation/providers/cart_notifier.dart';

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
    this.deliveryMethod = 'Delivery Service',
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
    
    // Load local addresses
    final localAddressesStrs = PreferencesManager.getStringList('local_addresses');
    final localAddresses = localAddressesStrs.map((s) => AddressEntity.fromJson(jsonDecode(s))).toList();

    final addressResult = await repository.getAddresses();

    addressResult.fold(
      (addressFailure) {
        final defaultAddress = localAddresses.where((a) => a.isDefault).isNotEmpty 
            ? localAddresses.where((a) => a.isDefault).first 
            : (localAddresses.isNotEmpty ? localAddresses.first : null);
        state = state.copyWith(
          isLoading: false,
          error: addressFailure.message,
          addresses: localAddresses,
          selectedAddress: defaultAddress,
        );
      },
      (addresses) {
        final allAddresses = [...addresses, ...localAddresses];
        final defaultAddress = allAddresses.where((a) => a.isDefault).isNotEmpty
            ? allAddresses.where((a) => a.isDefault).first
            : (allAddresses.isNotEmpty ? allAddresses.first : null);
        state = state.copyWith(
          isLoading: false,
          addresses: allAddresses,
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


  void deleteAddress(String id) {
    final updated = state.addresses.where((a) => a.id != id).toList();
    state = state.copyWith(
      addresses: updated,
      selectedAddress: state.selectedAddress?.id == id
          ? (updated.isNotEmpty ? updated.first : null)
          : state.selectedAddress,
    );
  }

  void setDefaultAddress(String id) {
    final updated = state.addresses.map<AddressEntity>((a) {
      if (a.id == id) {
        return AddressEntity(
          id: a.id,
          label: a.label,
          region: a.region,
          district: a.district,
          street: a.street,
          building: a.building,
          apartment: a.apartment,
          zipCode: a.zipCode,
          phone: a.phone,
          notes: a.notes,
          isDefault: true,
          isCurrentLocation: a.isCurrentLocation,
          addressType: a.addressType,
        );
      } else {
        return AddressEntity(
          id: a.id,
          label: a.label,
          region: a.region,
          district: a.district,
          street: a.street,
          building: a.building,
          apartment: a.apartment,
          zipCode: a.zipCode,
          phone: a.phone,
          notes: a.notes,
          isDefault: false,
          isCurrentLocation: a.isCurrentLocation,
          addressType: a.addressType,
        );
      }
    }).toList();
    state = state.copyWith(addresses: updated);
  }

  Future<bool> addNewAddress(String label, String region, String district, String street) async {
    state = state.copyWith(isLoading: true);

    // Check for duplicates
    final bool isDuplicate = state.addresses.any((a) =>
        a.region == region &&
        a.district == district &&
        a.street == street,);

    if (isDuplicate) {
      state = state.copyWith(
        isLoading: false,
        error: 'Bu manzil allaqachon mavjud',
      );
      return false;
    }
    
    final newAddress = AddressEntity(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      label: label,
      region: region,
      district: district,
      street: street,
      building: '',
      apartment: '',
      zipCode: '',
      phone: '',
      notes: '',
      isDefault: state.addresses.isEmpty,
      isCurrentLocation: false,
      addressType: 'local',
    );
    
    final localStrs = List<String>.from(PreferencesManager.getStringList('local_addresses'));
    
    // Check for duplicates
    final bool alreadyExists = state.addresses.any((a) => 
        a.street == street && a.region == region && a.district == district,);
    
    if (!alreadyExists) {
      localStrs.add(jsonEncode(newAddress.toJson()));
      await PreferencesManager.setStringList('local_addresses', localStrs);
    }
    
    try {
      final dio = ref.read(dioProvider);
      final landmark = '$region, $district';
      await dio.post(
        '/addresses',
        data: {
          'title': label,
          'street': street,
          'landmark': landmark,
          'lat': 0.0,
          'lng': 0.0,
          'is_default': state.addresses.isEmpty,
        },
      );
    } catch (e) {
      // Remote sync fails, but local persists
    }
    
    await load();
    return true;
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
      (order) {
        state = state.copyWith(isSubmitting: false, order: order);
        ref.read(cartNotifierProvider.notifier).clearCart();
      },
    );
  }

  double get subtotal =>
      state.cartItems.where((item) => item.isSelected).fold<double>(
            0,
            (sum, item) => sum + (item.product.price * item.quantity),
          );

  double get shippingFee {
    switch (state.deliveryMethod) {
      case 'Delivery Service':
        return 50000;
      case 'Pickup from warehouse':
        return 0;
      default:
        return 50000;
    }
  }
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
