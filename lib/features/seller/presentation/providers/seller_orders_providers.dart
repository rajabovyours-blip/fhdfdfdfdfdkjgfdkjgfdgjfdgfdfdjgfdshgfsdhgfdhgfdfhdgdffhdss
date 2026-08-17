import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/features/seller/data/datasources/seller_orders_remote_datasource.dart';
import 'package:milliy_metr/features/seller/data/repositories/seller_orders_repository_impl.dart';
import 'package:milliy_metr/features/seller/domain/repositories/seller_orders_repository.dart';

final sellerOrdersDataSourceProvider =
    Provider<SellerOrdersRemoteDataSource>((ref) {
  return SellerOrdersRemoteDataSourceImpl(dio: ref.read(dioProvider));
});

final sellerOrdersRepositoryProvider = Provider<SellerOrdersRepository>((ref) {
  return SellerOrdersRepositoryImpl(
    remoteDataSource: ref.read(sellerOrdersDataSourceProvider),
  );
});

final sellerOrdersProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.read(sellerOrdersRepositoryProvider);
  final result = await repository.getItems();
  return result.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});
