import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:milliy_metr/features/seller/domain/entities/seller_verification_entity.dart';

final sellerVerificationStatusProvider =
    FutureProvider<SellerVerificationEntity>((ref) async {
  return SellerVerificationEntity(status: 'under_review');
});
