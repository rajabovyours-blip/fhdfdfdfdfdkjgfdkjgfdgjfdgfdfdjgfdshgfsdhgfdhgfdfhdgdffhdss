import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/state/feature_state.dart';
import 'package:milliy_metr/features/reviews/domain/entities/review_entity.dart';
import 'package:milliy_metr/features/reviews/domain/repositories/review_repository.dart';
import 'package:milliy_metr/features/reviews/data/repositories/review_repository_impl.dart';

import 'package:milliy_metr/core/providers/auth_provider.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return ReviewRepositoryImpl(dio: dio);
});

final productReviewsProvider = StateNotifierProvider.family<
    ProductReviewsNotifier,
    FeatureState<List<ReviewEntity>>,
    String>((ref, productId) {
  return ProductReviewsNotifier(ref.watch(reviewRepositoryProvider), productId);
});

class ProductReviewsNotifier
    extends StateNotifier<FeatureState<List<ReviewEntity>>> {
  final ReviewRepository _repository;
  final String _productId;

  ProductReviewsNotifier(this._repository, this._productId)
      : super(const FeatureState.initial()) {
    loadReviews();
  }

  Future<void> loadReviews() async {
    state = const FeatureState.loading();
    final result = await _repository.getProductReviews(_productId);
    state = result.fold(
      (l) => FeatureState.error(l.message),
      (r) => FeatureState.loaded(r),
    );
  }

  Future<void> addReview(ReviewEntity review) async {
    state.maybeWhen(
      loaded: (reviews) {
        // Optimistic update
        final existingIndex =
            reviews.indexWhere((r) => r.userId == review.userId);
        if (existingIndex >= 0) {
          final updated = List<ReviewEntity>.from(reviews);
          updated[existingIndex] = review;
          state = FeatureState.loaded(updated);
        } else {
          state = FeatureState.loaded([review, ...reviews]);
        }
      },
      orElse: () {},
    );
  }
}

final reviewEligibilityProvider =
    FutureProvider.family<bool, String>((ref, productId) async {
  final repository = ref.watch(reviewRepositoryProvider);
  final result = await repository.checkReviewEligibility(productId);
  return result.fold((l) => false, (r) => r);
});

final userReviewProvider =
    FutureProvider.family<ReviewEntity?, String>((ref, productId) async {
  final repository = ref.watch(reviewRepositoryProvider);
  final result = await repository.getUserReviewForProduct(productId);
  return result.fold((l) => null, (r) => r);
});
