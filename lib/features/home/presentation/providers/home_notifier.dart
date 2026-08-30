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

    var banners = bannerResult.fold((l) => <BannerEntity>[], (r) => r);
    if (banners.isEmpty) {
      banners = [
        BannerEntity(
          id: 'banner_1',
          imageUrl: 'assets/images/categories/cat-1.webp',
          linkUrl: '',
          title: const LocalizedString(uz: 'Qurilish uchun kerakli barcha materiallar bir joyda', ru: 'Все необходимые строительные материалы в одном месте', en: 'All the necessary construction materials in one place'),
          subtitle: const LocalizedString(uz: 'Eng yaxshi narxlar kafolati', ru: 'Гарантия лучших цен', en: 'Best price guarantee'),
          cta: const LocalizedString(uz: 'Xarid qilish', ru: 'В магазин', en: 'Shop now'),
        ),
        BannerEntity(
          id: 'banner_2',
          imageUrl: 'assets/images/categories/cat-2.webp',
          linkUrl: '',
          title: const LocalizedString(uz: 'Katta chegirmalar mavsumi', ru: 'Сезон больших скидок', en: 'Huge discount season'),
          subtitle: const LocalizedString(uz: 'Ommabop mahsulotlarga 20% gacha chegirma', ru: 'Скидки до 20% на популярные товары', en: 'Up to 20% off on popular products'),
          cta: const LocalizedString(uz: "Ko'rish", ru: 'Посмотреть', en: 'View'),
        ),
      ];
    }

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
