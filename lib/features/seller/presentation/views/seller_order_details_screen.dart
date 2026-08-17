import 'package:flutter/material.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:dio/dio.dart';
import 'package:milliy_metr/shared/widgets/app_snackbar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/core/utils/currency_formatter.dart';

class SellerOrderDetailsScreen extends ConsumerWidget {
  final String orderId;
  const SellerOrderDetailsScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /* fetching order details... */
    const orderDetailsAsync = AsyncValue<dynamic>.data(null);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.orderDetails),
      ),
      body: orderDetailsAsync.when(
        data: (order) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order #${order.id.substring(0, 8).toUpperCase()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Chip(
                      label: Text(order.status),
                      backgroundColor: Colors.blue.shade100,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Customer Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text('Address: ${order.deliveryAddress}'),
                // Customer details are limited for privacy
                const SizedBox(height: 24),
                Text(
                  'Items',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                ...order.items.map(
                  (item) => ListTile(
                    title: Text(
                      item.product.name
                          .get(Localizations.localeOf(context).languageCode),
                    ),
                    subtitle: Text('Qty: ${item.quantity}'),
                    trailing: Text(
                      CurrencyFormatter.format(
                        item.product.price * item.quantity,
                        context,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Revenue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(order.total, context),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: context.colors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Update Order Status',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: context.colors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: order.status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: [
                    'pending',
                    'processing',
                    'shipped',
                    'out_for_delivery',
                    'delivered',
                  ]
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.toUpperCase()),
                        ),
                      )
                      .toList(),
                  onChanged: (val) async {
                    if (val != null) {
                      try {
                        await ref.read(dioProvider).post(
                          '/seller/orders/$orderId/status',
                          data: {'status': val},
                        );
                        if (context.mounted) {
                          AppSnackBar.showSuccess(context, 'Status updated');
                        }
                      } on DioException catch (e) {
                        if (context.mounted) {
                          AppSnackBar.showError(context, 'Error: ${e.message}');
                        }
                      }

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Status updated to $val')),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
