import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/admin/data/datasources/admin_dashboard_remote_datasource.dart';
import 'package:milliy_metr/features/admin/domain/entities/admin_dashboard_entity.dart';
import 'package:milliy_metr/features/admin/domain/repositories/admin_dashboard_repository.dart';

class AdminDashboardRepositoryImpl implements AdminDashboardRepository {
  final AdminDashboardRemoteDataSource remoteDataSource;

  AdminDashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AdminDashboardEntity>> getDashboardStatistics() async {
    try {
      final response = await remoteDataSource.getDashboardStatistics();
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
