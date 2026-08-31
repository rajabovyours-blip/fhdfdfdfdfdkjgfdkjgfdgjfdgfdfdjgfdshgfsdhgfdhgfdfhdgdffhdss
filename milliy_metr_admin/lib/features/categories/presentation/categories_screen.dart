import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
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
  void _showCategoryDialog(BuildContext context, WidgetRef ref, {Map<String, dynamic>? category}) {
    final isEditing = category != null;
    final nameUzController = TextEditingController(text: isEditing ? category['name'] : '');
    final nameRuController = TextEditingController(text: isEditing ? category['name_ru'] ?? '' : '');
    final nameEnController = TextEditingController(text: isEditing ? category['name_en'] ?? '' : '');
    final imageController = TextEditingController(
      text: isEditing ? category['image_url'] : '',
    );
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isEditing ? Icons.edit : Icons.add_box_rounded,
                    color: const Color(0xFFFF7A00),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(isEditing ? 'edit_category'.tr() : 'add_category'.tr()),
                ),
              ],
            ),
            content: SizedBox(
              width: 500,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: imageController,
                            decoration: InputDecoration(labelText: 'image_url_or_asset'.tr()),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await FilePicker.pickFiles(type: FileType.image);
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
                                    imageController.text = ImageUtils.getFullImageUrl(response.data['data']['url']);
                                  });
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
                                }
                              } finally {
                                setDialogState(() => isLoading = false);
                              }
                            }
                          },
                          icon: const Icon(Icons.upload_file),
                          label: Text('upload_image'.tr()),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: Text('cancel'.tr()),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        setDialogState(() => isLoading = true);
                        try {
                          final dio = ref.read(dioProvider);
                          final payload = {
                            'name': nameUzController.text,
                            'name_ru': nameRuController.text,
                            'name_en': nameEnController.text,
                            'image_url': imageController.text,
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
          );
        },
      ),
    );
  }

  Future<void> _deleteCategory(BuildContext context, WidgetRef ref, int id) async {
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

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Header (responsive) ─────────────────────────────────────
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'categories'.tr(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showCategoryDialog(context, ref),
                        icon: const Icon(Icons.add, size: 18),
                        label: Text('add_category'.tr()),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'categories'.tr(),
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showCategoryDialog(context, ref),
                      icon: const Icon(Icons.add),
                      label: Text('add_category'.tr()),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(200, 48),
                      ),
                    ),
                  ],
                ),
          const SizedBox(height: 24),
          // ─── Categories Table ────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return const Center(child: Text('Kategoriyalar topilmadi.'));
                }
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('image'.tr())),
                      const DataColumn(label: Text('ID')),
                      DataColumn(label: Text('name_uz'.tr())),
                      DataColumn(label: Text('name_ru'.tr())),
                      DataColumn(label: Text('name_en'.tr())),
                      DataColumn(label: Text('actions'.tr())),
                    ],
                    rows: categories.map((category) {
                      final rawUrl = category['image_url']?.toString();
                      final imageUrl = ImageUtils.getFullImageUrl(rawUrl);
                      final isAsset = imageUrl.startsWith('assets/');
                      final isNetwork = imageUrl.isNotEmpty && !isAsset;

                      return DataRow(
                        cells: [
                          DataCell(
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: isAsset
                                  ? Image.asset(
                                      imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Icon(Icons.category, size: 20),
                                    )
                                  : isNetwork
                                      ? Image.network(
                                          imageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => const Icon(Icons.category, size: 20),
                                        )
                                      : const Icon(Icons.category, size: 20),
                            ),
                          ),
                          DataCell(Text(category['id'].toString())),
                          DataCell(Text(category['name'] ?? '')),
                          DataCell(Text(category['name_ru'] ?? '')),
                          DataCell(Text(category['name_en'] ?? '')),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showCategoryDialog(context, ref, category: category),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteCategory(context, ref, category['id']),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Xatolik: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
