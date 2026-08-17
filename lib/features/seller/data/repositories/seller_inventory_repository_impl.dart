import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/seller/data/datasources/seller_inventory_remote_datasource.dart';
import 'package:milliy_metr/features/seller/domain/repositories/seller_inventory_repository.dart';

class SellerInventoryRepositoryImpl implements SellerInventoryRepository {
  final SellerInventoryRemoteDataSource remoteDataSource;

  SellerInventoryRepositoryImpl({required this.remoteDataSource});

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
