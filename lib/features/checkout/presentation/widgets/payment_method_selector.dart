import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/features/checkout/presentation/widgets/add_card_bottom_sheet.dart';

class PaymentMethodItem {
  final String id;
  final String name;
  final String? description;
  final String? iconAsset;
  final IconData? fallbackIcon;

  PaymentMethodItem({
    required this.id,
    required this.name,
    this.description,
    this.iconAsset,
    this.fallbackIcon,
  });
}

class PaymentMethodSelector extends StatelessWidget {
  final String selectedMethodId;
  final ValueChanged<String> onMethodSelected;

  const PaymentMethodSelector({
    super.key,
    required this.selectedMethodId,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final methods = [
      PaymentMethodItem(
        id: 'Payme',
        name: 'Payme',
        iconAsset: 'assets/svg/payment_payme.svg',
      ),
      PaymentMethodItem(
        id: 'Click',
        name: 'Click',
        iconAsset: 'assets/svg/payment_click.svg',
      ),
      PaymentMethodItem(
        id: 'Visa',
        name: 'Visa',
        iconAsset: 'assets/svg/payment_visa.svg',
      ),
      PaymentMethodItem(
        id: 'Mastercard',
        name: 'Mastercard',
        iconAsset: 'assets/svg/payment_mastercard.svg',
      ),
      PaymentMethodItem(
        id: 'Cash on Delivery',
        name: l10n.cashOnDelivery,
        description: l10n.cashOnDeliveryDesc,
        iconAsset: 'assets/svg/payment_cash.svg',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...methods.map(
          (method) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _PaymentCard(
              method: method,
              isSelected: selectedMethodId == method.id,
              onTap: () => onMethodSelected(method.id),
            ),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => const AddCardBottomSheet(),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.colors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.colors.outline.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: context.colors.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.addCard,
                  style: TextStyle(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final PaymentMethodItem method;
  final bool isSelected;
  final VoidCallback onTap;

  const _PaymentCard({
    required this.method,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isSelected ? context.colors.primary : context.colors.outline,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: context.colors.primary.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              _buildIcon(context),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.name,
                      style: TextStyle(
                        color: context.colors.textHigh,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (method.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        method.description!,
                        style: TextStyle(
                          color: context.colors.textMedium,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16),
              _buildRadio(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    return Container(
      width: 50,
      height: 30,
      decoration: BoxDecoration(
        color: context.colors.surfaceVariant,
        borderRadius: BorderRadius.circular(6),
        border:
            Border.all(color: context.colors.outline.withValues(alpha: 0.5)),
      ),
      alignment: Alignment.center,
      child: method.iconAsset != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: SvgPicture.asset(
                method.iconAsset!,
                width: 50,
                height: 30,
                fit: BoxFit.contain,
                placeholderBuilder: (BuildContext context) => Container(
                  width: 50,
                  height: 30,
                  color: context.colors.surfaceVariant,
                ),
              ),
            )
          : Icon(
              method.fallbackIcon ?? Icons.credit_card,
              color: context.colors.textMedium,
              size: 20,
            ),
    );
  }

  Widget _buildRadio(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? context.colors.primary : context.colors.outline,
          width: isSelected ? 6 : 2,
        ),
      ),
    );
  }
}
