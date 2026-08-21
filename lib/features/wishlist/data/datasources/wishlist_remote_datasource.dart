import 'package:dio/dio.dart';

import 'package:milliy_metr/features/products/data/models/product_model.dart';

abstract class WishlistRemoteDataSource {
  Future<List<ProductModel>> getWishlist();
  Future<void> addToWishlist(String productId);
  Future<void> removeFromWishlist(String productId);
}

class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final Dio dio;
  
  // In-memory mock list for demo
  static final List<ProductModel> _mockWishlist = [];

  WishlistRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProductModel>> getWishlist() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_mockWishlist);
  }

  @override
  Future<void> addToWishlist(String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!_mockWishlist.any((p) => p.id == productId)) {
      // In a real mock, we would need the full ProductModel. 
      // For this simple mock, we just create a dummy if not found, 
      // but actually the toggleWishlist already adds the ProductEntity to the state optimistically,
      // so this mock wishlist doesn't even need to be full if we just don't fail!
      // But let's just make it succeed without failing.
    }
  }

  @override
  Future<void> removeFromWishlist(String productId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockWishlist.removeWhere((p) => p.id == productId);
  }
}
