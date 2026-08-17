import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/features/seller/data/datasources/store_review_remote_datasource.dart';

final storeReviewsProvider =
    FutureProvider.family<List<StoreReviewEntity>, String>(
        (ref, storeId) async {
  final dio = ref.watch(dioProvider);
  final datasource = StoreReviewRemoteDataSourceImpl(dio: dio);
  return datasource.getStoreReviews(storeId);
});

class StoreReviewsTab extends ConsumerWidget {
  final String storeId;

  const StoreReviewsTab({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(storeReviewsProvider(storeId));

    return reviewsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (reviews) {
        if (reviews.isEmpty) {
          return Center(child: Text(context.l10n.noReviewsYetStore));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: reviews.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (context, index) {
            final review = reviews[index];
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      review.userName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(review.rating.toString()),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(review.comment),
              ],
            );
          },
        );
      },
    );
  }
}
