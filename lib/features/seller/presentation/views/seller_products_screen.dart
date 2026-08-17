import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';

class SellerProductsScreen extends ConsumerWidget {
  const SellerProductsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We would use a specific provider for seller's own products here
    // For now, BACKEND CONTRACT REQUIRED: /seller/products
    const productsAsync = AsyncValue<List<dynamic>>.data([]);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.myProducts),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(AppRoutes.sellerAddProduct),
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Text(context.l10n.noProductsAddedYet),
            );
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: product.images.isNotEmpty
                    ? Image.network(
                        product.images.first,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 50,
                        height: 50,
                        color: context.colors.surfaceVariant,
                        child: const Icon(Icons.image),
                      ),
                title: Text(
                  product.name
                      .get(Localizations.localeOf(context).languageCode),
                ),
                subtitle: Text(
                  '${product.price} ${product.currency} • Stock: ${product.stock}',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') {
                      context.push(
                        AppRoutes.sellerEditProduct
                            .replaceAll(':id', product.id),
                      );
                    } else if (value == 'delete') {
                      // Handle delete
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(context.l10n.editBtn),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Archive/Delete',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.sellerAddProduct),
        backgroundColor: context.colors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
}
