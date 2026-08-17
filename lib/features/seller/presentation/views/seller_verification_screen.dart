import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/seller/presentation/providers/seller_auth_providers.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';

class SellerVerificationScreen extends ConsumerWidget {
  const SellerVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(sellerVerificationStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.verificationStatus),
      ),
      body: statusAsync.when(
        data: (entity) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  _getIconForStatus(entity.status),
                  size: 64,
                  color: _getColorForStatus(context, entity.status),
                ),
                const SizedBox(height: 24),
                Text(
                  'Application Status: ${entity.status.toUpperCase()}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (entity.rejectionReason != null &&
                    entity.rejectionReason!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: context.colors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: context.colors.danger),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rejection Reason:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: context.colors.danger,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entity.rejectionReason!,
                          style: TextStyle(color: context.colors.danger),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  IconData _getIconForStatus(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle_outline;
      case 'rejected':
      case 'suspended':
        return Icons.error_outline;
      case 'under_review':
        return Icons.hourglass_empty;
      default:
        return Icons.info_outline;
    }
  }

  Color _getColorForStatus(BuildContext context, String status) {
    switch (status) {
      case 'approved':
        return context.colors.success;
      case 'rejected':
      case 'suspended':
        return context.colors.danger;
      case 'under_review':
        return context.colors.secondary;
      default:
        return context.colors.primary;
    }
  }
}
