import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/state/feature_state.dart';
import 'package:milliy_metr/features/home/domain/entities/home_entities.dart';
import 'package:milliy_metr/features/products/domain/entities/product_entity.dart';
import 'package:milliy_metr/features/categories/domain/entities/category_entity.dart';
import 'package:milliy_metr/features/home/presentation/providers/home_providers.dart';
import 'package:milliy_metr/core/localization/localized_string.dart';

class HomeData {
  final List<BannerEntity> banners;
  final List<CategoryEntity> categories;
  final List<ProductEntity> featuredProducts;

  const HomeData({
    required this.banners,
    required this.categories,
    required this.featuredProducts,
  });
}

class HomeNotifier extends StateNotifier<FeatureState<HomeData>> {
  final Ref _ref;

  HomeNotifier(this._ref) : super(const FeatureState.initial()) {
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    state = const FeatureState.loading();

    final repository = _ref.read(homeRepositoryProvider);

    final bannerResult = await repository.getBanners();
    final categoryResult = await repository.getPopularCategories();
    final productResult = await repository.getFeaturedProducts();

    if (!mounted) return;

    final banners = bannerResult.fold((l) => <BannerEntity>[], (r) => r);
    final categories = categoryResult.fold((l) => <CategoryEntity>[], (r) => r);
    final products = productResult.fold((l) => <ProductEntity>[], (r) => r);

    state = FeatureState.loaded(
      HomeData(
        banners: banners,
        categories: categories,
        featuredProducts: products,
      ),
    );
  }
}

final homeNotifierProvider =
    StateNotifierProvider<HomeNotifier, FeatureState<HomeData>>((ref) {
  return HomeNotifier(ref);
});
