import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:milliy_metr_admin/shared/utils/responsive_modal.dart';
import 'package:milliy_metr_admin/shared/widgets/admin_page_header.dart';
import 'package:milliy_metr_admin/core/utils/image_utils.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/api/api_client.dart';
import 'package:easy_localization/easy_localization.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Helper to build a hierarchical tree from a flat list for Dropdown indentation
  List<Map<String, dynamic>> _buildCategoryTree(List<dynamic> flatCategories) {
    final Map<String, List<Map<String, dynamic>>> childrenMap = {};
    final List<Map<String, dynamic>> topLevel = [];

    for (var cat in flatCategories) {
      final String? parentId = cat['parent_id']?.toString();
      final category = Map<String, dynamic>.from(cat);
      if (parentId == null || parentId.isEmpty || parentId == 'null') {
        topLevel.add(category);
      } else {
        childrenMap.putIfAbsent(parentId, () => []).add(category);
      }
    }

    final List<Map<String, dynamic>> result = [];
    void traverse(List<Map<String, dynamic>> cats, int depth) {
      for (var cat in cats) {
        final catId = cat['id'].toString();
        cat['depth'] = depth;
        result.add(cat);
        if (childrenMap.containsKey(catId)) {
          traverse(childrenMap[catId]!, depth + 1);
        }
      }
    }

    traverse(topLevel, 0);
    return result;
  }

  List<DropdownMenuItem<String>> _buildCategoryDropdownItems(List<Map<String, dynamic>> tree) {
    return tree.map((c) {
      final int depth = c['depth'] ?? 0;
      final name = c['name'] is Map ? c['name']['uz'] : c['name'];
      final prefix = depth > 0 ? '${'  ' * depth}↳ ' : '';
      return DropdownMenuItem(
        value: c['id'].toString(),
        child: Text('$prefix${name ?? ''}'),
      );
    }).toList();
  }

  void _showProductDialog(BuildContext context, {Map<String, dynamic>? product}) {
    final isEditing = product != null;
    
    final nameUzController = TextEditingController(text: isEditing ? (product['name'] is Map ? product['name']['uz'] : product['name']) : '');
    final nameRuController = TextEditingController(text: isEditing ? (product['name'] is Map ? (product['name']['ru'] ?? '') : '') : '');
    final nameEnController = TextEditingController(text: isEditing ? (product['name'] is Map ? (product['name']['en'] ?? '') : '') : '');
    final descController = TextEditingController(text: isEditing ? (product['description'] is Map ? product['description']['uz'] : product['description']) : '');
    final priceController = TextEditingController(text: isEditing ? product['price'].toString() : '');
    final brandController = TextEditingController(text: isEditing ? (product['brand'] ?? '') : '');
    final deliveryPriceController = TextEditingController(text: isEditing ? (product['delivery_price']?.toString() ?? '0') : '0');
    
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
    bool hasDelivery = isEditing ? (product['has_delivery'] ?? true) : true;
    
    Uint8List? localImageBytes;
    bool isLoading = false;

    final flatCategories = ref.read(categoriesProvider).value ?? [];
    final categoriesTree = _buildCategoryTree(flatCategories);

    showAdminFormModal(
      context: context,
      title: isEditing ? 'edit_product'.tr() : 'add_product'.tr(),
      icon: isEditing ? Icons.edit : Icons.add_box_rounded,
      builder: (modalContext, setModalState) {
        // Return only the form fields. The actions are handled in actionsBuilder.
        return Column(
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('category'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: selectedCategoryId,
                      hint: Text('select_category'.tr()),
                      isExpanded: true,
                      items: _buildCategoryDropdownItems(categoriesTree),
                      onChanged: (val) {
                        setModalState(() {
                          selectedCategoryId = val;
                        });
                      },
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Category is required';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    
                    Text('name_uz'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameUzController,
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.abc)),
                    ),
                    const SizedBox(height: 16),
                    Text('name_ru'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameRuController,
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.abc)),
                    ),
                    const SizedBox(height: 16),
                    Text('name_en'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameEnController,
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.abc)),
                    ),
                    const SizedBox(height: 20),
                    
                    Text('description'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Tavsifni kiriting...',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('price_uzs'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              const SizedBox(height: 8),
                              TextField(
                                controller: priceController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  suffixText: "UZS",
                                  prefixIcon: Icon(Icons.payments),
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
                              Text('unit'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
                                  DropdownMenuItem(value: 'pcs', child: Text('Pcs')),
                                ],
                                onChanged: (val) {
                                  setModalState(() {
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
                    
                    Text('image'.tr(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: localImageBytes != null
                              ? Image.memory(localImageBytes!, fit: BoxFit.cover)
                              : imageUrlController.text.isNotEmpty
                                  ? Image.network(
                                      ImageUtils.getFullImageUrl(imageUrlController.text),
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        debugPrint("Image load error: $error");
                                        return const Icon(Icons.broken_image, size: 32, color: Colors.grey);
                                      },
                                    )
                                  : const Icon(Icons.image, size: 32, color: Colors.grey),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: isLoading
                                ? null
                                : () async {
                                    final result = await FilePicker.pickFiles(type: FileType.image, withData: true);
                                    if (result != null && result.files.single.bytes != null) {
                                      setModalState(() {
                                        localImageBytes = result.files.single.bytes;
                                        isLoading = true;
                                      });
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
                                          setModalState(() {
                                            imageUrlController.text = response.data['data']['url'];
                                          });
                                        }
                                      } catch (e) {
                                        if (modalContext.mounted) {
                                          ScaffoldMessenger.of(modalContext).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
                                        }
                                      } finally {
                                        setModalState(() => isLoading = false);
                                      }
                                    }
                                  },
                            icon: isLoading
                                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                                : const Icon(Icons.upload_file),
                            label: Text('upload_image'.tr()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    
                    SwitchListTile(
                      title: Text('in_stock'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('stock_available'.tr(), style: const TextStyle(fontSize: 12)),
                      value: inStock,
                      onChanged: (val) {
                        setModalState(() {
                          inStock = val;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 16),
                    const Text('Brend nomi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: brandController,
                      decoration: const InputDecoration(prefixIcon: Icon(Icons.branding_watermark)),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Yetkazib berish mavjud', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      value: hasDelivery,
                      onChanged: (val) {
                        setModalState(() {
                          hasDelivery = val;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (hasDelivery) ...[
                      const SizedBox(height: 16),
                      const Text('Yetkazib berish narxi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: deliveryPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.local_shipping)),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        );
      },
      actionsBuilder: (modalContext, setModalState) {
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(modalContext),
                child: Text('cancel'.tr()),
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
                          ScaffoldMessenger.of(modalContext).showSnackBar(
                            SnackBar(
                              content: Text("enter_name_and_price".tr()),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }
                        if (selectedCategoryId == null) {
                          ScaffoldMessenger.of(modalContext).showSnackBar(
                            const SnackBar(
                              content: Text("Category is required"),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        setModalState(() => isLoading = true);

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
                            'category_id': selectedCategoryId,
                            'price': double.tryParse(priceController.text) ?? 0.0,
                            'unit': selectedUnit,
                            'stock': inStock ? 100 : 0,
                            'images': imageUrlController.text.isNotEmpty ? [imageUrlController.text] : [],
                            'image_url': imageUrlController.text.isNotEmpty ? imageUrlController.text : '',
                            'brand': brandController.text.isNotEmpty ? brandController.text : null,
                            'has_delivery': hasDelivery,
                            'delivery_price': hasDelivery ? (double.tryParse(deliveryPriceController.text) ?? 0.0) : 0.0,
                          };

                          if (isEditing) {
                            await dio.put('/products/${product['id']}', data: payload);
                          } else {
                            await dio.post('/products', data: payload);
                          }

                          if (modalContext.mounted) {
                            Navigator.pop(modalContext);
                            ref.invalidate(productsProvider);
                            ScaffoldMessenger.of(modalContext).showSnackBar(
                              SnackBar(
                                content: Text(isEditing ? "Mahsulot yangilandi!" : "Mahsulot qo'shildi!"),
                                backgroundColor: const Color(0xFF10B981),
                              ),
                            );
                          }
                        } catch (e) {
                          setModalState(() => isLoading = false);
                          if (modalContext.mounted) {
                            String errorMessage = 'Xatolik: $e';
                            if (e is DioException && e.response != null) {
                              final data = e.response!.data;
                              if (data is Map && data.containsKey('detail')) {
                                final detail = data['detail'];
                                if (detail is List) {
                                  errorMessage = detail.map((err) => '${err['loc']}: ${err['msg']}').join('\n');
                                } else {
                                  errorMessage = detail.toString();
                                }
                              } else {
                                errorMessage = e.response!.data.toString();
                              }
                            }
                            ScaffoldMessenger.of(modalContext).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 6),
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
                    : Text('save'.tr()),
              ),
            ),
          ],
        );
      },
    );
  }
  
  void _deleteProduct(BuildContext context, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete_product'.tr()),
        content: Text('delete_product_confirm'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('no'.tr())),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text('yes_delete'.tr())),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        final dio = ref.read(dioProvider);
        await dio.delete('/products/$id');
        ref.invalidate(productsProvider);
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('product_deleted'.tr()), backgroundColor: Colors.green),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("${'error_prefix'.tr()}: $e"), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildProductThumbnail(String? imageUrl) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(
              ImageUtils.getFullImageUrl(imageUrl),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint("Thumbnail load error: $error");
                return const Icon(Icons.inventory_2, size: 24, color: Colors.grey);
              },
            )
          : const Icon(Icons.inventory_2, size: 24, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsyncValue = ref.watch(productsProvider);
    final flatCategories = ref.watch(categoriesProvider).value ?? [];
    final categoriesTree = _buildCategoryTree(flatCategories);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 640;

    String resolveCategoryName(String? categoryId) {
      if (categoryId == null) return 'other'.tr();
      final cat = flatCategories.firstWhere((c) => c['id']?.toString() == categoryId, orElse: () => <String, dynamic>{});
      if (cat.isEmpty) return 'other'.tr();
      final name = cat['name'];
      if (name is Map) return (name['uz'] ?? name['ru'] ?? name['en'] ?? 'other'.tr()).toString();
      return name?.toString() ?? 'other'.tr();
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => _showProductDialog(context),
              child: const Icon(Icons.add),
            )
          : null,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ──────────────────────────────────────────────────
            AdminPageHeader(
              title: 'products_catalog'.tr(),
              addLabel: 'add_product'.tr(),
              onAdd: () => _showProductDialog(context),
              extraActions: [
                ElevatedButton.icon(
                  onPressed: () => context.go('/products/import'),
                  icon: const Icon(Icons.upload_file),
                  label: Text('excel_import'.tr()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.surface,
                    foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                    side: BorderSide(color: Theme.of(context).colorScheme.outline),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // ─── Filters ─────────────────────────────────────────────────
            _buildFilters(categoriesTree, isMobile),
            const SizedBox(height: 24),
            // ─── Products List / Table ───────────────────────────────────
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
                          Text('products_not_found'.tr(), style: Theme.of(context).textTheme.titleLarge),
                        ],
                      ),
                    ),
                  );
                }

                if (isMobile) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      final nameRaw = product['name'];
                      String displayName;
                      if (nameRaw is Map) {
                        displayName = nameRaw['uz'] ?? nameRaw['en'] ?? 'unknown'.tr();
                      } else {
                        displayName = (nameRaw ?? 'unknown'.tr()).toString();
                      }

                      final images = product['images'];
                      String? imageUrl;
                      if (images is List && images.isNotEmpty) {
                        imageUrl = images.first.toString();
                      } else {
                        imageUrl = product['image_url']?.toString();
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 1,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: _buildProductThumbnail(imageUrl),
                          title: Text(displayName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Category: ${resolveCategoryName(product['category_id']?.toString())}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              const SizedBox(height: 2),
                              Text('${product['price'] ?? 0} UZS / ${product['unit'] ?? 'dona'}', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _showProductDialog(context, product: product),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteProduct(context, product['id'].toString()),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
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
                      headingRowColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceContainerHighest),
                      headingTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      columns: [
                        DataColumn(label: Text('image'.tr())),
                        DataColumn(label: Text('name'.tr())),
                        DataColumn(label: Text('category'.tr())),
                        DataColumn(label: Text('price_uzs'.tr())),
                        DataColumn(label: Text('unit'.tr())),
                        DataColumn(label: Text('actions'.tr())),
                      ],
                      rows: filteredProducts.map((product) {
                        final nameRaw = product['name'];
                        String displayName;
                        if (nameRaw is Map) {
                          displayName = nameRaw['uz'] ?? nameRaw['en'] ?? 'unknown'.tr();
                        } else {
                          displayName = (nameRaw ?? 'unknown'.tr()).toString();
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
                            DataCell(_buildProductThumbnail(imageUrl)),
                            DataCell(
                              SizedBox(
                                width: 200,
                                child: Text(
                                  displayName,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            DataCell(Text(resolveCategoryName(product['category_id']?.toString()))),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${product['price'] ?? 0} UZS',
                                  style: const TextStyle(
                                    color: Color(0xFF10B981),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text((product['unit'] ?? 'dona').toString())),
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
                                    onPressed: () => _deleteProduct(context, product['id'].toString()),
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
                      Text('${'error_prefix'.tr()}: $error'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(productsProvider),
                        child: Text('retry'.tr()),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
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
              border: OutlineInputBorder(),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              hintText: 'all_categories'.tr(),
              border: const OutlineInputBorder(),
            ),
            value: _selectedCategory,
            isExpanded: true,
            items: [
              DropdownMenuItem(value: '', child: Text('all_categories'.tr())),
              ...categories.map((c) {
                final int depth = c['depth'] ?? 0;
                final name = c['name'] is Map ? c['name']['uz'] : c['name'];
                final prefix = depth > 0 ? '${'  ' * depth}↳ ' : '';
                return DropdownMenuItem(
                  value: c['id'].toString(),
                  child: Text('$prefix${name ?? ''}'),
                );
              }),
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
              label: Text('clear_filters'.tr()),
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
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: 'Mahsulot nomini qidiring...',
              prefixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _searchFocusNode.requestFocus(),
              ),
              border: const OutlineInputBorder(),
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
              border: OutlineInputBorder(),
            ),
            value: _selectedCategory,
            items: [
              const DropdownMenuItem(value: '', child: Text('Barcha kategoriyalar')),
              ...categories.map((c) {
                final int depth = c['depth'] ?? 0;
                final name = c['name'] is Map ? c['name']['uz'] : c['name'];
                final prefix = depth > 0 ? '${'  ' * depth}↳ ' : '';
                return DropdownMenuItem(
                  value: c['id'].toString(),
                  child: Text('$prefix${name ?? ''}'),
                );
              }),
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
