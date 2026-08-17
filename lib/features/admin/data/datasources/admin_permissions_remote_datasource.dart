import 'package:dio/dio.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';

abstract class AdminPermissionsRemoteDataSource {
  Future<List<dynamic>> getItems();
}

class AdminPermissionsRemoteDataSourceImpl
    implements AdminPermissionsRemoteDataSource {
  final Dio dio;

  AdminPermissionsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> getItems() async {
    try {
      final response = await dio.get('/admin/permissions');
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      } else {
        throw ServerException('Failed to load data from /admin/permissions');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
