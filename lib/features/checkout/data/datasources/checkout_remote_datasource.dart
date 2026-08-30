import 'package:dio/dio.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/core/errors/dio_error_mapper.dart';

abstract class CheckoutRemoteDataSource {
  Future<dynamic> placeOrder(Map<String, dynamic> data);
  Future<List<dynamic>> getAddresses();
  Future<void> addAddress(Map<String, dynamic> data);
}

class CheckoutRemoteDataSourceImpl implements CheckoutRemoteDataSource {
  final Dio dio;

  CheckoutRemoteDataSourceImpl({required this.dio});

  @override
  Future<dynamic> placeOrder(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/checkout/order', data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data['data'];
      } else {
        throw ServerException('Failed to place order');
      }
    } on DioException catch (e) {
      throw ServerException(DioErrorMapper.extractErrorMessage(e));
    } catch (e) {
      throw ServerException(DioErrorMapper.extractErrorMessage(e));
    }
  }

  @override
  Future<List<dynamic>> getAddresses() async {
    try {
      final response = await dio.get('/addresses');
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      } else {
        throw ServerException('Failed to fetch addresses');
      }
    } on DioException catch (e) {
      throw ServerException(DioErrorMapper.extractErrorMessage(e));
    } catch (e) {
      throw ServerException(DioErrorMapper.extractErrorMessage(e));
    }
  }

  @override
  Future<void> addAddress(Map<String, dynamic> data) async {
    try {
      final response = await dio.post('/addresses', data: data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Failed to add address');
      }
    } on DioException catch (e) {
      throw ServerException(DioErrorMapper.extractErrorMessage(e));
    } catch (e) {
      throw ServerException(DioErrorMapper.extractErrorMessage(e));
    }
  }
}
