import 'package:dio/dio.dart';
import 'package:milliy_metr/features/reviews/domain/entities/review_entity.dart';

class StoreReviewRemoteDataSourceImpl {
  final Dio dio;
  StoreReviewRemoteDataSourceImpl({required this.dio});

  Future<List<ReviewEntity>> getStoreReviews(String storeId) async {
    try {
      final response = await dio.get('/sellers/$storeId/reviews');
      return (response.data as List).map((json) {
        return ReviewEntity(
          id: json['id'],
          productId: json['product_id'] ?? '',
          userId: json['user_id'],
          userName: json['user_name'],
          rating: json['rating'],
          text: json['text'],
          createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}
