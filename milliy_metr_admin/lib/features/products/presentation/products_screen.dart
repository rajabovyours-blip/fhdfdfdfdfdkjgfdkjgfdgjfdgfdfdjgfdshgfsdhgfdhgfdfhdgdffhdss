import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
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

  void _showProductDialog(BuildContext context, {Map<String, dynamic>? product}) {
    final isEditing = product != null;
    
    final nameUzController = TextEditingController(text: isEditing ? (product['name'] is Map ? product['name']['uz'] : product['name']) : '');
    final nameRuController = TextEditingController(text: isEditing ? (product['name'] is Map ? product['name']['ru'] : '') : '');
    final nameEnController = TextEditingController(text: isEditing ? (product['name'] is Map ? product['name']['en'] : '') : '');
    final descController = TextEditingController(text: isEditing ? (product['description'] is Map ? product['description']['uz'] : product['description']) : '');
    final priceController = TextEditingController(text: isEditing ? product['price'].toString() : '');
    
    String imageUrl = '';
    if (isEditing) {
      if (product['images'] != null && (product['images'] as List).isNotEmpty) {
        imageUrl = product['images'][0].toString();
      } else {
        imageUrl = product['image_url']?.toString() ?? '';
      }
    }
    final imageUrlController = TextEditingController(text: imageUrl);
    
    String selectedUnit = isEditing ? (product['unit'] ?? 'dona') : 'dona';
    String? selectedCategoryId = isEditing ? product['category_id']?.toString() : null;
    bool inStock = isEditing ? ((product['stock'] ?? 0) > 0) : true;
    bool isLoading = false;

    final categories = ref.read(categoriesProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobileDialog = screenWidth < 600;

    Widget buildFormBody(StateSetter setDialogState, BuildContext dialogContext) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
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
                  const Text('Rasm', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final result = await FilePicker.pickFiles(type: FileType.image, withData: true);
                      if (result != null && result.files.single.bytes != null) {
                        setDialogState(() => isLoading = true);
                        try {
                          final dio = ref.read(dioProvider);
                          final formData = FormData.fromMap({
                            'file': MultipartFile.fromBytes(
                              result.files.single.bytes!,
                              filename: result.files.single.name,
                            ),
                          });
                          final response = await dio.post('/upload/image', data: formData);
                          if (response.data['data'] != null && response.data['data']['url'] != null) {
                            setDialogState(() {
                              imageUrlController.text = response.data['data']['url'];
                            });
                          }
                        } catch (e) {
                          if (dialogContext.mounted) {
                            ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
                          }
                        } finally {
                          setDialogState(() => isLoading = false);
                        }
                      }
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        image: imageUrlController.text.isNotEmpty
                            ? DecorationImage(image: NetworkImage(imageUrlController.text), fit: BoxFit.cover)
                            : null,
                      ),
                      child: imageUrlController.text.isEmpty
                          ? const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_a_photo, size: 32, color: Colors.grey),
                                SizedBox(height: 8),
                                Text("Rasm yuklash", style: TextStyle(color: Colors.grey)),
                              ],
                            )
                          : Stack(
                              children: [
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                                    onPressed: () {
                                      setDialogState(() {
                                        imageUrlController.text = '';
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
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
          
          // 3. Pinned Bottom Action Bar (Always Visible)
          Container(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 12,
              bottom: MediaQuery.of(dialogContext).viewInsets.bottom > 0 ? 12 : 24,
            ),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: const Border(top: BorderSide(color: Colors.white12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text("Bekor qilish"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (nameUzController.text.isEmpty || priceController.text.isEmpty) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
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
                              final payload = {
                                'name': {
                                  'uz': nameUzController.text,
                                  'ru': nameRuController.text.isNotEmpty ? nameRuController.text : nameUzController.text,
                                  'en': nameEnController.text.isNotEmpty ? nameEnController.text : nameUzController.text,
                                },
                                'description': {
                                  'uz': descController.text.isNotEmpty ? descController.text : '',
                                  'ru': descController.text.isNotEmpty ? descController.text : '',
                                  'en': descController.text.isNotEmpty ? descController.text : '',
                                },
                                'category_id': selectedCategoryId ?? categories.first['id'],
                                'price': double.tryParse(priceController.text) ?? 0,
                                'unit': selectedUnit,
                                'stock': inStock ? 100 : 0,
                                'images': imageUrlController.text.isNotEmpty ? [imageUrlController.text] : [],
                                'image_url': imageUrlController.text.isNotEmpty ? imageUrlController.text : '',
                              };

                              if (isEditing) {
                                await dio.put('/products/${product['id']}', data: payload);
                              } else {
                                await dio.post('/products/', data: payload);
                              }

                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                                ref.invalidate(productsProvider);
                                ScaffoldMessenger.of(dialogContext).showSnackBar(
                                  SnackBar(
                                    content: Text(isEditing ? "Mahsulot yangilandi!" : "Mahsulot qo'shildi!"),
                                    backgroundColor: const Color(0xFF10B981),
                                  ),
                                );
                              }
                            } catch (e) {
                              setDialogState(() => isLoading = false);
                              if (dialogContext.mounted) {
                                ScaffoldMessenger.of(dialogContext).showSnackBar(
                                  SnackBar(
                                    content: Text('Xatolik: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('Saqlash'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (isMobileDialog) {
      // Mobile: full-screen scrollable bottom sheet
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (sheetContext) => StatefulBuilder(
          builder: (sheetContext, setSheetState) => DraggableScrollableSheet(
            initialChildSize: 0.95,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            expand: false,
            builder: (_, scrollController) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  // Drag handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(isEditing ? Icons.edit : Icons.add_box_rounded, color: const Color(0xFFFF7A00)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isEditing ? "Mahsulotni tahrirlash" : "Yangi mahsulot qo'shish",
                          style: Theme.of(sheetContext).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: buildFormBody(setSheetState, sheetContext)),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // Desktop: AlertDialog
      showDialog(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setDialogState) => AlertDialog(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(isEditing ? Icons.edit : Icons.add_box_rounded, color: const Color(0xFFFF7A00)),
                ),
                const SizedBox(width: 12),
                Text(isEditing ? "Mahsulotni tahrirlash" : "Yangi mahsulot qo'shish"),
              ],
            ),
            content: SizedBox(
              width: 600,
              child: buildFormBody(setDialogState, dialogContext),
            ),
            actions: const [], // Actions are inside the form body
          ),
        ),
      );
    }
  }
  
  void _deleteProduct(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Mahsulotni o'chirish"),
        content: const Text("Rostdan ham ushbu mahsulotni o'chirmoqchimisiz?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Yo'q")),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Ha, o'chirish")),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        final dio = ref.read(dioProvider);
        await dio.delete('/products/$id');
        ref.invalidate(productsProvider);
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Mahsulot o'chirildi"), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Xatolik: $e"), backgroundColor: Colors.red));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productsAsyncValue = ref.watch(productsProvider);
    final categories = ref.watch(categoriesProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
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
                          onPressed: () => _showProductDialog(context),
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
                          onPressed: () => _showProductDialog(context),
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
                                  onPressed: () => _showProductDialog(context, product: product),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteProduct(context, product['id']),
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
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = null;
                });
              },
              icon: const Icon(Icons.clear),
              label: const Text('Filtrlarni tozalash'),
            ),
          )
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
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () {
            setState(() {
              _searchQuery = '';
              _selectedCategory = null;
            });
          },
          icon: const Icon(Icons.clear),
          label: const Text('Tozalash'),
        ),
      ],
    );
  }
}
