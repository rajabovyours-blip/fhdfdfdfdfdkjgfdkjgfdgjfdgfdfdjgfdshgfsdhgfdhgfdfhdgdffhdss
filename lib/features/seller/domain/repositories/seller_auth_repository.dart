import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/seller/domain/entities/seller_registration_entity.dart';
import 'package:milliy_metr/features/seller/domain/entities/seller_verification_entity.dart';

abstract class SellerAuthRepository {
  Future<Either<Failure, dynamic>> registerSeller(
    SellerRegistrationEntity entity,
  );
  Future<Either<Failure, SellerVerificationEntity>> getVerificationStatus();
}
