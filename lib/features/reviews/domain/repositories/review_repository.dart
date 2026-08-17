import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/reviews/domain/entities/review_entity.dart';

abstract class ReviewRepository {
  Future<Either<Failure, List<ReviewEntity>>> getProductReviews(
    String productId,
  );
  Future<Either<Failure, ReviewEntity>> submitReview(ReviewEntity review);
  Future<Either<Failure, bool>> checkReviewEligibility(String productId);
  Future<Either<Failure, Unit>> reportReview(String reviewId, String reason);
  Future<Either<Failure, ReviewEntity?>> getUserReviewForProduct(
    String productId,
  );
}
