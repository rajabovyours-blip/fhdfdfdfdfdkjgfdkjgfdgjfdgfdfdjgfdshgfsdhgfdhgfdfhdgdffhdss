import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import 'product.dart';

final productRepositoryProvider = Provider((ref) => ProductRepository(ref.watch(dioProvider)));

class ProductRepository {
  final Dio _dio;

  ProductRepository(this._dio);

  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get('/seller/products');
      final data = response.data['data'] as List;
      return data.map((e) => Product.fromJson(e)).toList();
    } catch (e) {
      // Return empty or throw based on your error handling strategy
      throw Exception('Failed to load products');
    }
  }

  Future<void> addProduct(Map<String, dynamic> data) async {
    await _dio.post('/seller/products', data: data);
  }
}
