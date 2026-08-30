import 'package:flutter/material.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class DeliveryTrackingScreen extends StatelessWidget {
  final String orderId;

  const DeliveryTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Delivery Tracking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order: $orderId',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(context.l10n.statusOnTheWay),
                    Text(context.l10n.driverJamshid),
                    Text(context.l10n.estimatedArrival),
                    Text(context.l10n.liveTrackingReady),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
