import 'package:dio/dio.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/features/products/data/models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
    Map<String, dynamic>? filters,
  });

  Future<ProductModel> getProductById(String id);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ProductModel>> getProducts({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'limit': limit,
        if (categoryId != null) 'category_id': categoryId,
        if (searchQuery != null) 'search': searchQuery,
        if (filters != null) ...filters,
      };

      final response = await dio.get('/products', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => ProductModel.fromJson(e)).toList();
      } else {
        throw ServerException('Failed to load products');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      final response = await dio.get('/products/$id');

      if (response.statusCode == 200) {
        return ProductModel.fromJson(response.data['data']);
      } else {
        throw ServerException('Product not found');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
