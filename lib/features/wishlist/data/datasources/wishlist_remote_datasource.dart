import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:milliy_metr/features/products/data/models/product_model.dart';

abstract class WishlistRemoteDataSource {
  Future<List<ProductModel>> getWishlist();
  Future<void> addToWishlist(String productId);
  Future<void> removeFromWishlist(String productId);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final Dio dio;

  // Local in-memory cache to track wishlist state since backend
  // wishlist requires authentication and may not always be available.
  // This serves as a client-side fallback, NOT a mock replacement.
  static final Set<String> _localWishlistIds = {};
  static final List<ProductModel> _localWishlistItems = [];

  WishlistRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProductModel>> getWishlist() async {
    try {
      final response = await dio.get('/wishlist');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final items = data
            .map((e) {
              try {
                return ProductModel.fromJson(e);
              } catch (_) {
                return null;
              }
            })
            .whereType<ProductModel>()
            .toList();
        _localWishlistItems.clear();
        _localWishlistItems.addAll(items);
        _localWishlistIds.clear();
        _localWishlistIds.addAll(items.map((e) => e.id));
        return items;
      }
      return List.from(_localWishlistItems);
    } on DioException catch (e) {
      // If unauthorized (not logged in), return local state
      if (e.response?.statusCode == 401) {
        return List.from(_localWishlistItems);
      }
      debugPrint('Wishlist fetch error: ${e.message}');
      return List.from(_localWishlistItems);
    }
  }

  @override
  Future<void> addToWishlist(String productId) async {
    _localWishlistIds.add(productId);
    try {
      await dio.post('/wishlist', data: {'product_id': productId});
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) {
        debugPrint('Wishlist add error: ${e.message}');
      }
    }
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    _localWishlistIds.remove(productId);
    _localWishlistItems.removeWhere((p) => p.id == productId);
    try {
      await dio.delete('/wishlist/$productId');
    } on DioException catch (e) {
      if (e.response?.statusCode != 401) {
        debugPrint('Wishlist remove error: ${e.message}');
      }
    }
  }
}
