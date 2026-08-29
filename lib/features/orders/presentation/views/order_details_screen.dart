import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/shared/widgets/app_button.dart';
import 'package:milliy_metr/features/orders/presentation/providers/order_notifier.dart';
import 'package:intl/intl.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/utils/currency_formatter.dart';

class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderDetailsProvider(orderId));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.orderNumberLabel(orderId))),
      body: orderAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (order) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                '${context.l10n.orderDate}: ${DateFormat.yMMMd().format(order.createdAt)}',
              ),
              Text(
                '${context.l10n.status}: ${order.status}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Divider(),
              Text(
                context.l10n.trackingTimeline,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildTrackingStepper(context, order.status),
              const SizedBox(height: 24),
              const Divider(),
              Text(
                context.l10n.items,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ...order.items.map(
                (item) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 50,
                    height: 50,
                    color: context.colors.surfaceVariant,
                    child: const Icon(Icons.image),
                  ),
                  title: Text(
                    item.product.name
                        .get(Localizations.localeOf(context).languageCode),
                  ),
                  subtitle: Text('${context.l10n.qty}: ${item.quantity}'),
                  trailing: Text(
                    CurrencyFormatter.format(
                      item.product.price * item.quantity,
                      context,
                    ),
                  ),
                ),
              ),
              const Divider(),
              Text(
                context.l10n.deliveryAddress,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(order.deliveryAddress),
              const SizedBox(height: 16),
              Text(
                context.l10n.paymentMethod,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(order.paymentMethod),
              const Divider(),
              Text(
                context.l10n.paymentSummary,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.subtotal),
                  Text(CurrencyFormatter.format(order.subtotal, context)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.delivery),
                  Text(CurrencyFormatter.format(order.shippingFee, context)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.tax),
                  Text(CurrencyFormatter.format(order.tax, context)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(context.l10n.discount),
                  Text('-${CurrencyFormatter.format(order.discount, context)}'),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.total,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    CurrencyFormatter.format(order.total, context),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: context.colors.primary,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: AppButton(
            text: context.l10n.requestRefund,
            isSecondary: true,
            onPressed: () {
              context.push('/return-request');
            },
          ),
        ),
      ),
    );
  }
  Widget _buildTrackingStepper(BuildContext context, String status) {
    final colors = context.colors;
    
    // Determine active step based on status
    int currentStep = 0;
    switch (status.toLowerCase()) {
      case 'pending': currentStep = 0; break;
      case 'processing': currentStep = 1; break;
      case 'shipped': currentStep = 2; break;
      case 'delivered': currentStep = 3; break;
      default: currentStep = 0;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        children: [
          _buildStep(context, 'Buyurtma qabul qilindi', 'Pending', currentStep >= 0, isLast: false),
          _buildStep(context, 'Qadoqlanmoqda', 'Processing', currentStep >= 1, isLast: false),
          _buildStep(context, "Yo'lga chiqdi", 'Shipped', currentStep >= 2, isLast: false),
          _buildStep(context, 'Yetkazib berildi', 'Delivered', currentStep >= 3, isLast: true),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, String title, String subtitle, bool isActive, {bool isLast = false}) {
    final colors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? colors.primary : colors.surface,
                border: Border.all(
                  color: isActive ? colors.primary : colors.outline,
                  width: 2,
                ),
              ),
              child: isActive 
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: isActive ? colors.primary : colors.outline,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive ? colors.textHigh : colors.textMedium,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: colors.textMedium,
                ),
              ),
              if (!isLast) const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
