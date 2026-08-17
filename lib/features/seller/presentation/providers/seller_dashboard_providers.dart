import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/seller/domain/entities/seller_dashboard_entity.dart';

final sellerDashboardProvider =
    FutureProvider<SellerDashboardEntity>((ref) async {
  // Return an empty entity until backend is integrated, to satisfy compiler and UI.
  return SellerDashboardEntity.empty();
});
