import 'package:flutter/material.dart';

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
                    const Text('Status: On the way'),
                    const Text('Driver: Jamshid K.'),
                    const Text('Estimated arrival: 18:30'),
                    const Text('Live tracking ready for map integration.'),
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
