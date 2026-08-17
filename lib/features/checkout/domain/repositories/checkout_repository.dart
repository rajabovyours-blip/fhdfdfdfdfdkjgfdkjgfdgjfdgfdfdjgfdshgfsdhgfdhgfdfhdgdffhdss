import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/checkout/domain/entities/address_entity.dart';
import 'package:milliy_metr/features/checkout/domain/entities/cart_item_entity.dart';
import 'package:milliy_metr/features/checkout/domain/entities/order_entity.dart';

abstract class CheckoutRepository {
  Future<Either<Failure, List<AddressEntity>>> getAddresses();
  Future<Either<Failure, OrderEntity>> placeOrder({
    required List<CartItemEntity> items,
    required AddressEntity address,
    required String paymentMethod,
    required String deliveryMethod,
    required String couponCode,
    required String notes,
  });
}
