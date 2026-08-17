import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/products/data/datasources/product_remote_datasource.dart';

import 'package:milliy_metr/features/products/data/repositories/product_repository_impl.dart';

import 'package:milliy_metr/core/providers/auth_provider.dart';

final productRemoteDataSourceProvider =
    Provider<ProductRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ProductRemoteDataSourceImpl(dio: dio);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteDataSource = ref.watch(productRemoteDataSourceProvider);
  return ProductRepositoryImpl(remoteDataSource: remoteDataSource);
});
