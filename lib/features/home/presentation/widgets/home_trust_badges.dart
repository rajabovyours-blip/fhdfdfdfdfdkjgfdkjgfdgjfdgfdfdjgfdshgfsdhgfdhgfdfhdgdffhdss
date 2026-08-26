import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class HomeTrustBadges extends StatelessWidget {
  const HomeTrustBadges({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.colors.outline, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildBadge(context, Icons.verified_outlined, context.l10n.qualityGuaranteeBadge.replaceAll(" ", "\n", 1)),
          _buildDivider(context),
          _buildBadge(context, Icons.bolt_outlined, context.l10n.fastDeliveryBadge.replaceAll(" ", "\n", 1)),
          _buildDivider(context),
          _buildBadge(context, Icons.credit_card_outlined, context.l10n.securePaymentBadge.replaceAll(" ", "\n", 1)),
        ],
      ),
    );
  }

  Widget _buildBadge(BuildContext context, IconData icon, String label) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: context.colors.primary),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: context.colors.textMedium,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: context.colors.outline,
    );
  }
}
