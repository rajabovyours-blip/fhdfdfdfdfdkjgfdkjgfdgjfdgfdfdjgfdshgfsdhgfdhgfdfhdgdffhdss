import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/admin/data/datasources/admin_management_remote_datasource.dart';
import 'package:milliy_metr/features/admin/domain/repositories/admin_management_repository.dart';

class AdminManagementRepositoryImpl implements AdminManagementRepository {
  final AdminManagementRemoteDataSource remoteDataSource;

  AdminManagementRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<dynamic>>> getUsers() async {
    try {
      final response = await remoteDataSource.getUsers();
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
