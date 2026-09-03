import 'package:dio/dio.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/features/payment/domain/entities/payment_method_entity.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PaymentMethodEntity>> getPaymentMethods();
  Future<String> processPayment(String orderId, String paymentMethodId);
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;

  PaymentRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PaymentMethodEntity>> getPaymentMethods() async {
    try {
      final response = await dio.get('/payment-methods');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data.map((e) => PaymentMethodEntity.fromJson(e)).toList();
      } else {
        throw ServerException('Failed to fetch payment methods');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw ServerException(e.message ?? 'Network error');
    }
  }

  @override
  Future<String> processPayment(String orderId, String paymentMethodId) async {
    try {
      final response = await dio.post(
        '/payments/process',
        data: {
          'order_id': orderId,
          'payment_method_id': paymentMethodId,
        },
      );
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return data['payment_url'] as String;
      } else {
        throw ServerException('Failed to process payment');
      }
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
