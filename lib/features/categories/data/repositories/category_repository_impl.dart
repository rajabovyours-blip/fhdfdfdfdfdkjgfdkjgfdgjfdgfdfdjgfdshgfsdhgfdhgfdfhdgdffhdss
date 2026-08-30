import 'package:fpdart/fpdart.dart';

import 'package:milliy_metr/core/errors/failures.dart';

import 'package:milliy_metr/features/categories/domain/entities/category_entity.dart';
import 'package:milliy_metr/features/categories/data/datasources/category_remote_datasource.dart';

abstract class CategoryRepository {
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    bool tree = true,
  });
}

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDataSource remoteDataSource;

  CategoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    bool tree = true,
  }) async {
    try {
      final categories = await remoteDataSource.getCategories(tree: tree);
      final entities = categories.map((e) => e.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      if (e is Failure) return Left(e);
      return Left(ServerFailure(e.toString()));
    }
  }
}
