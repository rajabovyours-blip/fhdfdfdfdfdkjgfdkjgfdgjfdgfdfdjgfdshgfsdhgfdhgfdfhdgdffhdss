import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/features/admin/data/datasources/admin_permissions_remote_datasource.dart';
import 'package:milliy_metr/features/admin/data/repositories/admin_permissions_repository_impl.dart';
import 'package:milliy_metr/features/admin/domain/repositories/admin_permissions_repository.dart';

final adminPermissionsDataSourceProvider =
    Provider<AdminPermissionsRemoteDataSource>((ref) {
  return AdminPermissionsRemoteDataSourceImpl(dio: ref.read(dioProvider));
});

final adminPermissionsRepositoryProvider =
    Provider<AdminPermissionsRepository>((ref) {
  return AdminPermissionsRepositoryImpl(
    remoteDataSource: ref.read(adminPermissionsDataSourceProvider),
  );
});

final adminPermissionsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.read(adminPermissionsRepositoryProvider);
  final result = await repository.getItems();
  return result.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});
