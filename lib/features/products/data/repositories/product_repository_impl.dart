import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/core/errors/failures.dart';
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
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
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
