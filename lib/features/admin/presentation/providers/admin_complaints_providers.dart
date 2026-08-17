import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/features/admin/data/datasources/admin_complaints_remote_datasource.dart';
import 'package:milliy_metr/features/admin/data/repositories/admin_complaints_repository_impl.dart';
import 'package:milliy_metr/features/admin/domain/repositories/admin_complaints_repository.dart';

final adminComplaintsDataSourceProvider =
    Provider<AdminComplaintsRemoteDataSource>((ref) {
  return AdminComplaintsRemoteDataSourceImpl(dio: ref.read(dioProvider));
});

final adminComplaintsRepositoryProvider =
    Provider<AdminComplaintsRepository>((ref) {
  return AdminComplaintsRepositoryImpl(
    remoteDataSource: ref.read(adminComplaintsDataSourceProvider),
  );
});

final adminComplaintsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.read(adminComplaintsRepositoryProvider);
  final result = await repository.getItems();
  return result.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});
