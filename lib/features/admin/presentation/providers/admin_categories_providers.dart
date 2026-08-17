import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/features/admin/data/datasources/admin_categories_remote_datasource.dart';
import 'package:milliy_metr/features/admin/data/repositories/admin_categories_repository_impl.dart';
import 'package:milliy_metr/features/admin/domain/repositories/admin_categories_repository.dart';

final adminCategoriesDataSourceProvider =
    Provider<AdminCategoriesRemoteDataSource>((ref) {
  return AdminCategoriesRemoteDataSourceImpl(dio: ref.read(dioProvider));
});

final adminCategoriesRepositoryProvider =
    Provider<AdminCategoriesRepository>((ref) {
  return AdminCategoriesRepositoryImpl(
    remoteDataSource: ref.read(adminCategoriesDataSourceProvider),
  );
});

final adminCategoriesProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.read(adminCategoriesRepositoryProvider);
  final result = await repository.getItems();
  return result.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});
