import 'package:dio/dio.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';

class StoreReviewEntity {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const StoreReviewEntity({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory StoreReviewEntity.fromJson(Map<String, dynamic> json) {
    return StoreReviewEntity(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      userName: json['user_name'] as String? ?? 'Anonymous',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

abstract class StoreReviewRemoteDataSource {
  Future<List<StoreReviewEntity>> getStoreReviews(String storeId);
}

class StoreReviewRemoteDataSourceImpl implements StoreReviewRemoteDataSource {
  final Dio dio;

  StoreReviewRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<StoreReviewEntity>> getStoreReviews(String storeId) async {
    try {
      final response = await dio.get('/stores/$storeId/reviews');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data.map((e) => StoreReviewEntity.fromJson(e)).toList();
      } else {
        throw ServerException('Failed to fetch store reviews');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw ServerException(
          'backend endpoint documented: /stores/$storeId/reviews is missing',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
