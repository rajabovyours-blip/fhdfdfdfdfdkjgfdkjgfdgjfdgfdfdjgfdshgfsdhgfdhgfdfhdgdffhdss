import 'package:equatable/equatable.dart';

class ReviewEntity extends Equatable {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String? userAvatar;
  final int rating;
  final String? text;
  final List<String> photos;
  final bool isVerifiedPurchase;
  final DateTime createdAt;
  final List<String> templates;
  final bool? wouldBuyAgain;

  const ReviewEntity({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    this.text,
    this.photos = const [],
    this.isVerifiedPurchase = false,
    required this.createdAt,
    this.templates = const [],
    this.wouldBuyAgain,
  });

  @override
  List<Object?> get props => [
        id,
        productId,
        userId,
        userName,
        userAvatar,
        rating,
        text,
        photos,
        isVerifiedPurchase,
        createdAt,
        templates,
        wouldBuyAgain,
      ];
}
