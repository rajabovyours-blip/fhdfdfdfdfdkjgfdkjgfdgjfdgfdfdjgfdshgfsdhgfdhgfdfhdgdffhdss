import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/home/domain/entities/home_entities.dart';
import 'package:milliy_metr/features/products/domain/entities/product_entity.dart';
import 'package:milliy_metr/features/categories/domain/entities/category_entity.dart';
import 'package:milliy_metr/features/home/data/datasources/home_remote_datasource.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<BannerEntity>>> getBanners();
  Future<Either<Failure, List<CategoryEntity>>> getPopularCategories();
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts();
}

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;

  HomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<BannerEntity>>> getBanners() async {
    try {
      final models = await remoteDataSource.getBanners();
      return Right(models.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryEntity>>> getPopularCategories() async {
    try {
      final models = await remoteDataSource.getPopularCategories();
      return Right(models.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductEntity>>> getFeaturedProducts() async {
    try {
      final models = await remoteDataSource.getFeaturedProducts();
      return Right(models.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
