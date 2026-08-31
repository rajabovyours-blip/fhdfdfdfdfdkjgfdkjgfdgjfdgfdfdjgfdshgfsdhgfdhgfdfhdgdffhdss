import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:milliy_metr_admin/shared/utils/responsive_modal.dart';
import 'package:milliy_metr_admin/core/utils/image_utils.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/api/api_client.dart';

class BannersScreen extends ConsumerStatefulWidget {
  const BannersScreen({super.key});

  @override
  ConsumerState<BannersScreen> createState() => _BannersScreenState();
}

class _BannersScreenState extends ConsumerState<BannersScreen> {
  
  void _showBannerDialog(BuildContext context, {Map<String, dynamic>? banner}) {
    final titleController = TextEditingController(text: banner?['title'] ?? '');
    final linkController = TextEditingController(text: banner?['link_url'] ?? '');
    String existingImageUrl = banner?['image_url'] ?? '';
    
    PlatformFile? selectedImageFile;
    Uint8List? localImageBytes;
    bool isLoading = false;
    final isEditing = banner != null;

    showAdminFormModal(
      context: context,
      title: isEditing ? 'edit_banner'.tr() : 'add_banner'.tr(),
      icon: isEditing ? Icons.edit : Icons.add_box_rounded,
      builder: (dialogContext, setDialogState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Image Field (Required)
                    Text("banner_image".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final result = await FilePicker.pickFiles(
                          type: FileType.image,
                          withData: true,
                        );
                        if (result != null && result.files.isNotEmpty) {
                          setDialogState(() {
                            selectedImageFile = result.files.first;
                            localImageBytes = result.files.first.bytes;
                            existingImageUrl = ''; // Clear existing network image
                          });
                        }
                      },
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: _buildImagePreview(localImageBytes, existingImageUrl, context),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tasvir ustiga bosib yangi rasm yuklang.",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 24),
                    
                    // 2. Internal Label
                    Text("Ichki nom (Faqat admin uchun)", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        hintText: 'Masalan: Yangi yil aksiyasi',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // 3. Link (URL)
                    Text("banner_link".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: linkController,
                      decoration: InputDecoration(
                        hintText: 'Havola manzili (ixtiyoriy)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(dialogContext).viewInsets.bottom > 0 ? 12 : 24,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: const Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext), 
                    child: Text('cancel'.tr())
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (localImageBytes == null && existingImageUrl.isEmpty) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(content: Text('Iltimos, banner rasmini yuklang'), backgroundColor: Colors.red)
                              );
                              return;
                            }
                            
                            setDialogState(() => isLoading = true);
                            try {
                              final dio = ref.read(dioProvider);
                              String finalImageUrl = existingImageUrl;
                              
                              // Upload new image if selected
                              if (localImageBytes != null && selectedImageFile != null) {
                                final formData = FormData.fromMap({
                                  'file': MultipartFile.fromBytes(
                                    localImageBytes!,
                                    filename: selectedImageFile!.name,
                                  ),
                                });
                                final uploadResp = await dio.post('/upload/image', data: formData);
                                if (uploadResp.data['data'] != null && uploadResp.data['data']['url'] != null) {
                                  finalImageUrl = uploadResp.data['data']['url'];
                                } else {
                                  throw Exception("Rasm yuklashda xatolik");
                                }
                              }

                              final payload = {
                                'title': titleController.text,
                                'link_url': linkController.text.isEmpty ? null : linkController.text,
                                'image_url': finalImageUrl,
                                'is_active': true, // Auto true, since we removed the toggle
                                'order_index': 0,
                              };

                              if (!isEditing) {
                                await dio.post('/banners', data: payload);
                              } else {
                                // Since current backend might not have proper PATCH, standard here seems to be delete then post (as in previous code),
                                // Wait, usually we just send a PUT/PATCH or if none exists delete+post. I will use delete+post to match previous working logic.
                                await dio.delete('/banners/${banner['id']}');
                                await dio.post('/banners', data: payload);
                              }
                              
                              if (dialogContext.mounted) {
                                Navigator.pop(dialogContext);
                                ref.invalidate(bannersProvider);
                                ScaffoldMessenger.of(dialogContext).showSnackBar(
                                  const SnackBar(content: Text("Banner muvaffaqiyatli saqlandi"), backgroundColor: Colors.green)
                                );
                              }
                            } catch (e) {
                              setDialogState(() => isLoading = false);
                              if (dialogContext.mounted) {
                                ScaffoldMessenger.of(dialogContext).showSnackBar(
                                  SnackBar(content: Text("Xatolik: $e"), backgroundColor: Colors.red)
                                );
                              }
                            }
                          },
                    icon: isLoading 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Icon(Icons.save),
                    label: Text('save'.tr()),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePreview(Uint8List? localBytes, String existingUrl, BuildContext context) {
    if (localBytes != null) {
      return Image.memory(
        localBytes,
        fit: BoxFit.cover,
        width: double.infinity,
      );
    } else if (existingUrl.isNotEmpty) {
      return Image.network(
        ImageUtils.getFullImageUrl(existingUrl),
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (context, error, stackTrace) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.broken_image, size: 48, color: Colors.grey),
            const SizedBox(height: 8),
            Text("Rasmni yuklab bo'lmadi", style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey.shade400),
          const SizedBox(height: 8),
          Text("Rasm tanlash", style: TextStyle(color: Colors.grey.shade600)),
        ],
      );
    }
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
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 640;

    return Scaffold(
      backgroundColor: Colors.transparent, // Let parent handle background
      floatingActionButton: isMobile ? FloatingActionButton(
        onPressed: () => _showBannerDialog(context),
        backgroundColor: const Color(0xFFFF7A00),
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'banners'.tr(),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                if (!isMobile)
                  ElevatedButton.icon(
                    onPressed: () => _showBannerDialog(context),
                    icon: const Icon(Icons.add),
                    label: Text('add_banner'.tr()),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: bannersAsyncValue.when(
              data: (banners) {
                if (banners.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.view_carousel_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text('no_banners'.tr(), style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
                        if (isMobile) ...[
                          const SizedBox(height: 8),
                          const Text("Yangi banner qo'shish uchun + tugmasini bosing", style: TextStyle(color: Colors.grey)),
                        ]
                      ],
                    ),
                  );
                }

                if (isMobile) {
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: banners.length,
                    itemBuilder: (context, index) {
                      final banner = banners[index];
                      final title = (banner['title'] == null || banner['title'].toString().isEmpty) ? 'Nomsiz' : banner['title'];
                      final link = (banner['link_url'] == null || banner['link_url'].toString().isEmpty) ? 'Havola yo\'q' : banner['link_url'];
                      final imageUrl = banner['image_url'] ?? '';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        clipBehavior: Clip.antiAlias,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            AspectRatio(
                              aspectRatio: 2.5,
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      ImageUtils.getFullImageUrl(imageUrl),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey)),
                                    )
                                  : const Center(child: Icon(Icons.image, size: 48, color: Colors.grey)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            const Icon(Icons.link, size: 14, color: Colors.blue),
                                            const SizedBox(width: 4),
                                            Expanded(child: Text(link, style: const TextStyle(color: Colors.blue, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
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
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                }

                // Desktop Table View
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.outline),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceContainerHighest),
                        columns: [
                          DataColumn(label: Text('Tasvir'.tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Ichki nom'.tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Havola'.tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('actions'.tr(), style: const TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: banners.map((banner) {
                          final title = (banner['title'] == null || banner['title'].toString().isEmpty) ? 'Nomsiz' : banner['title'];
                          final link = (banner['link_url'] == null || banner['link_url'].toString().isEmpty) ? 'Havola yo\'q' : banner['link_url'];
                          final imageUrl = banner['image_url'] ?? '';

                          return DataRow(
                            cells: [
                              DataCell(
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Container(
                                    width: 140,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    ),
                                    child: imageUrl.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              ImageUtils.getFullImageUrl(imageUrl),
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.grey),
                                            ),
                                          )
                                        : const Icon(Icons.image, color: Colors.grey),
                                  ),
                                ),
                              ),
                              DataCell(Text(title)),
                              DataCell(
                                link == 'Havola yo\'q' 
                                  ? Text(link, style: const TextStyle(color: Colors.grey))
                                  : Row(
                                      children: [
                                        const Icon(Icons.link, size: 16, color: Colors.blue),
                                        const SizedBox(width: 4),
                                        Text(link, style: const TextStyle(color: Colors.blue)),
                                      ],
                                    ),
                              ),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      tooltip: 'Tahrirlash',
                                      onPressed: () => _showBannerDialog(context, banner: banner),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      tooltip: "O'chirish",
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
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A00))),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text('Xatolik: $error'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(bannersProvider),
                      child: const Text("Qayta urinish"),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
