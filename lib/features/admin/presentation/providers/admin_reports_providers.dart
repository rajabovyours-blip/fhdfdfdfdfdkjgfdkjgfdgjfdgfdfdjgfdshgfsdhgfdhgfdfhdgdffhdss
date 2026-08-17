import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/features/admin/data/datasources/admin_reports_remote_datasource.dart';
import 'package:milliy_metr/features/admin/data/repositories/admin_reports_repository_impl.dart';
import 'package:milliy_metr/features/admin/domain/repositories/admin_reports_repository.dart';

final adminReportsDataSourceProvider =
    Provider<AdminReportsRemoteDataSource>((ref) {
  return AdminReportsRemoteDataSourceImpl(dio: ref.read(dioProvider));
});

final adminReportsRepositoryProvider = Provider<AdminReportsRepository>((ref) {
  return AdminReportsRepositoryImpl(
    remoteDataSource: ref.read(adminReportsDataSourceProvider),
  );
});

final adminReportsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.read(adminReportsRepositoryProvider);
  final result = await repository.getItems();
  return result.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});
