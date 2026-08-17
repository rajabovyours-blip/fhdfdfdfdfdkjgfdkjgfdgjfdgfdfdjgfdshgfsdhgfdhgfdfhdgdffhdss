import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/payment/domain/entities/payment_method_entity.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<PaymentMethodEntity>>> getPaymentMethods();
  Future<Either<Failure, void>> processPayment(
    String orderId,
    String paymentMethodId,
  );
}
