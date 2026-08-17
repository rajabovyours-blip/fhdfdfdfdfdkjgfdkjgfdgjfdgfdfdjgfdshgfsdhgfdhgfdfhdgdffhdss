import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:milliy_metr/features/checkout/domain/entities/cart_item_entity.dart';
import 'package:milliy_metr/features/cart/domain/repositories/cart_repository.dart';

import 'package:milliy_metr/core/errors/app_exception.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CartItemEntity>>> getCartItems() async {
    try {
      final items = await remoteDataSource.getCartItems();
      return Right(items
          .map((e) => CartItemEntity.fromJson(e as Map<String, dynamic>))
          .toList(),);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addToCart(
    String productId,
    int quantity,
  ) async {
    try {
      await remoteDataSource.addToCart(productId, quantity);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCartItem(
    String cartItemId,
    int quantity,
  ) async {
    try {
      await remoteDataSource.updateCartItem(cartItemId, quantity);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String cartItemId) async {
    try {
      await remoteDataSource.removeFromCart(cartItemId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      // NOTE: CartRemoteDataSource does not have a clearCart endpoint yet.
      // Doing nothing or calling a future endpoint.
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
