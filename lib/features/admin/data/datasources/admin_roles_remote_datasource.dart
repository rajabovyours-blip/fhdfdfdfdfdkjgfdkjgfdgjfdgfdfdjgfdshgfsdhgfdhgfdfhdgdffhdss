import 'package:dio/dio.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';

abstract class AdminRolesRemoteDataSource {
  Future<List<dynamic>> getItems();
}

class AdminRolesRemoteDataSourceImpl implements AdminRolesRemoteDataSource {
  final Dio dio;

  AdminRolesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> getItems() async {
    try {
      final response = await dio.get('/admin/roles');
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      } else {
        throw ServerException('Failed to load data from /admin/roles');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
