import 'package:dio/dio.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';

abstract class AdminCategoriesRemoteDataSource {
  Future<List<dynamic>> getItems();
}

class AdminCategoriesRemoteDataSourceImpl
    implements AdminCategoriesRemoteDataSource {
  final Dio dio;

  AdminCategoriesRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> getItems() async {
    try {
      final response = await dio.get('/admin/categories');
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      } else {
        throw ServerException('Failed to load data from /admin/categories');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
