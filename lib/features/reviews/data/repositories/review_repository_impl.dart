import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/reviews/domain/entities/review_entity.dart';
import 'package:milliy_metr/features/reviews/data/models/review_model.dart';
import 'package:milliy_metr/features/reviews/domain/repositories/review_repository.dart';
import 'package:dio/dio.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final Dio dio;

  ReviewRepositoryImpl({required this.dio});

  @override
  Future<Either<Failure, List<ReviewEntity>>> getProductReviews(
    String productId,
  ) async {
    try {
      final response = await dio.get('/products/$productId/reviews');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return Right(data.map((e) => ReviewModel.fromJson(e)).toList());
      }
      return Left(ServerFailure('Failed to load reviews'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity>> submitReview(
    ReviewEntity review,
  ) async {
    try {
      final reviewModel = ReviewModel(
        id: review.id,
        productId: review.productId,
        userId: review.userId,
        userName: review.userName,
        userAvatar: review.userAvatar,
        rating: review.rating,
        text: review.text,
        photos: review.photos,
        isVerifiedPurchase: review.isVerifiedPurchase,
        createdAt: review.createdAt,
        templates: review.templates,
        wouldBuyAgain: review.wouldBuyAgain,
      );
      final response = await dio.post('/reviews', data: reviewModel.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Right(ReviewModel.fromJson(response.data['data']));
      }
      return Left(ServerFailure('Failed to submit review'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkReviewEligibility(String productId) async {
    try {
      final response = await dio.get('/products/$productId/eligibility');
      return Right(response.data['eligible'] ?? false);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> reportReview(
    String reviewId,
    String reason,
  ) async {
    try {
      await dio.post('/reviews/$reviewId/report', data: {'reason': reason});
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReviewEntity?>> getUserReviewForProduct(
    String productId,
  ) async {
    try {
      final response = await dio.get('/products/$productId/user-review');
      if (response.statusCode == 200 && response.data['data'] != null) {
        return Right(ReviewModel.fromJson(response.data['data']));
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
