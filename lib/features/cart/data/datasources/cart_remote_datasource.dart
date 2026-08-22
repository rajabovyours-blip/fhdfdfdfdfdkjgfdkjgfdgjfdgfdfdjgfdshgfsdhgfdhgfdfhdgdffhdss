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
        '/cart/items',
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
    // The backend doesn't have an explicit update endpoint yet, but addToCart handles quantity additions.
    // If we need a strict set quantity, we'd need a backend endpoint. For now, we'll just skip or add.
    // Ideally we'd have /cart/items/{id} PUT. Let's just use POST /cart/items if the cart is additive.
    // Wait, the UI might send an absolute quantity. The backend adds to existing. This is a mismatch.
    // We'll leave this as a dummy call for now, since UI doesn't use it or it's unhandled.
    throw ServerException('Update not fully supported by backend');
  }

  @override
  Future<void> removeFromCart(String cartItemId) async {
    try {
      final response = await dio.delete(
        '/cart/items/$cartItemId',
      );
      if (response.statusCode != 200) {
        throw ServerException('Failed to remove from cart');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
