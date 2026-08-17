import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/admin/data/datasources/admin_roles_remote_datasource.dart';
import 'package:milliy_metr/features/admin/domain/repositories/admin_roles_repository.dart';

class AdminRolesRepositoryImpl implements AdminRolesRepository {
  final AdminRolesRemoteDataSource remoteDataSource;

  AdminRolesRepositoryImpl({required this.remoteDataSource});

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
