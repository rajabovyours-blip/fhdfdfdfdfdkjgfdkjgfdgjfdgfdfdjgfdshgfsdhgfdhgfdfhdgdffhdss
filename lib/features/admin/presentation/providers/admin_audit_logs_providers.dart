import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/features/admin/data/datasources/admin_audit_logs_remote_datasource.dart';
import 'package:milliy_metr/features/admin/data/repositories/admin_audit_logs_repository_impl.dart';
import 'package:milliy_metr/features/admin/domain/repositories/admin_audit_logs_repository.dart';

final adminAuditLogsDataSourceProvider =
    Provider<AdminAuditLogsRemoteDataSource>((ref) {
  return AdminAuditLogsRemoteDataSourceImpl(dio: ref.read(dioProvider));
});

final adminAuditLogsRepositoryProvider =
    Provider<AdminAuditLogsRepository>((ref) {
  return AdminAuditLogsRepositoryImpl(
    remoteDataSource: ref.read(adminAuditLogsDataSourceProvider),
  );
});

final adminAuditLogsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.read(adminAuditLogsRepositoryProvider);
  final result = await repository.getItems();
  return result.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});
