import 'package:dio/dio.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';

abstract class AdminAuditLogsRemoteDataSource {
  Future<List<dynamic>> getItems();
}

class AdminAuditLogsRemoteDataSourceImpl
    implements AdminAuditLogsRemoteDataSource {
  final Dio dio;

  AdminAuditLogsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> getItems() async {
    try {
      final response = await dio.get('/admin/audit-logs');
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      } else {
        throw ServerException('Failed to load data from /admin/audit-logs');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
