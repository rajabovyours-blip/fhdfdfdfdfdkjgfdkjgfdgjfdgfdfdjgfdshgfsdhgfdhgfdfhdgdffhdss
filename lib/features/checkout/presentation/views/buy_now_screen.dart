import 'package:flutter/material.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/shared/widgets/app_button.dart';
import 'package:milliy_metr/features/checkout/presentation/providers/checkout_provider.dart';

class BuyNowScreen extends ConsumerStatefulWidget {
  final String productId;

  const BuyNowScreen({super.key, required this.productId});

  @override
  ConsumerState<BuyNowScreen> createState() => _BuyNowScreenState();
}

class _BuyNowScreenState extends ConsumerState<BuyNowScreen> {
  int quantity = 1;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(checkoutProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(checkoutProvider.notifier);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.buyNow)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quantity',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: () => setState(
                    () => quantity = quantity > 1 ? quantity - 1 : 1,
                  ),
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text(quantity.toString()),
                IconButton(
                  onPressed: () => setState(() => quantity = quantity + 1),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Delivery Method',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: 'Standard Delivery',
              items: [
                DropdownMenuItem(
                  value: 'Standard Delivery',
                  child: Text(context.l10n.standardDelivery),
                ),
                DropdownMenuItem(
                  value: 'Express Delivery',
                  child: Text(context.l10n.expressDelivery),
                ),
                DropdownMenuItem(
                  value: 'Pickup',
                  child: Text(context.l10n.pickup),
                ),
              ],
              onChanged: (value) =>
                  notifier.setDeliveryMethod(value ?? 'Standard Delivery'),
            ),
            const SizedBox(height: 24),
            AppButton(
              text: 'Place Order',
              onPressed: () => context.push(AppRoutes.orderSuccess),
            ),
          ],
        ),
      ),
    );
  }
}
