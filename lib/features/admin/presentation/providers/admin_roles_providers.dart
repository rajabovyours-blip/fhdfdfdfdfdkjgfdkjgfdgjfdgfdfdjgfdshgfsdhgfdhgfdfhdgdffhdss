import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/features/admin/data/datasources/admin_roles_remote_datasource.dart';
import 'package:milliy_metr/features/admin/data/repositories/admin_roles_repository_impl.dart';
import 'package:milliy_metr/features/admin/domain/repositories/admin_roles_repository.dart';

final adminRolesDataSourceProvider =
    Provider<AdminRolesRemoteDataSource>((ref) {
  return AdminRolesRemoteDataSourceImpl(dio: ref.read(dioProvider));
});

final adminRolesRepositoryProvider = Provider<AdminRolesRepository>((ref) {
  return AdminRolesRepositoryImpl(
    remoteDataSource: ref.read(adminRolesDataSourceProvider),
  );
});

final adminRolesProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.read(adminRolesRepositoryProvider);
  final result = await repository.getItems();
  return result.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});
