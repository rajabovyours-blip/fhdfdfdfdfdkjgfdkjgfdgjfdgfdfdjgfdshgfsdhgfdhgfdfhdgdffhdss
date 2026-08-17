import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/seller/data/datasources/seller_auth_remote_datasource.dart';
import 'package:milliy_metr/features/seller/domain/entities/seller_registration_entity.dart';
import 'package:milliy_metr/features/seller/domain/entities/seller_verification_entity.dart';
import 'package:milliy_metr/features/seller/domain/repositories/seller_auth_repository.dart';

class SellerAuthRepositoryImpl implements SellerAuthRepository {
  final SellerAuthRemoteDataSource remoteDataSource;

  SellerAuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, dynamic>> registerSeller(
    SellerRegistrationEntity entity,
  ) async {
    try {
      final response = await remoteDataSource.registerSeller(entity);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SellerVerificationEntity>>
      getVerificationStatus() async {
    try {
      final response = await remoteDataSource.getVerificationStatus();
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
