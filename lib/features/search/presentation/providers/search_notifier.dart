import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/state/feature_state.dart';
import 'package:milliy_metr/features/products/domain/entities/product_entity.dart';
import 'package:milliy_metr/features/products/presentation/providers/product_providers.dart';
import 'package:milliy_metr/features/search/domain/entities/search_filter_state.dart';

class SearchState {
  final String query;
  final SearchFilterState filters;
  final FeatureState<List<ProductEntity>> results;
  final List<String> recentSearches;

  SearchState({
    required this.query,
    required this.filters,
    required this.results,
    this.recentSearches = const [],
  });

  SearchState copyWith({
    String? query,
    SearchFilterState? filters,
    FeatureState<List<ProductEntity>>? results,
    List<String>? recentSearches,
  }) {
    return SearchState(
      query: query ?? this.query,
      filters: filters ?? this.filters,
      results: results ?? this.results,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }
}

class SearchNotifier extends StateNotifier<SearchState> {
  final Ref _ref;
  Timer? _debounceTimer;

  SearchNotifier(this._ref)
      : super(
          SearchState(
            query: '',
            filters: const SearchFilterState(),
            results: const FeatureState.initial(),
          ),
        );

  void updateQuery(String query) {
    state = state.copyWith(query: query);
    _debounceTimer?.cancel();
    if (query.isEmpty) {
      state = state.copyWith(results: const FeatureState.initial());
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _executeSearch();
      _addRecentSearch(query);
    });
  }

  void updateFilters(SearchFilterState filters) {
    state = state.copyWith(filters: filters);
    _executeSearch();
  }

  void clearSearch() {
    state = state.copyWith(query: '', results: const FeatureState.initial());
  }

  void _addRecentSearch(String query) {
    if (query.isEmpty) return;
    final recent = List<String>.from(state.recentSearches);
    recent.remove(query);
    recent.insert(0, query);
    if (recent.length > 5) recent.removeLast();
    state = state.copyWith(recentSearches: recent);
  }

  Future<void> _executeSearch() async {
    if (state.query.isEmpty && state.filters == const SearchFilterState()) {
      return;
    }

    state = state.copyWith(results: const FeatureState.loading());
    final repository = _ref.read(productRepositoryProvider);

    final result = await repository.getProducts(
      searchQuery: state.query,
      filters: state.filters.toQueryParameters(),
    );

    state = state.copyWith(
      results: result.fold(
        (l) => FeatureState.error(l.message),
        (r) => FeatureState.loaded(r),
      ),
    );
  }
}

final searchNotifierProvider =
    StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(ref);
});
