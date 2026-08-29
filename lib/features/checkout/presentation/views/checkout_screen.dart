import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/shared/widgets/app_button.dart';
import 'package:milliy_metr/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/features/checkout/presentation/widgets/delivery_address_card.dart';
import 'package:milliy_metr/features/checkout/presentation/widgets/payment_method_selector.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(checkoutProvider.notifier).load());
  }

  String _formatCurrency(double amount) {
    final format = NumberFormat.currency(
      locale: 'uz_UZ',
      symbol: 'UZS',
      decimalDigits: 0,
      customPattern: '#,##0 \u00A4',
    );
    return format.format(amount).replaceAll(',', ' ');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutProvider);
    final notifier = ref.read(checkoutProvider.notifier);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          l10n.checkout,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: context.colors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: state.isLoading
          ? Center(
              child: CircularProgressIndicator(color: context.colors.primary),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    children: [
                      // Address Section
                      _buildSectionHeader(context, l10n.deliveryAddress),
                      const SizedBox(height: 12),
                      DeliveryAddressCard(
                        address: state.selectedAddress,
                        onTap: () => context.push(AppRoutes.addresses),
                      ),
                      const SizedBox(height: 24),

                      // Delivery Method
                      _buildSectionHeader(context, l10n.deliveryMethod),
                      const SizedBox(height: 12),
                      _buildDeliveryMethodSelector(state, notifier),
                      const SizedBox(height: 24),

                      // Payment Method
                      _buildSectionHeader(context, l10n.paymentMethod),
                      const SizedBox(height: 12),
                      PaymentMethodSelector(
                        selectedMethodId: state.paymentMethod,
                        onMethodSelected: notifier.setPaymentMethod,
                      ),
                      const SizedBox(height: 24),

                      // Coupon Code
                      _buildSectionHeader(context, l10n.couponCode),
                      const SizedBox(height: 12),
                      TextField(
                        style: TextStyle(color: context.colors.textHigh),
                        decoration: InputDecoration(
                          hintText: l10n.enterCouponCode,
                          hintStyle: TextStyle(
                            color: context.colors.textMedium
                                .withValues(alpha: 0.5),
                          ),
                          filled: true,
                          fillColor: context.colors.surfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(
                            Icons.local_offer_outlined,
                            color: context.colors.textMedium,
                          ),
                        ),
                        onChanged: notifier.setCouponCode,
                      ),
                      const SizedBox(height: 24),

                      // Order Summary
                      _buildSectionHeader(context, l10n.orderSummary),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: context.colors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: context.colors.outline),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow(
                              context,
                              l10n.subtotal,
                              _formatCurrency(notifier.subtotal),
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              context,
                              l10n.shipping,
                              _formatCurrency(notifier.shippingFee),
                            ),
                            const SizedBox(height: 8),
                            _buildSummaryRow(
                              context,
                              l10n.tax,
                              _formatCurrency(notifier.tax),
                            ),
                            if (notifier.discount > 0) ...[
                              const SizedBox(height: 8),
                              _buildSummaryRow(
                                context,
                                l10n.discount,
                                '-${_formatCurrency(notifier.discount)}',
                                isDiscount: true,
                              ),
                            ],
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Divider(),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  l10n.total,
                                  style: TextStyle(
                                    color: context.colors.textHigh,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _formatCurrency(notifier.total),
                                  style: TextStyle(
                                    color: context.colors.primary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),


                      const SizedBox(height: 40),
                    ],
                  ),
                ),

                // Bottom CTA
                Container(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    16,
                    20,
                    MediaQuery.of(context).padding.bottom + 16,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        offset: const Offset(0, -4),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: AppButton(
                    text: state.isSubmitting
                        ? l10n.placingOrder
                        : l10n.payAmount(_formatCurrency(notifier.total)),
                    isLoading: state.isSubmitting,
                    onPressed: () async {
                      await notifier.placeOrder();
                      if (!context.mounted) return;
                      final error = ref.read(checkoutProvider).error;
                      if (error != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error),
                            backgroundColor: context.colors.danger,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      } else if (ref.read(checkoutProvider).order != null) {
                        context.go(AppRoutes.orderSuccess);
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: context.colors.textHigh,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isDiscount = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: context.colors.textMedium, fontSize: 14),
        ),
        Text(
          value,
          style: TextStyle(
            color:
                isDiscount ? context.colors.success : context.colors.textHigh,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryMethodSelector(
    CheckoutState state,
    CheckoutNotifier notifier,
  ) {
    return Column(
      children: [
        _DeliveryOptionCard(
          title: context.l10n.deliveryService,
          subtitle: '',
          price: _formatCurrency(50000),
          value: 'Delivery Service',
          groupValue: state.deliveryMethod,
          onChanged: (v) => notifier.setDeliveryMethod(v!),
        ),
        const SizedBox(height: 8),
        _DeliveryOptionCard(
          title: context.l10n.pickupFromWarehouse,
          subtitle: '',
          price: _formatCurrency(0),
          value: 'Pickup from warehouse',
          groupValue: state.deliveryMethod,
          onChanged: (v) => notifier.setDeliveryMethod(v!),
        ),
      ],
    );
  }
}

class _DeliveryOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;

  const _DeliveryOptionCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(value),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  isSelected ? context.colors.primary : context.colors.outline,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // ignore: deprecated_member_use
              Radio<String>(
                value: value,
                // ignore: deprecated_member_use
                groupValue: groupValue,
                // ignore: deprecated_member_use
                onChanged: onChanged,
                activeColor: context.colors.primary,
                visualDensity:
                    const VisualDensity(horizontal: -4, vertical: -4),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: context.colors.textHigh,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: context.colors.textMedium,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  color: context.colors.textHigh,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
