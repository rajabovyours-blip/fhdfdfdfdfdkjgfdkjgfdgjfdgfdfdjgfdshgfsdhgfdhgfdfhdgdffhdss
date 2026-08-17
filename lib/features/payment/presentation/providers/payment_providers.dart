import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:milliy_metr/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:milliy_metr/features/payment/domain/repositories/payment_repository.dart';

final paymentRemoteDataSourceProvider =
    Provider<PaymentRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return PaymentRemoteDataSourceImpl(dio: dio);
});

final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  final remoteDataSource = ref.watch(paymentRemoteDataSourceProvider);
  return PaymentRepositoryImpl(remoteDataSource: remoteDataSource);
});
