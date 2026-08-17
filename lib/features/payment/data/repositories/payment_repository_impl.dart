import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:milliy_metr/features/payment/domain/entities/payment_method_entity.dart';
import 'package:milliy_metr/features/payment/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods() async {
    try {
      final methods = await remoteDataSource.getPaymentMethods();
      return Right(methods);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> processPayment(
    String orderId,
    String paymentMethodId,
  ) async {
    try {
      await remoteDataSource.processPayment(orderId, paymentMethodId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
