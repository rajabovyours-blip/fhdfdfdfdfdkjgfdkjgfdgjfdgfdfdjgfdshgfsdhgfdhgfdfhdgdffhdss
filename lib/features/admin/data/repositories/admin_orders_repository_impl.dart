import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/admin/data/datasources/admin_orders_remote_datasource.dart';
import 'package:milliy_metr/features/admin/domain/repositories/admin_orders_repository.dart';

class AdminOrdersRepositoryImpl implements AdminOrdersRepository {
  final AdminOrdersRemoteDataSource remoteDataSource;

  AdminOrdersRepositoryImpl({required this.remoteDataSource});

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
