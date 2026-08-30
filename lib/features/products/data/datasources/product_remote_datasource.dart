import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/core/errors/dio_error_mapper.dart';
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
        if (filters != null)
          ...filters.map((k, v) => MapEntry(
                k.replaceAllMapped(RegExp(r'[A-Z]'),
                    (m) => '_${m.group(0)!.toLowerCase()}',),
                v,
              ),),
      };

      final response = await dio.get(
        '/products',
        queryParameters: Map<String, dynamic>.from(queryParams),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) {
          try {
            return ProductModel.fromJson(e);
          } catch (err, stack) {
            debugPrint('Product parsing error for item: $e\nError: $err\nStack: $stack');
            return null;
          }
        }).whereType<ProductModel>().toList();
      } else {
        throw ServerException('Failed to load products');
      }
    } on DioException catch (e) {
      throw ServerException(DioErrorMapper.extractErrorMessage(e));
    } catch (e, stacktrace) {
      debugPrint('Product parsing error: $e');
      debugPrint(stacktrace.toString());
      throw ServerException(DioErrorMapper.extractErrorMessage(e));
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
      debugPrint('DioException in getProductById: ${e.response?.data}');
      throw ServerException(DioErrorMapper.extractErrorMessage(e));
    } catch (e, stack) {
      debugPrint('Exception in getProductById: $e\n$stack');
      throw ServerException(e.toString());
    }
  }
}

