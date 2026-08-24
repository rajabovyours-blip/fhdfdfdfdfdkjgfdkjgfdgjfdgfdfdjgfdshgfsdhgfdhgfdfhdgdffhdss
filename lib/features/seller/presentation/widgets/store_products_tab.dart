import 'package:flutter/material.dart';

class StoreProductsTab extends StatelessWidget {
  final String storeId;

  const StoreProductsTab({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Store products will be listed here.'),
    );
  }
}
