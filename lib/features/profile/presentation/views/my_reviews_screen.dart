import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/features/reviews/domain/entities/review_entity.dart';
import 'package:milliy_metr/features/reviews/presentation/widgets/review_card.dart';
import 'package:go_router/go_router.dart';

class MyReviewsScreen extends StatelessWidget {
  MyReviewsScreen({super.key});

  final List<ReviewEntity> _reviews = [];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          l10n.myReviews,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: context.colors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: _reviews.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: context.colors.surface,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.colors.outline),
                    ),
                    child: Icon(
                      Icons.star_outline,
                      size: 48,
                      color: context.colors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.noReviewsWritten,
                    style: TextStyle(
                      color: context.colors.textHigh,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Siz hali sharh qoldirmadingiz",
                    style: TextStyle(
                      color: context.colors.textMedium,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 48,
                    width: 200,
                    child: ElevatedButton(
                      onPressed: () => context.go('/home'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Xarid qilish",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _reviews.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return ReviewCard(review: _reviews[index]);
              },
            ),
    );
  }
}
