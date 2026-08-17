import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:milliy_metr/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:milliy_metr/features/categories/data/repositories/category_repository_impl.dart';

final categoryRemoteDataSourceProvider =
    Provider<CategoryRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return CategoryRemoteDataSourceImpl(dio: dio);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final remoteDataSource = ref.watch(categoryRemoteDataSourceProvider);
  return CategoryRepositoryImpl(remoteDataSource: remoteDataSource);
});
