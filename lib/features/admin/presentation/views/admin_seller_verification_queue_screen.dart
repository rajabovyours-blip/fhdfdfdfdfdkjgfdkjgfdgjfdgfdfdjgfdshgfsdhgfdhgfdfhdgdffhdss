import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:milliy_metr/shared/widgets/app_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/admin/presentation/providers/admin_providers.dart';

class AdminSellerVerificationQueueScreen extends ConsumerWidget {
  const AdminSellerVerificationQueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(adminVerificationQueueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Verification Queue'),
      ),
      body: queueAsync.when(
        data: (queue) {
          if (queue.isEmpty) {
            return const Center(child: Text('No pending verifications.'));
          }
          return ListView.builder(
            itemCount: queue.length,
            itemBuilder: (context, index) {
              final application = queue[index];
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
                          Text(
                            application['business_name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Chip(
                            label: const Text('Pending'),
                            backgroundColor: context.colors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text('Tax ID: '),
                      const Text('Submitted: '),
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
                                  '/admin/sellers/verification/approve',
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
          title: const Text('Reject Application'),
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
                      '/admin/sellers/verification/reject',
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
