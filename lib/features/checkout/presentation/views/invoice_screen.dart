import 'package:flutter/material.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class InvoiceScreen extends StatelessWidget {
  final String orderId;

  const InvoiceScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.invoice)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Milliy Metr',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
                const SizedBox(height: 8),
                Text('Invoice for $orderId'),
                const SizedBox(height: 8),
                Text('${context.l10n.subtotal}: 520,000 UZS'),
                Text('${context.l10n.shipping}: 50,000 UZS'),
                Text('${context.l10n.total}: 570,000 UZS'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
