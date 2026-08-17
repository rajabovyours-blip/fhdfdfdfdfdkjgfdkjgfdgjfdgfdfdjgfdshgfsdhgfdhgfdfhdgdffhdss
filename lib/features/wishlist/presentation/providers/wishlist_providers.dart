import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:milliy_metr/features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import 'package:milliy_metr/features/wishlist/data/repositories/wishlist_repository_impl.dart';

final wishlistRemoteDataSourceProvider =
    Provider<WishlistRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return WishlistRemoteDataSourceImpl(dio: dio);
});

final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final remoteDataSource = ref.watch(wishlistRemoteDataSourceProvider);
  return WishlistRepositoryImpl(remoteDataSource: remoteDataSource);
});
