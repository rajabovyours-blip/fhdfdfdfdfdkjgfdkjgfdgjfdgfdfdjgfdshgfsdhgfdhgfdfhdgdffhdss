import 'package:dio/dio.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/features/admin/domain/entities/admin_dashboard_entity.dart';

abstract class AdminDashboardRemoteDataSource {
  Future<AdminDashboardEntity> getDashboardStatistics();
}

class AdminDashboardRemoteDataSourceImpl
    implements AdminDashboardRemoteDataSource {
  final Dio dio;

  AdminDashboardRemoteDataSourceImpl({required this.dio});

  @override
  Future<AdminDashboardEntity> getDashboardStatistics() async {
    try {
      // backend endpoint documented
      final response = await dio.get('/admin/dashboard');
      if (response.statusCode == 200) {
        return AdminDashboardEntity.fromJson(response.data['data']);
      } else {
        throw ServerException('Failed to fetch admin dashboard statistics');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
