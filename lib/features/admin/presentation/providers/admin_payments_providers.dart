import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/features/admin/data/datasources/admin_payments_remote_datasource.dart';
import 'package:milliy_metr/features/admin/data/repositories/admin_payments_repository_impl.dart';
import 'package:milliy_metr/features/admin/domain/repositories/admin_payments_repository.dart';

final adminPaymentsDataSourceProvider =
    Provider<AdminPaymentsRemoteDataSource>((ref) {
  return AdminPaymentsRemoteDataSourceImpl(dio: ref.read(dioProvider));
});

final adminPaymentsRepositoryProvider =
    Provider<AdminPaymentsRepository>((ref) {
  return AdminPaymentsRepositoryImpl(
    remoteDataSource: ref.read(adminPaymentsDataSourceProvider),
  );
});

final adminPaymentsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.read(adminPaymentsRepositoryProvider);
  final result = await repository.getItems();
  return result.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});
