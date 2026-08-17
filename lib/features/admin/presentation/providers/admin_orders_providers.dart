import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/features/admin/data/datasources/admin_orders_remote_datasource.dart';
import 'package:milliy_metr/features/admin/data/repositories/admin_orders_repository_impl.dart';
import 'package:milliy_metr/features/admin/domain/repositories/admin_orders_repository.dart';

final adminOrdersDataSourceProvider =
    Provider<AdminOrdersRemoteDataSource>((ref) {
  return AdminOrdersRemoteDataSourceImpl(dio: ref.read(dioProvider));
});

final adminOrdersRepositoryProvider = Provider<AdminOrdersRepository>((ref) {
  return AdminOrdersRepositoryImpl(
    remoteDataSource: ref.read(adminOrdersDataSourceProvider),
  );
});

final adminOrdersProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.read(adminOrdersRepositoryProvider);
  final result = await repository.getItems();
  return result.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});
