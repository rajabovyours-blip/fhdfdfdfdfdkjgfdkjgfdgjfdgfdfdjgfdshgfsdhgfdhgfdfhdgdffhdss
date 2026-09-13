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
    if (productId.trim().isEmpty) {
      return const Right([]);
    }
    
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
      // MUHIM: `review.photos` bu bosqichda qurilmadagi MAHALLIY fayl
      // yo'llarini saqlaydi (masalan "/data/user/0/.../image.jpg").
      // Bunday yo'lni to'g'ridan-to'g'ri serverga yuborish ma'nosiz —
      // u faqat shu qurilmada mavjud, boshqa hech kim (hatto admin ham)
      // uni ocholmaydi. Shuning uchun avval har bir rasmni /upload/image
      // orqali serverga yuklab, o'rniga haqiqiy URL olamiz.
      final List<String> uploadedPhotoUrls = [];
      for (final localPath in review.photos) {
        if (localPath.startsWith('http://') ||
            localPath.startsWith('https://')) {
          // Tahrirlashda — bu rasm allaqachon serverda, qayta yuklamaymiz.
          uploadedPhotoUrls.add(localPath);
          continue;
        }
        try {
          final fileName = localPath.split('/').last;
          final formData = FormData.fromMap({
            'file': await MultipartFile.fromFile(
              localPath,
              filename: fileName,
            ),
          });
          final uploadResponse = await dio.post(
            '/upload/image',
            data: formData,
          );
          final url = uploadResponse.data?['data']?['url'] as String?;
          if (url != null) uploadedPhotoUrls.add(url);
        } catch (_) {
          // Bitta rasm yuklanmasa ham butun sharh yuborilishi to'xtamasin —
          // shunchaki o'sha rasmni o'tkazib yuboramiz.
          continue;
        }
      }

      // DIQQAT: manzil `/reviews` EMAS — bunday umumiy manzil backendda
      // mavjud emas va 404 (Not Found) qaytaradi. Sharh har doim aniq
      // mahsulotga bog'liq bo'lgani uchun manzilda mahsulot ID'si bo'lishi
      // shart: /products/{id}/reviews.
      final response = await dio.post(
        '/products/${review.productId}/reviews',
        data: {
          'rating': review.rating,
          'text': review.text,
          'photos': uploadedPhotoUrls,
          'templates': review.templates,
          'wouldBuyAgain': review.wouldBuyAgain,
        },
      );
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
