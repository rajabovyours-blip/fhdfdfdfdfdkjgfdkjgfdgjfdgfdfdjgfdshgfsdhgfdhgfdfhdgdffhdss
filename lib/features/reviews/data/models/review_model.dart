import 'package:milliy_metr/features/reviews/domain/entities/review_entity.dart';

class ReviewModel extends ReviewEntity {
  const ReviewModel({
    required super.id,
    required super.productId,
    required super.userId,
    required super.userName,
    super.userAvatar,
    required super.rating,
    super.text,
    super.photos = const [],
    super.isVerifiedPurchase = false,
    required super.createdAt,
    super.templates = const [],
    super.wouldBuyAgain,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userAvatar: json['userAvatar'] as String?,
      rating: json['rating'] as int,
      text: json['text'] as String?,
      photos: (json['photos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      isVerifiedPurchase: json['isVerifiedPurchase'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      templates: (json['templates'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      wouldBuyAgain: json['wouldBuyAgain'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userAvatar': userAvatar,
      'rating': rating,
      'text': text,
      'photos': photos,
      'isVerifiedPurchase': isVerifiedPurchase,
      'createdAt': createdAt.toIso8601String(),
      'templates': templates,
      'wouldBuyAgain': wouldBuyAgain,
    };
  }
}
