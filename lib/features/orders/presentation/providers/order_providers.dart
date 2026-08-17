import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/features/orders/data/datasources/order_remote_datasource.dart';
import 'package:milliy_metr/features/orders/data/repositories/order_repository_impl.dart';
import 'package:milliy_metr/features/orders/domain/repositories/order_repository.dart';

final orderRemoteDataSourceProvider = Provider<OrderRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return OrderRemoteDataSourceImpl(dio: dio);
});

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final remoteDataSource = ref.watch(orderRemoteDataSourceProvider);
  return OrderRepositoryImpl(remoteDataSource: remoteDataSource);
});
