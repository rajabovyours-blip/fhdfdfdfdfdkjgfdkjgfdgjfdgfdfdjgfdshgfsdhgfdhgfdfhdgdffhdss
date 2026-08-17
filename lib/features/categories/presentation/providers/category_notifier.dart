import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/state/feature_state.dart';
import 'package:milliy_metr/features/categories/domain/entities/category_entity.dart';
import 'package:milliy_metr/features/categories/presentation/providers/category_providers.dart';

class CategoryNotifier
    extends StateNotifier<FeatureState<List<CategoryEntity>>> {
  final Ref _ref;

  CategoryNotifier(this._ref) : super(const FeatureState.initial()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const FeatureState.loading();
    final repository = _ref.read(categoryRepositoryProvider);
    final result = await repository.getCategories(tree: true);

    state = result.fold(
      (l) => FeatureState.error(l.message),
      (r) => FeatureState.loaded(r),
    );
  }
}

final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, FeatureState<List<CategoryEntity>>>(
        (ref) {
  return CategoryNotifier(ref);
});
