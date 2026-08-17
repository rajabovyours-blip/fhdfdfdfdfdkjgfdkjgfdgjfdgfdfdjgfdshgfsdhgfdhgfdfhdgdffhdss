import 'package:dio/dio.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';

abstract class AdminOrdersRemoteDataSource {
  Future<List<dynamic>> getItems();
}

class AdminOrdersRemoteDataSourceImpl implements AdminOrdersRemoteDataSource {
  final Dio dio;

  AdminOrdersRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> getItems() async {
    try {
      final response = await dio.get('/admin/orders');
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      } else {
        throw ServerException('Failed to load data from /admin/orders');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
