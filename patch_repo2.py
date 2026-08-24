with open('dart_categories.txt', 'r', encoding='utf-8') as f:
    hardcoded = f.read().replace('\ufeff', '')

with open('lib/features/categories/data/repositories/category_repository_impl.dart', 'r', encoding='utf-8') as f:
    content = f.read()

import re

target = """  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    bool tree = true,
  }) async {
    try {
      final models = await remoteDataSource.getCategories(tree: tree);
      return Right(models.map((e) => e.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }"""

replacement = """  @override
  Future<Either<Failure, List<CategoryEntity>>> getCategories({
    bool tree = true,
  }) async {
    return Right(_hardcodedCategories);
  }
\n""" + hardcoded

content = content.replace(target, replacement)

with open('lib/features/categories/data/repositories/category_repository_impl.dart', 'w', encoding='utf-8') as f:
    f.write(content)
