import 'package:dio/dio.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';

abstract class AdminManagementRemoteDataSource {
  Future<List<dynamic>> getUsers();
}

class AdminManagementRemoteDataSourceImpl
    implements AdminManagementRemoteDataSource {
  final Dio dio;

  AdminManagementRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> getUsers() async {
    try {
      // backend endpoint documented
      final response = await dio.get('/admin/users');
      return response.data['data'];
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
