import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/product_provider.dart';

class ProductsScreen extends ConsumerWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Products')),
      body: productsAsync.when(
        data: (products) => products.isEmpty
            ? const Center(child: Text('No products found'))
            : ListView.builder(
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final p = products[index];
                  return ListTile(
                    title: Text(p.name['en'] ?? p.name.values.first),
                    subtitle: Text('Price: ${p.basePrice} | Stock: ${p.stock}'),
                    trailing: Text(p.status),
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(e.toString()),
              ElevatedButton(
                onPressed: () => ref.refresh(productsProvider),
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add product screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
