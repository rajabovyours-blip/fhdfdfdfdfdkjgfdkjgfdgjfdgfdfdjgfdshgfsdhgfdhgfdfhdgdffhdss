import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/features/admin/data/datasources/admin_management_remote_datasource.dart';
import 'package:milliy_metr/features/admin/data/repositories/admin_management_repository_impl.dart';
import 'package:milliy_metr/features/admin/domain/repositories/admin_management_repository.dart';

final adminManagementRemoteDataSourceProvider =
    Provider<AdminManagementRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AdminManagementRemoteDataSourceImpl(dio: dio);
});

final adminManagementRepositoryProvider =
    Provider<AdminManagementRepository>((ref) {
  final remoteDataSource = ref.watch(adminManagementRemoteDataSourceProvider);
  return AdminManagementRepositoryImpl(remoteDataSource: remoteDataSource);
});

final adminUsersProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(adminManagementRepositoryProvider);
  final result = await repository.getUsers();
  return result.fold((l) => throw l.message, (r) => r);
});
