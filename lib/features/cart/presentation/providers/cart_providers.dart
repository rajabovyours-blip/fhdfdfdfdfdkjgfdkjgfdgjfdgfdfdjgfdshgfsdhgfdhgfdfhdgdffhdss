import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/cart/data/datasources/cart_remote_datasource.dart';
import 'package:milliy_metr/features/cart/data/repositories/cart_repository_impl.dart';
import 'package:milliy_metr/features/cart/domain/repositories/cart_repository.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';

final cartRemoteDataSourceProvider = Provider<CartRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return CartRemoteDataSourceImpl(dio: dio);
});

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  final remoteDataSource = ref.watch(cartRemoteDataSourceProvider);
  return CartRepositoryImpl(remoteDataSource: remoteDataSource);
});
