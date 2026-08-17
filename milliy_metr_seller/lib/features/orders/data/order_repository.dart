import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import 'order.dart';

final orderRepositoryProvider = Provider((ref) => OrderRepository(ref.watch(dioProvider)));

class OrderRepository {
  final Dio _dio;

  OrderRepository(this._dio);

  Future<List<Order>> getOrders() async {
    try {
      final response = await _dio.get('/seller/orders');
      final data = response.data['data'] as List;
      return data.map((e) => Order.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to load orders');
    }
  }

  Future<void> updateOrderStatus(String id, String status) async {
    await _dio.patch('/seller/orders/$id/status', data: {'status': status});
  }
}
