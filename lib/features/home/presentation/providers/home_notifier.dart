import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/state/feature_state.dart';
import 'package:milliy_metr/features/home/domain/entities/home_entities.dart';
import 'package:milliy_metr/features/products/domain/entities/product_entity.dart';
import 'package:milliy_metr/features/categories/domain/entities/category_entity.dart';
import 'package:milliy_metr/features/home/presentation/providers/home_providers.dart';

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

    if (bannerResult.isLeft() ||
        categoryResult.isLeft() ||
        productResult.isLeft()) {
      final failure = bannerResult.fold(
        (l) => l,
        (r) => categoryResult.fold(
          (l) => l,
          (r) => productResult.fold((l) => l, (r) => null),
        ),
      );
      state = FeatureState.error(failure!.message);
      return;
    }

    state = FeatureState.loaded(
      HomeData(
        banners: bannerResult.getRight().toNullable()!,
        categories: categoryResult.getRight().toNullable()!,
        featuredProducts: productResult.getRight().toNullable()!,
      ),
    );
  }
}

final homeNotifierProvider =
    StateNotifierProvider<HomeNotifier, FeatureState<HomeData>>((ref) {
  return HomeNotifier(ref);
});
