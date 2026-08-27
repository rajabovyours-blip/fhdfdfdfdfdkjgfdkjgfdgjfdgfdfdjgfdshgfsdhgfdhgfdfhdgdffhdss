import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String _selectedMethod = 'cash';

  @override
  void initState() {
    super.initState();
    _loadPaymentMethod();
  }

  Future<void> _loadPaymentMethod() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedMethod = prefs.getString('selected_payment_method') ?? 'cash';
    });
  }

  Future<void> _savePaymentMethod(String method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_payment_method', method);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          l10n.paymentMethods,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: context.colors.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.paymentMethodSelected),
                  backgroundColor: context.colors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            child: Text(
              'Saqlash', // We can use l10n.save if it's there, but "Saqlash" works too.
              style: TextStyle(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildPaymentCard(
            context,
            id: 'cash',
            icon: Icons.money_outlined,
            title: l10n.cashOnDelivery,
            subtitle: l10n.cashOnDeliveryDesc,
          ),
          const SizedBox(height: 12),
          _buildPaymentCard(
            context,
            id: 'click',
            icon: Icons.touch_app_outlined,
            title: l10n.clickPayment,
            subtitle: l10n.clickPaymentDesc,
          ),
          const SizedBox(height: 12),
          _buildPaymentCard(
            context,
            id: 'card',
            icon: Icons.credit_card_outlined,
            title: l10n.bankCard,
            subtitle: l10n.bankCardDesc,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(
    BuildContext context, {
    required String id,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isSelected = _selectedMethod == id;
    final l10n = context.l10n;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedMethod = id);
        _savePaymentMethod(id);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? context.colors.primary : context.colors.outline,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colors.primary.withValues(alpha: 0.1)
                    : context.colors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? context.colors.primary
                    : context.colors.textMedium,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            color: context.colors.textHigh,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color:
                                context.colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            l10n.defaultPayment,
                            style: TextStyle(
                              color: context.colors.primary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
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
            // ignore: deprecated_member_use
            Radio<String>(
              value: id,
              // ignore: deprecated_member_use
              groupValue: _selectedMethod,
              activeColor: context.colors.primary,
              // ignore: deprecated_member_use
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedMethod = val);
                  _savePaymentMethod(val);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
