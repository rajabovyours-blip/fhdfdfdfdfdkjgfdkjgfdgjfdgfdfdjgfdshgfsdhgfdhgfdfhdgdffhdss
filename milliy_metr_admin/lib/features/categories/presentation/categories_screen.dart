import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:milliy_metr_admin/shared/utils/responsive_modal.dart';
import 'package:milliy_metr_admin/shared/widgets/admin_page_header.dart';
import 'package:milliy_metr_admin/core/utils/image_utils.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/api/api_client.dart';
import 'package:easy_localization/easy_localization.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  // Helper to build a hierarchical tree from a flat list
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

  void _showCategoryDialog(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> allCategories, {Map<String, dynamic>? category}) {
    final isEditing = category != null;
    final nameUzController = TextEditingController(text: isEditing ? (category['name'] is Map ? category['name']['uz'] : category['name']) : '');
    final nameRuController = TextEditingController(text: isEditing ? (category['name'] is Map ? category['name']['ru'] : '') : '');
    final nameEnController = TextEditingController(text: isEditing ? (category['name'] is Map ? category['name']['en'] : '') : '');
    final imageController = TextEditingController(text: isEditing ? (category['image_url'] ?? '') : '');
    String? selectedParentId = isEditing ? category['parent_id']?.toString() : null;
    
    Uint8List? localImageBytes;
    bool isLoading = false;

    // Get top level categories for the dropdown
    final topLevelCategories = allCategories.where((c) => c['parent_id'] == null && (category == null || c['id'] != category['id'])).toList();

    Widget buildFormContent(BuildContext dialogContext, StateSetter setDialogState) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: nameUzController,
            decoration: InputDecoration(labelText: 'name_uz'.tr()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameRuController,
            decoration: InputDecoration(labelText: 'name_ru'.tr()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameEnController,
            decoration: InputDecoration(labelText: 'name_en'.tr()),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'parent_category'.tr(),
              border: const OutlineInputBorder(),
            ),
            initialValue: selectedParentId,
            items: [
              DropdownMenuItem<String>(
                value: null,
                child: Text('none'.tr()),
              ),
              ...topLevelCategories.map((c) {
                final name = c['name'] is Map ? c['name']['uz'] : c['name'];
                return DropdownMenuItem<String>(
                  value: c['id'].toString(),
                  child: Text(name ?? ''),
                );
              }),
            ],
            onChanged: (val) {
              setDialogState(() => selectedParentId = val);
            },
          ),
          const SizedBox(height: 16),
          
          // Image Preview & Upload
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
                    : imageController.text.isNotEmpty
                        ? Image.network(
                            ImageUtils.getFullImageUrl(imageController.text),
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
                            setDialogState(() {
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
                                setDialogState(() {
                                  // Save the relative URL to the controller
                                  imageController.text = response.data['data']['url'];
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
                  icon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.upload_file),
                  label: Text('upload_image'.tr()),
                ),
              ),
            ],
          ),
        ],
      );
    }

    Widget buildActionButtons(BuildContext dialogContext, StateSetter setDialogState) {
      return Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('cancel'.tr()),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      setDialogState(() => isLoading = true);
                      try {
                        final dio = ref.read(dioProvider);
                        final payload = {
                          'name': {
                            'uz': nameUzController.text,
                            'ru': nameRuController.text,
                            'en': nameEnController.text,
                          },
                          'image_url': imageController.text,
                          'parent_id': selectedParentId,
                        };

                        if (isEditing) {
                          await dio.put('/categories/${category['id']}', data: payload);
                        } else {
                          await dio.post('/categories', data: payload);
                        }
                        ref.invalidate(categoriesProvider);
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                        }
                      } catch (e) {
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
                        }
                      } finally {
                        if (dialogContext.mounted) {
                          setDialogState(() => isLoading = false);
                        }
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text('save'.tr()),
            ),
          ],
        ),
      );
    }

    showAdminFormModal(
      context: context,
      title: isEditing ? 'edit_category'.tr() : 'add_category'.tr(),
      icon: isEditing ? Icons.edit : Icons.add_box_rounded,
      builder: (dialogContext, setDialogState) {
        return buildFormContent(dialogContext, setDialogState);
      },
      actionsBuilder: (dialogContext, setDialogState) {
        return buildActionButtons(dialogContext, setDialogState);
      },
    );
  }

  Future<void> _deleteCategory(BuildContext context, WidgetRef ref, String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete'.tr()),
        content: Text('Ishonchingiz komilmi?'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('delete'.tr()),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final dio = ref.read(dioProvider);
        await dio.delete('/categories/$id');
        ref.invalidate(categoriesProvider);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
        }
      }
    }
  }

  Widget _buildCategoryThumbnail(String? rawUrl) {
    final imageUrl = ImageUtils.getFullImageUrl(rawUrl);
    final isAsset = imageUrl.startsWith('assets/');
    final isNetwork = imageUrl.isNotEmpty && !isAsset;

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade300),
      ),
      clipBehavior: Clip.antiAlias,
      child: isAsset
          ? Image.asset(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.category, size: 24, color: Colors.grey),
            )
          : isNetwork
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    debugPrint("Thumbnail load error: $error");
                    return const Icon(Icons.category, size: 24, color: Colors.grey);
                  },
                )
              : const Icon(Icons.category, size: 24, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 640;

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: isMobile 
          ? categoriesAsync.when(
              data: (flatCategories) => FloatingActionButton(
                onPressed: () => _showCategoryDialog(context, ref, _buildCategoryTree(flatCategories)),
                child: const Icon(Icons.add),
              ),
              loading: () => null,
              error: (_, __) => null,
            )
          : null,
      body: categoriesAsync.when(
        data: (flatCategories) {
          final categories = _buildCategoryTree(flatCategories);
          
          if (categories.isEmpty) {
            return Column(
              children: [
                AdminPageHeader(
                  title: 'categories'.tr(),
                  addLabel: 'add_category'.tr(),
                  onAdd: () => _showCategoryDialog(context, ref, categories),
                ),
                const Expanded(child: Center(child: Text('Kategoriyalar topilmadi.'))),
              ],
            );
          }

          if (isMobile) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final int depth = category['depth'] ?? 0;
                final name = category['name'] is Map ? category['name']['uz'] : category['name'];
                final parentName = category['parent']?['name'];

                return Padding(
                  padding: EdgeInsets.only(left: depth * 16.0, bottom: 8),
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: _buildCategoryThumbnail(category['image_url']?.toString()),
                      title: Text(name ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: parentName != null ? Text('Parent: $parentName', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)) : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showCategoryDialog(context, ref, categories, category: category),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCategory(context, ref, category['id'].toString()),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            );
          }

          return SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdminPageHeader(
                  title: 'categories'.tr(),
                  addLabel: 'add_category'.tr(),
                  onAdd: () => _showCategoryDialog(context, ref, categories),
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  clipBehavior: Clip.antiAlias,
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
                        DataColumn(label: Text('name_uz'.tr())),
                        DataColumn(label: Text('parent_col'.tr())),
                        DataColumn(label: Text('products_col'.tr())),
                        DataColumn(label: Text('actions'.tr())),
                      ],
                      rows: categories.map((category) {
                        final int depth = category['depth'] ?? 0;
                        final name = category['name'] is Map ? category['name']['uz'] : category['name'];
                        final parentName = category['parent']?['name'];
                        final productCount = category['products_count'] ?? 0;

                        return DataRow(
                          cells: [
                            DataCell(
                              Padding(
                                padding: EdgeInsets.only(left: depth * 24.0),
                                child: _buildCategoryThumbnail(category['image_url']?.toString()),
                              ),
                            ),
                            DataCell(
                              Padding(
                                padding: EdgeInsets.only(left: depth * 24.0),
                                child: Row(
                                  children: [
                                    if (depth > 0) const Icon(Icons.subdirectory_arrow_right, size: 16, color: Colors.grey),
                                    if (depth > 0) const SizedBox(width: 8),
                                    Text(name ?? '', style: TextStyle(fontWeight: depth == 0 ? FontWeight.bold : FontWeight.normal)),
                                  ],
                                ),
                              ),
                            ),
                            DataCell(Text(parentName != null ? parentName.toString() : '-')),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: productCount > 0 ? Colors.green.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '$productCount',
                                  style: TextStyle(
                                    color: productCount > 0 ? Colors.green : Colors.grey,
                                    fontWeight: FontWeight.bold,
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
                                    onPressed: () => _showCategoryDialog(context, ref, categories, category: category),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteCategory(context, ref, category['id'].toString()),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Xatolik: $err')),
      ),
    );
  }
}
