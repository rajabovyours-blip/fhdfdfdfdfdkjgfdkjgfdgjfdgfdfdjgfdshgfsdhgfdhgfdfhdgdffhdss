import 'package:dio/dio.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';

abstract class OrderRemoteDataSource {
  Future<List<dynamic>> getOrders();
  Future<dynamic> getOrderById(String orderId);
  Future<void> cancelOrder(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio dio;

  OrderRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> getOrders() async {
    try {
      final response = await dio.get('/orders/my');
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      } else {
        throw ServerException('Failed to fetch orders');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }

  @override
  Future<dynamic> getOrderById(String orderId) async {
    try {
      final response = await dio.get('/orders/$orderId');
      if (response.statusCode == 200) {
        return response.data['data'];
      } else {
        throw ServerException('Failed to fetch order details');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    try {
      final response = await dio.post('/orders/$orderId/cancel');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to cancel order');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
