import 'package:flutter/material.dart';

import 'package:milliy_metr/features/admin/presentation/providers/admin_providers.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:milliy_metr/shared/widgets/app_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminProductModerationQueueScreen extends ConsumerWidget {
  const AdminProductModerationQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(adminModerationQueueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Moderation'),
      ),
      body: queueAsync.when(
        data: (queue) {
          if (queue.isEmpty) {
            return const Center(child: Text('No products pending moderation.'));
          }
          return ListView.builder(
            itemCount: queue.length,
            itemBuilder: (context, index) {
              final product = queue[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              product['name'] ?? 'Unknown Product',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const Text(
                            ' UZS',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Seller: '),
                      const Text('Category: '),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              _showRejectDialog(context, index, ref);
                            },
                            child: const Text(
                              'Reject',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () async {
                              try {
                                await ref.read(dioProvider).post(
                                  '/admin/products/moderation/approve',
                                  data: {'id': index},
                                );
                                if (context.mounted) {
                                  AppSnackBar.showSuccess(context, 'Approved');
                                }
                              } on DioException catch (e) {
                                if (context.mounted) {
                                  AppSnackBar.showError(
                                    context,
                                    'Error: ${e.message}',
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                            ),
                            child: const Text('Approve'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  void _showRejectDialog(BuildContext context, int index, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reject Product'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Reason for rejection (Required)',
            ),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  try {
                    await ref.read(dioProvider).post(
                      '/admin/products/moderation/reject',
                      data: {'id': index, 'reason': controller.text},
                    );
                    if (context.mounted) {
                      AppSnackBar.showSuccess(context, 'Rejected');
                    }
                  } on DioException catch (e) {
                    if (context.mounted) {
                      AppSnackBar.showError(context, 'Error: ${e.message}');
                    }
                  }

                  if (!context.mounted) return;
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }
}
