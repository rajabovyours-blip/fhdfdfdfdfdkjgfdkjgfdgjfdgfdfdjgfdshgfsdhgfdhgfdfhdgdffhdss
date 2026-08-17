import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/features/seller/data/datasources/seller_inventory_remote_datasource.dart';
import 'package:milliy_metr/features/seller/data/repositories/seller_inventory_repository_impl.dart';
import 'package:milliy_metr/features/seller/domain/repositories/seller_inventory_repository.dart';

final sellerInventoryDataSourceProvider =
    Provider<SellerInventoryRemoteDataSource>((ref) {
  return SellerInventoryRemoteDataSourceImpl(dio: ref.read(dioProvider));
});

final sellerInventoryRepositoryProvider =
    Provider<SellerInventoryRepository>((ref) {
  return SellerInventoryRepositoryImpl(
    remoteDataSource: ref.read(sellerInventoryDataSourceProvider),
  );
});

final sellerInventoryProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.read(sellerInventoryRepositoryProvider);
  final result = await repository.getItems();
  return result.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});
