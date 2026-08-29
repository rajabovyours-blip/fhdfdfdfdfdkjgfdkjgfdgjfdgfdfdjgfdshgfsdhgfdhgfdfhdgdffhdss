import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/core/localization/localized_string.dart';
import 'package:milliy_metr/features/products/domain/entities/product_entity.dart';
import 'package:milliy_metr/features/products/data/datasources/product_remote_datasource.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
    Map<String, dynamic>? filters,
  });

  Future<Either<Failure, ProductEntity>> getProductById(String id);
}

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final models = await remoteDataSource.getProducts(
        page: page,
        limit: limit,
        categoryId: categoryId,
        searchQuery: searchQuery,
        filters: filters,
      );
      return Right(models.map((m) => m.toEntity()).toList());
    } on ServerException catch (_) {
      return Right(_filterMockProducts(searchQuery, _getMockProducts()));
    } catch (_) {
      return Right(_filterMockProducts(searchQuery, _getMockProducts()));
    }
  }

  List<ProductEntity> _filterMockProducts(String? query, List<ProductEntity> products) {
    if (query == null || query.trim().isEmpty) return products;
    final lowerQuery = query.toLowerCase();
    return products.where((p) {
      final nameUz = p.name.uz.toLowerCase();
      final nameRu = p.name.ru.toLowerCase();
      final nameEn = p.name.en.toLowerCase();
      return nameUz.contains(lowerQuery) || nameRu.contains(lowerQuery) || nameEn.contains(lowerQuery);
    }).toList();
  }

  List<ProductEntity> _getMockProducts() {
    return [
      ProductEntity(
        id: 'mock_1',
        name: const LocalizedString(uz: 'M 400 Sement (Qopda)', ru: 'Цемент М 400', en: 'M 400 Cement'),
        description: const LocalizedString(uz: 'Yuqori sifatli M 400 sement', ru: 'Высококачественный цемент', en: 'High quality cement'),
        price: 45000,
        currency: 'UZS',
        categoryId: 'sement',
        images: const ['assets/images/categories/cat-2.webp'],
        stock: 100,
        stockStatus: 'in_stock',
        moq: 1,
        unit: 'qop',
        rating: 4.8,
        reviewCount: 15,
        location: 'Tashkent',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProductEntity(
        id: 'mock_2',
        name: const LocalizedString(uz: "Qizil pishgan g'isht", ru: 'Красный кирпич', en: 'Red brick'),
        description: const LocalizedString(uz: "Standart qizil pishgan g'isht", ru: 'Стандартный красный кирпич', en: 'Standard red brick'),
        price: 1200,
        currency: 'UZS',
        categoryId: 'gisht',
        images: const ['assets/images/categories/cat-1.webp'],
        stock: 5000,
        stockStatus: 'in_stock',
        moq: 100,
        unit: 'dona',
        rating: 4.5,
        reviewCount: 42,
        location: 'Tashkent',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    try {
      final model = await remoteDataSource.getProductById(id);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
