import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/shared/widgets/app_button.dart';

class ReturnRequestScreen extends StatelessWidget {
  const ReturnRequestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          l10n.requestRefund,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: context.colors.background,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.refundReason,
              style: TextStyle(
                color: context.colors.textHigh,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                filled: true,
                fillColor: context.colors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.outline),
                ),
              ),
              hint: Text(l10n.selectReason),
              items: [
                DropdownMenuItem(
                  value: 'damaged',
                  child: Text(context.l10n.damagedItem),
                ),
                DropdownMenuItem(
                  value: 'wrong',
                  child: Text(context.l10n.wrongItem),
                ),
                DropdownMenuItem(
                  value: 'late',
                  child: Text(context.l10n.lateDelivery),
                ),
              ],
              onChanged: (_) {},
            ),
            const SizedBox(height: 16),
            Text(
              'Notes',
              style: TextStyle(
                color: context.colors.textHigh,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              style: TextStyle(color: context.colors.textHigh),
              decoration: InputDecoration(
                labelText: l10n.refundDescription,
                labelStyle: TextStyle(color: context.colors.textMedium),
                filled: true,
                fillColor: context.colors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.colors.outline),
                ),
              ),
            ),
            const Spacer(),
            AppButton(
              text: l10n.submitRequest,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.refundSubmitted),
                    backgroundColor: context.colors.success,
                  ),
                );
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
