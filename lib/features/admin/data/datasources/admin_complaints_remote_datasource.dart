import 'package:dio/dio.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';

abstract class AdminComplaintsRemoteDataSource {
  Future<List<dynamic>> getItems();
}

class AdminComplaintsRemoteDataSourceImpl
    implements AdminComplaintsRemoteDataSource {
  final Dio dio;

  AdminComplaintsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> getItems() async {
    try {
      final response = await dio.get('/admin/complaints');
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      } else {
        throw ServerException('Failed to load data from /admin/complaints');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
