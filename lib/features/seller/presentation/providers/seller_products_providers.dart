import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/features/seller/data/datasources/seller_products_remote_datasource.dart';
import 'package:milliy_metr/features/seller/data/repositories/seller_products_repository_impl.dart';
import 'package:milliy_metr/features/seller/domain/repositories/seller_products_repository.dart';

final sellerProductsDataSourceProvider =
    Provider<SellerProductsRemoteDataSource>((ref) {
  return SellerProductsRemoteDataSourceImpl(dio: ref.read(dioProvider));
});

final sellerProductsRepositoryProvider =
    Provider<SellerProductsRepository>((ref) {
  return SellerProductsRepositoryImpl(
    remoteDataSource: ref.read(sellerProductsDataSourceProvider),
  );
});

final sellerProductsProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.read(sellerProductsRepositoryProvider);
  final result = await repository.getItems();
  return result.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});
