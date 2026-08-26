import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/api/api_client.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _searchQuery = '';
  String? _selectedCategory;

  void _showAddProductDialog(BuildContext context) {
    final nameUzController = TextEditingController();
    final nameRuController = TextEditingController();
    final nameEnController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController();
    final imageUrlController = TextEditingController();
    String selectedUnit = 'dona';
    String? selectedCategoryId;
    bool inStock = true;
    bool isLoading = false;

    final categories = ref.read(categoriesProvider);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_box_rounded, color: Color(0xFFFF7A00)),
              ),
              const SizedBox(width: 12),
              const Text("Yangi mahsulot qo'shish"),
            ],
          ),
          content: SizedBox(
            width: 600,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mahsulot nomi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: nameUzController,
                    decoration: const InputDecoration(
                      labelText: "Nomi (O'zbekcha)",
                      prefixIcon: Icon(Icons.language),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameRuController,
                    decoration: const InputDecoration(
                      labelText: 'Nomi (Ruscha)',
                      prefixIcon: Icon(Icons.language),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameEnController,
                    decoration: const InputDecoration(
                      labelText: 'Nomi (Inglizcha)',
                      prefixIcon: Icon(Icons.language),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Kategoriya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      hintText: 'Kategoriya tanlang',
                      prefixIcon: Icon(Icons.category),
                    ),
                    value: selectedCategoryId,
                    items: categories.map((c) {
                      return DropdownMenuItem(
                        value: c['id'].toString(),
                        child: Text(c['name'] ?? ''),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        selectedCategoryId = val;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Narxi (UZS)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 8),
                            TextField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                hintText: '45000',
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("O'lchov birligi", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: selectedUnit,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.straighten),
                              ),
                              items: const [
                                DropdownMenuItem(value: 'dona', child: Text('Dona')),
                                DropdownMenuItem(value: 'qop', child: Text('Qop')),
                                DropdownMenuItem(value: 'kg', child: Text('Kg')),
                                DropdownMenuItem(value: 'metr', child: Text('Metr')),
                                DropdownMenuItem(value: 'm2', child: Text('m²')),
                                DropdownMenuItem(value: 'litr', child: Text('Litr')),
                              ],
                              onChanged: (val) {
                                setDialogState(() {
                                  selectedUnit = val ?? 'dona';
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Rasm URL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: imageUrlController,
                    decoration: const InputDecoration(
                      hintText: 'https://... yoki assets/images/...',
                      prefixIcon: Icon(Icons.image),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Tavsif', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Mahsulot haqida...',
                      prefixIcon: Icon(Icons.description),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Omborda mavjud'),
                    subtitle: Text(inStock ? 'Sotuvda' : 'Tugagan'),
                    value: inStock,
                    activeColor: const Color(0xFFFF7A00),
                    onChanged: (val) {
                      setDialogState(() {
                        inStock = val;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Bekor qilish'),
            ),
            ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (nameUzController.text.isEmpty || priceController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Nomi va narxini kiriting"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }
                      setDialogState(() => isLoading = true);

                      try {
                        final dio = ref.read(dioProvider);
                        await dio.post('/products/', data: {
                          'name': {
                            'uz': nameUzController.text,
                            'ru': nameRuController.text.isNotEmpty ? nameRuController.text : nameUzController.text,
                            'en': nameEnController.text.isNotEmpty ? nameEnController.text : nameUzController.text,
                          },
                          'description': {
                            'uz': descController.text,
                            'ru': descController.text,
                            'en': descController.text,
                          },
                          'category_id': selectedCategoryId ?? categories.first['id'],
                          'price': double.tryParse(priceController.text) ?? 0,
                          'unit': selectedUnit,
                          'stock': inStock ? 100 : 0,
                          'images': imageUrlController.text.isNotEmpty ? [imageUrlController.text] : [],
                        });

                        if (context.mounted) {
                          Navigator.pop(context);
                          ref.invalidate(productsProvider);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Mahsulot muvaffaqiyatli qo'shildi!"),
                              backgroundColor: Color(0xFF10B981),
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Xatolik: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
              icon: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save),
              label: Text(isLoading ? 'Saqlanmoqda...' : 'Saqlash'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsyncValue = ref.watch(productsProvider);
    final categories = ref.watch(categoriesProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header ──────────────────────────────────────────────────
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mahsulotlar Katalogi',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => context.go('/products/import'),
                          icon: const Icon(Icons.upload_file, size: 18),
                          label: const Text('Excel Import'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                            side: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => _showAddProductDialog(context),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text("Mahsulot qo'shish"),
                        ),
                      ],
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mahsulotlar Katalogi',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () => context.go('/products/import'),
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Excel Import'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.surface,
                            foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                            side: BorderSide(color: Theme.of(context).colorScheme.outline),
                          ),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () => _showAddProductDialog(context),
                          icon: const Icon(Icons.add),
                          label: const Text("Mahsulot qo'shish"),
                        ),
                      ],
                    ),
                  ],
                ),
          const SizedBox(height: 24),
          // ─── Filters ─────────────────────────────────────────────────
          _buildFilters(categories, isMobile),
          const SizedBox(height: 24),
          // ─── Products Table ──────────────────────────────────────────
          productsAsyncValue.when(
            data: (products) {
              var filteredProducts = products.where((p) {
                final nameRaw = p['name'];
                String name;
                if (nameRaw is Map) {
                  name = (nameRaw['uz'] ?? nameRaw['en'] ?? '').toString().toLowerCase();
                } else {
                  name = (nameRaw ?? '').toString().toLowerCase();
                }
                final matchesSearch = name.contains(_searchQuery.toLowerCase());
                final matchesCategory = _selectedCategory == null ||
                    _selectedCategory == '' ||
                    p['category_id']?.toString() == _selectedCategory;
                return matchesSearch && matchesCategory;
              }).toList();

              if (filteredProducts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text('Mahsulotlar topilmadi', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
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
                      DataColumn(label: Text('Rasm')),
                      DataColumn(label: Text('Nomi')),
                      DataColumn(label: Text('Kategoriya')),
                      DataColumn(label: Text('Narxi (UZS)')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Amallar')),
                    ],
                    rows: filteredProducts.map((product) {
                      final nameRaw = product['name'];
                      String displayName;
                      if (nameRaw is Map) {
                        displayName = nameRaw['uz'] ?? nameRaw['en'] ?? 'Noma\'lum';
                      } else {
                        displayName = (nameRaw ?? 'Noma\'lum').toString();
                      }

                      final images = product['images'];
                      String? imageUrl;
                      if (images is List && images.isNotEmpty) {
                        imageUrl = images.first.toString();
                      } else {
                        imageUrl = product['image_url']?.toString();
                      }

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
                              child: imageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => const Icon(Icons.image),
                                      ),
                                    )
                                  : const Icon(Icons.inventory_2),
                            ),
                          ),
                          DataCell(
                            SizedBox(
                              width: 200,
                              child: Text(
                                displayName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          DataCell(Text(product['category_name']?.toString() ?? 'Boshqa')),
                          DataCell(Text('${product['price'] ?? 0} UZS')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Faol',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {},
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
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(48.0),
                child: CircularProgressIndicator(color: Color(0xFFFF7A00)),
              ),
            ),
            error: (error, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(48.0),
                child: Column(
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Xatolik: $error'),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(productsProvider),
                      child: const Text('Qayta urinish'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(List<Map<String, dynamic>> categories, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              hintText: 'Mahsulot nomini qidiring...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: const InputDecoration(
              hintText: 'Barcha kategoriyalar',
            ),
            value: _selectedCategory,
            isExpanded: true,
            items: [
              const DropdownMenuItem(value: '', child: Text('Barcha kategoriyalar')),
              ...categories.map((c) => DropdownMenuItem(
                    value: c['id'].toString(),
                    child: Text(c['name'] ?? ''),
                  )),
            ],
            onChanged: (val) {
              setState(() {
                _selectedCategory = val;
              });
            },
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'Mahsulot nomini qidiring...',
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
              hintText: 'Barcha kategoriyalar',
            ),
            value: _selectedCategory,
            items: [
              const DropdownMenuItem(value: '', child: Text('Barcha kategoriyalar')),
              ...categories.map((c) => DropdownMenuItem(
                    value: c['id'].toString(),
                    child: Text(c['name'] ?? ''),
                  )),
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
