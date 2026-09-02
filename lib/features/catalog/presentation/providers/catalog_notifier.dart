import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/state/feature_state.dart';
import 'package:milliy_metr/features/products/domain/entities/product_entity.dart';
import 'package:milliy_metr/features/products/presentation/providers/product_providers.dart';

class CatalogData {
  final List<ProductEntity> products;
  final int page;
  final bool hasReachedMax;
  final String searchQuery;
  final String selectedCategory;
  final double? minPrice;
  final double? maxPrice;
  final String? brand;
  final String? unit;
  final double? minRating;
  final int? maxMoq;
  final bool? hasCertificate;
  final bool? hasDelivery;
  final String? sortOption;

  const CatalogData({
    required this.products,
    required this.page,
    required this.hasReachedMax,
    this.searchQuery = '',
    this.selectedCategory = 'Barchasi',
    this.minPrice,
    this.maxPrice,
    this.brand,
    this.unit,
    this.minRating,
    this.maxMoq,
    this.hasCertificate,
    this.hasDelivery,
    this.sortOption,
  });

  CatalogData copyWith({
    List<ProductEntity>? products,
    int? page,
    bool? hasReachedMax,
    String? searchQuery,
    String? selectedCategory,
    double? minPrice,
    double? maxPrice,
    String? brand,
    String? unit,
    double? minRating,
    int? maxMoq,
    bool? hasCertificate,
    bool? hasDelivery,
    String? sortOption,
  }) {
    return CatalogData(
      products: products ?? this.products,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      brand: brand ?? this.brand,
      unit: unit ?? this.unit,
      minRating: minRating ?? this.minRating,
      maxMoq: maxMoq ?? this.maxMoq,
      hasCertificate: hasCertificate ?? this.hasCertificate,
      hasDelivery: hasDelivery ?? this.hasDelivery,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

class CatalogNotifier extends StateNotifier<FeatureState<CatalogData>> {
  final Ref _ref;

  CatalogNotifier(this._ref) : super(const FeatureState.initial());

  Future<void> loadProducts({bool refresh = false}) async {
    final currentData = state.maybeWhen(
      loaded: (data) => data,
      orElse: () => null,
    );

    if (currentData != null && currentData.hasReachedMax && !refresh) return;

    if (refresh || currentData == null) {
      state = const FeatureState.loading();
    }

    final repository = _ref.read(productRepositoryProvider);
    final pageToLoad = refresh ? 1 : (currentData?.page ?? 1);

    // Extract filters from state
    final searchQuery = currentData?.searchQuery.isNotEmpty == true
        ? currentData?.searchQuery
        : null;

    // The selectedCategory holds the actual category ID, or 'Barchasi' for all
    String? categoryId;
    final catId = currentData?.selectedCategory ?? 'Barchasi';
    if (catId != 'Barchasi') {
      categoryId = catId;
    }

    final filters = <String, dynamic>{};
    if (currentData?.minPrice != null) filters['min_price'] = currentData?.minPrice?.toInt();
    if (currentData?.maxPrice != null) filters['max_price'] = currentData?.maxPrice?.toInt();
    if (currentData?.brand != null) filters['brand'] = currentData?.brand;
    if (currentData?.unit != null) filters['unit'] = currentData?.unit;
    if (currentData?.minRating != null) filters['min_rating'] = currentData?.minRating;
    if (currentData?.maxMoq != null) filters['max_moq'] = currentData?.maxMoq;
    if (currentData?.hasCertificate != null && currentData!.hasCertificate!) filters['has_certificate'] = true;
    if (currentData?.hasDelivery != null && currentData!.hasDelivery!) filters['has_delivery'] = true;
    if (currentData?.sortOption != null) filters['sort_by'] = currentData?.sortOption;

    final result = await repository.getProducts(
      page: pageToLoad,
      limit: 20,
      searchQuery: searchQuery,
      categoryId: categoryId,
      filters: filters.isNotEmpty ? filters : null,
    );

    // Stale request check: if category changed mid-flight, ignore this result
    final currentCatId = state.maybeWhen(
      loaded: (d) => d.selectedCategory,
      orElse: () => null,
    );
    final reqCatId = categoryId ?? 'Barchasi';
    final stateCatId = currentCatId ?? 'Barchasi';
    if (reqCatId != stateCatId) {
      return;
    }

    result.fold(
      (l) {
        state = FeatureState.error(l.message);
      },
      (r) {
        final currentProducts = refresh
            ? <ProductEntity>[]
            : (currentData?.products ?? <ProductEntity>[]);
        state = FeatureState.loaded(
          currentData != null
              ? currentData.copyWith(
                  products: [...currentProducts, ...r],
                  page: pageToLoad + 1,
                  hasReachedMax: r.length < 20,
                )
              : CatalogData(
                  products: [...currentProducts, ...r],
                  page: pageToLoad + 1,
                  hasReachedMax: r.length < 20,
                ),
        );
      },
    );
  }

  CatalogData _getCurrentData() {
    return state.maybeWhen(
      loaded: (data) => data,
      orElse: () => const CatalogData(products: [], page: 1, hasReachedMax: false),
    );
  }

  void setSearchQuery(String query) {
    final data = _getCurrentData();
    state = FeatureState.loaded(data.copyWith(searchQuery: query));
    loadProducts(refresh: true);
  }

  void setCategory(String category) {
    final data = _getCurrentData();
    state = FeatureState.loaded(data.copyWith(selectedCategory: category));
    loadProducts(refresh: true);
  }

  void setFilters({
    double? minPrice, 
    double? maxPrice,
    String? brand,
    String? unit,
    double? minRating,
    int? maxMoq,
    bool? hasCertificate,
    bool? hasDelivery,
  }) {
    final data = _getCurrentData();
    state = FeatureState.loaded(
      data.copyWith(
        minPrice: minPrice,
        maxPrice: maxPrice,
        brand: brand,
        unit: unit,
        minRating: minRating,
        maxMoq: maxMoq,
        hasCertificate: hasCertificate,
        hasDelivery: hasDelivery,
      ),
    );
    loadProducts(refresh: true);
  }

  void clearFilters() {
    final data = _getCurrentData();
    state = FeatureState.loaded(
      data.copyWith(
        minPrice: null,
        maxPrice: null,
        brand: null,
        unit: null,
        minRating: null,
        maxMoq: null,
        hasCertificate: null,
        hasDelivery: null,
        searchQuery: '',
        selectedCategory: 'Barchasi',
        sortOption: null,
      ),
    );
    loadProducts(refresh: true);
  }

  void setSortOption(String sortOption) {
    final data = _getCurrentData();
    state = FeatureState.loaded(data.copyWith(sortOption: sortOption));
    loadProducts(refresh: true);
  }
}

final catalogNotifierProvider =
    StateNotifierProvider<CatalogNotifier, FeatureState<CatalogData>>((ref) {
  return CatalogNotifier(ref)..loadProducts();
});
