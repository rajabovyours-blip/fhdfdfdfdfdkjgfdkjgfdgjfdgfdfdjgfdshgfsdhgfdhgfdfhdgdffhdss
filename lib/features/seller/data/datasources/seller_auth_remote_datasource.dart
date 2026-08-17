import 'package:milliy_metr/features/seller/domain/entities/seller_registration_entity.dart';
import 'package:milliy_metr/features/seller/domain/entities/seller_verification_entity.dart';

abstract class SellerAuthRemoteDataSource {
  Future<dynamic> registerSeller(SellerRegistrationEntity entity);
  Future<SellerVerificationEntity> getVerificationStatus();
}

class SellerAuthRemoteDataSourceImpl implements SellerAuthRemoteDataSource {
  final dynamic dio;

  SellerAuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<dynamic> registerSeller(SellerRegistrationEntity entity) async {
    return {'success': true};
  }

  @override
  Future<SellerVerificationEntity> getVerificationStatus() async {
    return SellerVerificationEntity(status: 'verified');
  }
}
