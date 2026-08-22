import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/providers/admin_providers.dart';

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsyncValue = ref.watch(reviewsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('reviews'.tr())),
      body: reviewsAsyncValue.when(
        data: (reviews) {
          if (reviews.isEmpty) {
            return Center(child: Text('no_data'.tr()));
          }
          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final review = reviews[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.star, color: Colors.amber)),
                title: Text(review['product_name'] ?? review['title'] ?? 'Product Review'),
                subtitle: Text(review['comment'] ?? 'No comment provided.'),
                trailing: Text('${review['rating'] ?? 5} / 5'),
              );
            },
          );
        },
        loading: () => Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('loading'.tr()),
          ],
        )),
        error: (error, stack) => Center(child: Text('${'error'.tr()}: $error')),
      ),
    );
  }
}
