import 'package:dio/dio.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';

abstract class CartRemoteDataSource {
  Future<List<dynamic>> getCartItems();
  Future<void> addToCart(String productId, int quantity);
  Future<void> updateCartItem(String cartItemId, int quantity);
  Future<void> removeFromCart(String cartItemId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final Dio dio;

  CartRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> getCartItems() async {
    try {
      final response = await dio.get('/cart');
      if (response.statusCode == 200) {
        return response.data['data'] as List<dynamic>;
      } else {
        throw ServerException('Failed to load cart');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }

  @override
  Future<void> addToCart(String productId, int quantity) async {
    try {
      final response = await dio.post(
        '/cart/add',
        data: {
          'product_id': productId,
          'quantity': quantity,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Failed to add to cart');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }

  @override
  Future<void> updateCartItem(String cartItemId, int quantity) async {
    try {
      final response = await dio.post(
        '/cart/update',
        data: {
          'cart_item_id': cartItemId,
          'quantity': quantity,
        },
      );
      if (response.statusCode != 200) {
        throw ServerException('Failed to update cart');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    try {
      final response = await dio.delete(
        '/cart/remove',
        data: {
          'cart_item_id': cartItemId,
        },
      );
      if (response.statusCode != 200) {
        throw ServerException('Failed to remove from cart');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
