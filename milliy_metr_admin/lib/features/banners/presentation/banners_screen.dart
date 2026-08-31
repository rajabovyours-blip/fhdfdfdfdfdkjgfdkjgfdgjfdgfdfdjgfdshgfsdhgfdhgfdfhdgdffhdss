import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:milliy_metr_admin/core/utils/image_utils.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/api/api_client.dart';
import 'package:easy_localization/easy_localization.dart';

class BannersScreen extends ConsumerStatefulWidget {
  const BannersScreen({super.key});

  @override
  ConsumerState<BannersScreen> createState() => _BannersScreenState();
}

class _BannersScreenState extends ConsumerState<BannersScreen> {
  void _showBannerDialog(BuildContext context, {Map<String, dynamic>? banner}) {
    final titleController = TextEditingController(text: banner?['title'] ?? '');
    final linkController = TextEditingController(text: banner?['link_url'] ?? '');
    final imageController = TextEditingController(text: banner?['image_url'] ?? '');
    bool isActive = banner?['is_active'] ?? true;
    bool isLoading = false;
    final isEditing = banner != null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'edit_banner'.tr() : 'add_banner'.tr()),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(labelText: 'banner_title'.tr()),
                    controller: titleController,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(labelText: 'banner_link'.tr()),
                    controller: linkController,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(labelText: 'banner_image_url'.tr()),
                          controller: imageController,
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('activity_status'.tr()),
                      const Spacer(),
                      Switch(
                        value: isActive, 
                        onChanged: (val) {
                          setDialogState(() => isActive = val);
                        }
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr())),
            ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (imageController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('banner_image_required'.tr()), backgroundColor: Colors.red));
                        return;
                      }
                      setDialogState(() => isLoading = true);
                      try {
                        final dio = ref.read(dioProvider);
                        if (banner == null) {
                          await dio.post('/banners', data: {
                            'title': titleController.text,
                            'link_url': linkController.text,
                            'image_url': imageController.text,
                            'is_active': isActive,
                            'order_index': 0,
                          });
                        } else {
                          await dio.delete('/banners/${banner['id']}');
                          await dio.post('/banners', data: {
                            'title': titleController.text,
                            'link_url': linkController.text,
                            'image_url': imageController.text,
                            'is_active': isActive,
                            'order_index': 0,
                          });
                        }
                        if (context.mounted) {
                          Navigator.pop(context);
                          ref.invalidate(bannersProvider);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Banner saqlandi"), backgroundColor: Colors.green));
                        }
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Xatolik: $e"), backgroundColor: Colors.red));
                        }
                      }
                    },
              icon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save),
              label: Text(isLoading ? 'loading'.tr() : 'save'.tr()),
            ),
          ],
        ),
      ),
    );
  }
  
  void _deleteBanner(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete_banner'.tr()),
        content: Text('delete_banner_confirm'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('no'.tr())),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: Text('yes_delete'.tr())),
        ],
      ),
    );
    
    if (confirm == true) {
      try {
        final dio = ref.read(dioProvider);
        await dio.delete('/banners/$id');
        ref.invalidate(bannersProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Banner o'chirildi"), backgroundColor: Colors.green));
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
    final bannersAsyncValue = ref.watch(bannersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'banners'.tr(),
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showBannerDialog(context),
                icon: const Icon(Icons.add),
                label: Text('add_banner'.tr()),
              ),
            ],
          ),
          const SizedBox(height: 24),
          bannersAsyncValue.when(
            data: (banners) {
              if (banners.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.view_carousel_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text('no_banners'.tr(), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => _showBannerDialog(context),
                          icon: const Icon(Icons.add),
                          label: Text('add_banner'.tr()),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
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
                    columns: [
                      DataColumn(label: Text('image'.tr())),
                      DataColumn(label: Text('banner_title'.tr())),
                      DataColumn(label: Text('banner_link_label'.tr())),
                      DataColumn(label: Text('status'.tr())),
                      DataColumn(label: Text('actions'.tr())),
                    ],
                    rows: banners.map((banner) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Container(
                              width: 120,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              ),
                              child: banner['image_url'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(ImageUtils.getFullImageUrl(banner['image_url']), fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
                                    )
                                  : const Icon(Icons.image),
                            ),
                          ),
                          DataCell(Text(banner['title'] ?? 'Banner')),
                          DataCell(Text(banner['link_url'] ?? 'yo\'q')),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (banner['is_active'] == true ? const Color(0xFF10B981) : Colors.grey).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                banner['is_active'] == true ? 'active'.tr() : 'inactive'.tr(),
                                style: TextStyle(
                                  color: banner['is_active'] == true ? const Color(0xFF10B981) : Colors.grey,
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
                                  onPressed: () => _showBannerDialog(context, banner: banner),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteBanner(banner['id']),
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
}
