import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:milliy_metr/features/home/data/datasources/home_remote_datasource.dart';
import 'package:milliy_metr/features/home/data/repositories/home_repository_impl.dart';

final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return HomeRemoteDataSourceImpl(dio: dio);
});

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final remoteDataSource = ref.watch(homeRemoteDataSourceProvider);
  return HomeRepositoryImpl(remoteDataSource: remoteDataSource);
});
