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
  final String? selectedLocation;
  final String? sortOption;

  const CatalogData({
    required this.products,
    required this.page,
    required this.hasReachedMax,
    this.searchQuery = '',
    this.selectedCategory = 'Barchasi',
    this.minPrice,
    this.maxPrice,
    this.selectedLocation,
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
    String? selectedLocation,
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
      selectedLocation: selectedLocation ?? this.selectedLocation,
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
    if (currentData?.minPrice != null) {
      filters['min_price'] = currentData?.minPrice?.toInt();
    }
    if (currentData?.maxPrice != null) {
      filters['max_price'] = currentData?.maxPrice?.toInt();
    }
    if (currentData?.selectedLocation != null) {
      filters['location'] = currentData?.selectedLocation;
    }
    if (currentData?.sortOption != null) {
      filters['sort'] = currentData?.sortOption;
    }

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
    if (categoryId != null && currentCatId != null && categoryId != currentCatId) {
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

  void setFilters({double? minPrice, double? maxPrice, String? location}) {
    final data = _getCurrentData();
    state = FeatureState.loaded(
      data.copyWith(
        minPrice: minPrice,
        maxPrice: maxPrice,
        selectedLocation: location,
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
        selectedLocation: null,
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
