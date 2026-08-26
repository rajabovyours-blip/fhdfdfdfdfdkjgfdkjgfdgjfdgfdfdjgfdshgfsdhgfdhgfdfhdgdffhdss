import 'package:dio/dio.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/features/home/data/models/banner_model.dart';
import 'package:milliy_metr/features/products/data/models/product_model.dart';
import 'package:milliy_metr/features/categories/data/models/category_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<BannerModel>> getBanners();
  Future<List<CategoryModel>> getPopularCategories();
  Future<List<ProductModel>> getFeaturedProducts();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final Dio dio;

  HomeRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<BannerModel>> getBanners() async {
    try {
      final response = await dio.get('/banners?active_only=true');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => BannerModel.fromJson(e)).toList();
      } else {
        throw ServerException('Failed to load banners');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }

  @override
  Future<List<CategoryModel>> getPopularCategories() async {
    try {
      final response = await dio.get('/home/popular-categories');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) {
          final map = e as Map<String, dynamic>;
          return CategoryModel.fromJson({
            'id': map['id']?.toString() ?? '',
            'name': map['name'] ?? '',
            'iconUrl': map['icon_url'],
            'isFeatured': map['is_active'] ?? false,
          });
        }).toList();
      } else {
        throw ServerException('Failed to load popular categories');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final response = await dio.get('/home/featured-products');

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) {
          final map = e as Map<String, dynamic>;
          return ProductModel.fromJson({
            'id': map['id']?.toString() ?? '',
            'name': map['name'] ?? '',
            'description': map['description'] ?? {'uz': '', 'ru': '', 'en': ''},
            'images': (map['images'] as List<dynamic>?)?.map((i) {
              if (i is String) return i;
              if (i is Map) return i['image_url']?.toString() ?? '';
              return '';
            }).toList() ?? [],
            'categoryId': '',
            'price': (map['price'] ?? 0).toDouble(),
            'oldPrice': map['old_price'] != null
                ? (map['old_price'] as num).toDouble()
                : null,
            'currency': 'UZS',
            'unit': 'dona',
            'moq': 1,
            'stock': 100,
            'stockStatus': 'in_stock',
            'rating': (map['rating'] ?? 0).toDouble(),
            'reviewCount': 0,
            'location': 'Tashkent',
          });
        }).toList();
      } else {
        throw ServerException('Failed to load featured products');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
