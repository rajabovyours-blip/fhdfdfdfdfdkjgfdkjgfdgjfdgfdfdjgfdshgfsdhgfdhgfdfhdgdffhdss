import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/checkout/domain/entities/cart_item_entity.dart';

abstract class CartRepository {
  Future<Either<Failure, List<CartItemEntity>>> getCartItems();
  Future<Either<Failure, void>> addToCart(String productId, int quantity);
  Future<Either<Failure, void>> updateCartItem(String cartItemId, int quantity);
  Future<Either<Failure, void>> removeFromCart(String cartItemId);
  Future<Either<Failure, void>> clearCart();
}
