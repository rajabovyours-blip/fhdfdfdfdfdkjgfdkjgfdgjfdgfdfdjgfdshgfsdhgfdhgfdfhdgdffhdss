import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/features/admin/data/datasources/admin_dashboard_remote_datasource.dart';
import 'package:milliy_metr/features/admin/data/repositories/admin_dashboard_repository_impl.dart';
import 'package:milliy_metr/features/admin/domain/entities/admin_dashboard_entity.dart';
import 'package:milliy_metr/features/admin/domain/repositories/admin_dashboard_repository.dart';

final adminDashboardRemoteDataSourceProvider =
    Provider<AdminDashboardRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return AdminDashboardRemoteDataSourceImpl(dio: dio);
});

final adminDashboardRepositoryProvider =
    Provider<AdminDashboardRepository>((ref) {
  final remoteDataSource = ref.watch(adminDashboardRemoteDataSourceProvider);
  return AdminDashboardRepositoryImpl(remoteDataSource: remoteDataSource);
});

final adminDashboardProvider =
    FutureProvider<AdminDashboardEntity>((ref) async {
  final repository = ref.watch(adminDashboardRepositoryProvider);
  final result = await repository.getDashboardStatistics();
  return result.fold(
    (l) => throw l.message,
    (r) => r,
  );
});
