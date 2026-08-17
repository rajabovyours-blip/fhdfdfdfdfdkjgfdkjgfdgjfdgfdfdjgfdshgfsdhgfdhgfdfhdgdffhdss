import 'dart:io';
import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/utils/app_formatters.dart';
import 'package:milliy_metr/features/reviews/domain/entities/review_entity.dart';
import 'package:milliy_metr/features/reviews/presentation/widgets/custom_star_rating.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class ReviewCard extends StatelessWidget {
  final ReviewEntity review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: context.colors.outline,
                backgroundImage: review.userAvatar != null
                    ? NetworkImage(review.userAvatar!)
                    : null,
                child: review.userAvatar == null
                    ? Text(
                        review.userName.isNotEmpty
                            ? review.userName[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: context.colors.textHigh,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: TextStyle(
                        color: context.colors.textHigh,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (review.isVerifiedPurchase)
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: context.colors.success,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            context.l10n.verifiedPurchase,
                            style: TextStyle(
                              color: context.colors.success,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              Text(
                AppFormatters.date(review.createdAt),
                style:
                    TextStyle(color: context.colors.textMedium, fontSize: 12),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // show report options
                },
                child: Icon(
                  Icons.more_vert,
                  color: context.colors.textMedium,
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomStarRating(
            initialRating: review.rating,
            itemSize: 16,
            ignoreGestures: true,
          ),
          const SizedBox(height: 12),
          if (review.templates.isNotEmpty)
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: review.templates.map((template) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.colors.background,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: context.colors.outline),
                  ),
                  child: Text(
                    template,
                    style: TextStyle(
                      color: context.colors.textMedium,
                      fontSize: 11,
                    ),
                  ),
                );
              }).toList(),
            ),
          if (review.templates.isNotEmpty &&
              (review.text != null && review.text!.isNotEmpty))
            const SizedBox(height: 8),
          if (review.text != null && review.text!.isNotEmpty)
            Text(
              review.text!,
              style: TextStyle(
                color: context.colors.textHigh,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          if (review.photos.isNotEmpty) const SizedBox(height: 12),
          if (review.photos.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: review.photos.map((photo) {
                  return GestureDetector(
                    onTap: () {
                      context.push('/review-photo', extra: photo);
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: context.colors.outline),
                        image: DecorationImage(
                          image: photo.startsWith('http')
                              ? NetworkImage(photo) as ImageProvider
                              : FileImage(File(photo)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
