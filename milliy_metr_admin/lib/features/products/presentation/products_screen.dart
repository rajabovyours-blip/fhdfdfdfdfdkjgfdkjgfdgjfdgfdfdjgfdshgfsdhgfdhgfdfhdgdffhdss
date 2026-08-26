import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/admin_providers.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  void _showProductDialog(BuildContext context, {Map<String, dynamic>? product}) {
    // Basic dialog for demonstration, should be expanded for real usage
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(product == null ? "Yangi mahsulot qo'shish" : "Mahsulotni tahrirlash"),
        content: const SizedBox(
          width: 500,
          child: Text("Bu yerda mahsulot qo'shish formasi bo'ladi (UZ, RU, EN tillarda nomi, tavsif, narx, o'lchov birligi, rasmlar)."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Yopish")),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsyncValue = ref.watch(productsProvider);
    final categories = ref.watch(categoriesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Mahsulotlar Katalogi",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.go('/products/import'),
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Excel Import"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                      side: BorderSide(color: Theme.of(context).colorScheme.outline),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showProductDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text("Mahsulot qo'shish"),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildFilters(categories),
          const SizedBox(height: 24),
          productsAsyncValue.when(
            data: (products) {
              var filteredProducts = products.where((p) {
                final name = (p['name'] ?? '').toString().toLowerCase();
                final matchesSearch = name.contains(_searchQuery.toLowerCase());
                final matchesCategory = _selectedCategory == null || _selectedCategory == '' || p['category_id'] == _selectedCategory;
                return matchesSearch && matchesCategory;
              }).toList();

              if (filteredProducts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Text("Mahsulotlar topilmadi", style: Theme.of(context).textTheme.titleLarge),
                  ),
                );
              }

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Theme.of(context).colorScheme.outline),
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text("Rasm")),
                      DataColumn(label: Text("Nomi")),
                      DataColumn(label: Text("Kategoriya")),
                      DataColumn(label: Text("Narxi (UZS)")),
                      DataColumn(label: Text("Status")),
                      DataColumn(label: Text("Amallar")),
                    ],
                    rows: filteredProducts.map((product) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              ),
                              child: product['image_url'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(product['image_url'], fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
                                    )
                                  : const Icon(Icons.inventory_2),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 200,
                              child: Text(
                                product['name'] ?? 'Noma\'lum',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text(product['category_name'] ?? 'Boshqa')),
                          DataCell(Text("${product['price'] ?? 0} UZS")),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text("Faol", style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showProductDialog(context, product: product),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {},
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Xatolik: $error')),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(List<Map<String, dynamic>> categories) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            decoration: const InputDecoration(
              hintText: "Mahsulot nomini qidiring...",
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              hintText: "Barcha kategoriyalar",
            ),
            value: _selectedCategory,
            items: [
              const DropdownMenuItem(value: '', child: Text("Barcha kategoriyalar")),
              ...categories.map((c) => DropdownMenuItem(value: c['id'].toString(), child: Text(c['name'] ?? ''))),
            ],
            onChanged: (val) {
              setState(() {
                _selectedCategory = val;
              });
            },
          ),
        ),
      ],
    );
  }
}

