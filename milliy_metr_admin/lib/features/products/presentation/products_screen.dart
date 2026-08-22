import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/providers/admin_providers.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsyncValue = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('products'.tr()),
        actions: [
          ElevatedButton.icon(
            onPressed: () => context.go('/products/import'),
            icon: const Icon(Icons.upload_file),
            label: const Text('Import Excel'), // Can add localization later
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: productsAsyncValue.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(child: Text('no_data'.tr()));
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: product['image_url'] != null
                    ? Image.network(product['image_url'], width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image))
                    : const Icon(Icons.inventory),
                title: Text(product['name'] ?? 'Unknown Product'),
                subtitle: Text('${product['price']} UZS'),
                trailing: Text('${product['stock_quantity'] ?? 0} in stock'),
              );
            },
          );
        },
        loading: () => Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('loading'.tr()),
          ],
        )),
        error: (error, stack) => Center(child: Text('${'error'.tr()}: $error')),
      ),
    );
  }
}
