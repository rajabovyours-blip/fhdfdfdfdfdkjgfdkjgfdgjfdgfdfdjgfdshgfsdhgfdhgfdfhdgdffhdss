import 'package:dio/dio.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/features/products/data/models/product_model.dart';

abstract class WishlistRemoteDataSource {
  Future<List<ProductModel>> getWishlist();
  Future<void> addToWishlist(String productId);
  Future<void> removeFromWishlist(String productId);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final Dio dio;

  WishlistRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProductModel>> getWishlist() async {
    try {
      final response = await dio.get('/wishlist');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => ProductModel.fromJson(e)).toList();
      } else {
        throw ServerException('Failed to load wishlist');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }

  @override
  Future<void> addToWishlist(String productId) async {
    try {
      final response =
          await dio.post('/wishlist', data: {'product_id': productId});
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException('Failed to add to wishlist');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    try {
      final response = await dio.delete('/wishlist/$productId');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ServerException('Failed to remove from wishlist');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
