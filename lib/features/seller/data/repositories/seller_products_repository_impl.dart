import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/seller/data/datasources/seller_products_remote_datasource.dart';
import 'package:milliy_metr/features/seller/domain/repositories/seller_products_repository.dart';

class SellerProductsRepositoryImpl implements SellerProductsRepository {
  final SellerProductsRemoteDataSource remoteDataSource;

  SellerProductsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<dynamic>>> getItems() async {
    try {
      final result = await remoteDataSource.getItems();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
