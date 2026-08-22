import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Catalog'),
        actions: [
          ElevatedButton.icon(
            onPressed: () => context.go('/products/import'),
            icon: const Icon(Icons.upload_file),
            label: const Text('Import Excel'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: const Center(child: Text('Products List Placeholder (Admin Only)')),
    );
  }
}
