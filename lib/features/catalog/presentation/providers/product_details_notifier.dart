import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/state/feature_state.dart';
import 'package:milliy_metr/features/products/domain/entities/product_entity.dart';
import 'package:milliy_metr/features/products/presentation/providers/product_providers.dart';
import 'package:milliy_metr/features/catalog/presentation/providers/catalog_notifier.dart' as package_catalog_notifier;

class ProductDetailsNotifier
    extends StateNotifier<FeatureState<ProductEntity>> {
  final Ref _ref;
  final String productId;

  ProductDetailsNotifier(this._ref, this.productId)
      : super(const FeatureState.initial()) {
    loadProduct();
  }

  Future<void> loadProduct() async {
    state = const FeatureState.loading();
    final repository = _ref.read(productRepositoryProvider);
    final result = await repository.getProductById(productId);

    state = result.fold(
      (l) {
        // Fallback to catalog state if possible
        final catalogState = _ref.read(
            package_catalog_notifier.catalogNotifierProvider,);
        ProductEntity? fallbackProduct;
        catalogState.maybeWhen(
          loaded: (data) {
            try {
              fallbackProduct =
                  data.products.firstWhere((p) => p.id == productId);
            } catch (_) {}
          },
          orElse: () {},
        );
        if (fallbackProduct != null) {
          return FeatureState.loaded(fallbackProduct!);
        }
        return FeatureState.error(l.message);
      },
      (r) => FeatureState.loaded(r),
    );
  }
}

final productDetailsNotifierProvider = StateNotifierProvider.family<
    ProductDetailsNotifier,
    FeatureState<ProductEntity>,
    String>((ref, productId) {
  return ProductDetailsNotifier(ref, productId);
});
