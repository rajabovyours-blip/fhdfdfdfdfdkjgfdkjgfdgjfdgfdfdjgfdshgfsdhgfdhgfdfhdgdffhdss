import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/checkout/domain/entities/address_entity.dart';
import 'package:milliy_metr/features/checkout/domain/entities/cart_item_entity.dart';
import 'package:milliy_metr/features/checkout/domain/entities/order_entity.dart';
import 'package:milliy_metr/features/checkout/domain/repositories/checkout_repository.dart';

class PlaceOrderUseCase {
  final CheckoutRepository repository;

  PlaceOrderUseCase(this.repository);

  Future<Either<Failure, OrderEntity>> call({
    required List<CartItemEntity> items,
    required AddressEntity address,
    required String paymentMethod,
    required String deliveryMethod,
    required String couponCode,
    required String notes,
  }) {
    return repository.placeOrder(
      items: items,
      address: address,
      paymentMethod: paymentMethod,
      deliveryMethod: deliveryMethod,
      couponCode: couponCode,
      notes: notes,
    );
  }
}
