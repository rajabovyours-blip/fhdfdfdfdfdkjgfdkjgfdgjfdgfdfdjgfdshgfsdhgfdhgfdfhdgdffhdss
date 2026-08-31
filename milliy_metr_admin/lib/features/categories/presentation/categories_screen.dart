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
    final idController = TextEditingController(text: isEditing ? category['id'] : '');
    final imageController = TextEditingController(
      text: isEditing ? category['image_url'] : 'assets/images/categories/cat-1.webp',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                if (!isEditing)
                  TextField(
                    controller: idController,
                    decoration: InputDecoration(labelText: 'category_id_hint'.tr()),
                  ),
                const SizedBox(height: 16),
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
                              imageController.text = ImageUtils.getFullImageUrl(response.data['data']['url']);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
                            }
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
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            onPressed: () {
              final newCat = {
                'id': isEditing ? category['id'] : idController.text,
                'name': nameUzController.text,
                'name_ru': nameRuController.text,
                'name_en': nameEnController.text,
                'image_url': imageController.text,
              };
              if (isEditing) {
                ref.read(categoriesProvider.notifier).updateCategory(newCat);
              } else {
                ref.read(categoriesProvider.notifier).addCategory(newCat);
              }
              Navigator.pop(context);
            },
            child: Text('save'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);
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
            child: SingleChildScrollView(
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
                              onPressed: () {
                                ref.read(categoriesProvider.notifier).deleteCategory(category['id']);
                              },
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
  }
}
