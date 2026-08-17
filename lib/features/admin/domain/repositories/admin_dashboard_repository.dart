import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/admin/domain/entities/admin_dashboard_entity.dart';

abstract class AdminDashboardRepository {
  Future<Either<Failure, AdminDashboardEntity>> getDashboardStatistics();
}
