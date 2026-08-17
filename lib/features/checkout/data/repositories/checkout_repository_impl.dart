import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/checkout/data/datasources/checkout_remote_datasource.dart';
import 'package:milliy_metr/features/checkout/domain/entities/address_entity.dart';
import 'package:milliy_metr/features/checkout/domain/entities/cart_item_entity.dart';
import 'package:milliy_metr/features/checkout/domain/entities/order_entity.dart';
import 'package:milliy_metr/features/checkout/domain/repositories/checkout_repository.dart';

class CheckoutRepositoryImpl implements CheckoutRepository {
  final CheckoutRemoteDataSource remoteDataSource;

  CheckoutRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AddressEntity>>> getAddresses() async {
    try {
      final data = await remoteDataSource.getAddresses();
      final addresses =
          data.map<AddressEntity>((e) => AddressEntity.fromJson(e)).toList();
      return Right(addresses);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> placeOrder({
    required List<CartItemEntity> items,
    required AddressEntity address,
    required String paymentMethod,
    required String deliveryMethod,
    required String couponCode,
    required String notes,
  }) async {
    try {
      final payload = {
        'items':
            items.map((e) => {'id': e.id, 'quantity': e.quantity}).toList(),
        'address_id': address.id,
        'payment_method': paymentMethod,
        'delivery_method': deliveryMethod,
        'coupon_code': couponCode,
        'notes': notes,
      };

      final data = await remoteDataSource.placeOrder(payload);
      final order = OrderEntity.fromJson(data);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
