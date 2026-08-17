import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/reviews/presentation/providers/review_providers.dart';
import 'package:milliy_metr/features/reviews/presentation/widgets/review_card.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class AllReviewsScreen extends ConsumerStatefulWidget {
  final String productId;

  const AllReviewsScreen({super.key, required this.productId});

  @override
  ConsumerState<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends ConsumerState<AllReviewsScreen> {
  late String _selectedFilter;
  late List<String> _filters;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filters = [
      context.l10n.all,
      '5 ★',
      '4 ★',
      '3 ★',
      '2 ★',
      '1 ★',
      context.l10n.withPhotos,
    ];
    _selectedFilter = _filters.first;
  }

  @override
  Widget build(BuildContext context) {
    final reviewsState = ref.watch(productReviewsProvider(widget.productId));

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        iconTheme: IconThemeData(color: context.colors.textHigh),
        title: Text(
          context.l10n.reviews,
          style: TextStyle(color: context.colors.textHigh),
        ),
        centerTitle: true,
      ),
      body: reviewsState.when(
        initial: () => Center(
          child: CircularProgressIndicator(color: context.colors.primary),
        ),
        loading: () => Center(
          child: CircularProgressIndicator(color: context.colors.primary),
        ),
        error: (e) => Center(
          child: Text(e, style: TextStyle(color: context.colors.textHigh)),
        ),
        loaded: (reviews) {
          if (reviews.isEmpty) {
            return Center(
              child: Text(
                context.l10n.noReviewsAvailableYet,
                style: TextStyle(color: context.colors.textHigh),
              ),
            );
          }

          // Calculate summary
          final averageRating =
              reviews.fold(0.0, (sum, item) => sum + item.rating) /
                  reviews.length;

          // Apply filter
          final filteredReviews = reviews.where((review) {
            if (_selectedFilter == context.l10n.all) return true;
            if (_selectedFilter == context.l10n.withPhotos) {
              return review.photos.isNotEmpty;
            }
            final star = int.parse(_selectedFilter.split(' ')[0]);
            return review.rating == star;
          }).toList();

          return CustomScrollView(
            slivers: [
              // Summary Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                averageRating.toStringAsFixed(1),
                                style: TextStyle(
                                  color: context.colors.textHigh,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.star,
                                color: context.colors.warning,
                                size: 24,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            context.l10n.reviewsCountLabel(reviews.length),
                            style: TextStyle(
                              color: context.colors.textMedium,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Filter Chips
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _filters.map((filter) {
                      final isSelected = _selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedFilter = filter;
                            });
                          },
                          backgroundColor: context.colors.surface,
                          selectedColor:
                              context.colors.primary.withValues(alpha: 0.15),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? context.colors.primary
                                : context.colors.textMedium,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected
                                ? context.colors.primary
                                : context.colors.outline,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Reviews List
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 16, right: 16, bottom: 16,),
                      child: ReviewCard(review: filteredReviews[index]),
                    );
                  },
                  childCount: filteredReviews.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
