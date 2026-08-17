import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/shared/widgets/app_button.dart';
import 'package:milliy_metr/features/checkout/presentation/providers/checkout_provider.dart';

class OrderSuccessScreen extends ConsumerWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ref.watch(checkoutProvider).order;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: ListView(
            children: [
              const SizedBox(height: 24),
              Icon(Icons.check_circle, size: 100, color: context.colors.success),
              const SizedBox(height: 24),
              Text(
                context.l10n.orderConfirmed,
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                order == null
                    ? 'Your order has been placed successfully.'
                    : 'Order ${order.orderNumber} has been placed successfully.',
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.textMedium),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Number: ${order?.orderNumber ?? 'N/A'}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Invoice Number: ${order?.invoiceNumber ?? 'N/A'}'),
                      const SizedBox(height: 8),
                      Text(
                        'Payment Status: ${order?.paymentStatus ?? 'Pending'}',
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Delivery Status: ${order?.deliveryStatus ?? 'Packed'}',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                text: 'Track Order',
                onPressed: () => context.push(
                  AppRoutes.orderDetails
                      .replaceFirst(':id', order?.orderNumber ?? 'ORD-1'),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                text: 'Continue Shopping',
                isSecondary: true,
                onPressed: () => context.go(AppRoutes.home),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
