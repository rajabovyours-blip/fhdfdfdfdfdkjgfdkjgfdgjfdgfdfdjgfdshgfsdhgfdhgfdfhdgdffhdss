import 'package:dio/dio.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';

abstract class AdminPaymentsRemoteDataSource {
  Future<List<dynamic>> getItems();
}

class AdminPaymentsRemoteDataSourceImpl
    implements AdminPaymentsRemoteDataSource {
  final Dio dio;

  AdminPaymentsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> getItems() async {
    try {
      final response = await dio.get('/admin/payments');
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      } else {
        throw ServerException('Failed to load data from /admin/payments');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
