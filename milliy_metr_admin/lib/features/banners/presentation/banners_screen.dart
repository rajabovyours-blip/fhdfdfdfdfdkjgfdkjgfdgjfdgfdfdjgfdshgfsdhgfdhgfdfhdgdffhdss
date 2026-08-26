import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/admin_providers.dart';

class BannersScreen extends ConsumerStatefulWidget {
  const BannersScreen({super.key});

  @override
  ConsumerState<BannersScreen> createState() => _BannersScreenState();
}

class _BannersScreenState extends ConsumerState<BannersScreen> {
  void _showBannerDialog(BuildContext context, {Map<String, dynamic>? banner}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(banner == null ? "Yangi banner qo'shish" : "Bannerni tahrirlash"),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: const InputDecoration(labelText: "Sarlavha (Title)"),
                  controller: TextEditingController(text: banner?['title'] ?? ''),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: "Quyi sarlavha (Subtitle)"),
                  controller: TextEditingController(text: banner?['subtitle'] ?? ''),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: "Tugma matni (CTA text)"),
                  controller: TextEditingController(text: banner?['cta'] ?? ''),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(labelText: "Rasm URL"),
                  controller: TextEditingController(text: banner?['image_url'] ?? ''),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text("Faollik holati"),
                    const Spacer(),
                    Switch(value: true, onChanged: (val) {}),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Bekor qilish")),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("Saqlash")),
        ],
      ),
    );
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
                "Bannerlar va Aksiyalar",
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showBannerDialog(context),
                icon: const Icon(Icons.add),
                label: const Text("Banner qo'shish"),
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
                    child: Text("Bannerlar mavjud emas", style: Theme.of(context).textTheme.titleLarge),
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
                      DataColumn(label: Text("Sarlavha")),
                      DataColumn(label: Text("Havola (Link)")),
                      DataColumn(label: Text("Holat")),
                      DataColumn(label: Text("Amallar")),
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
                                      child: Image.network(banner['image_url'], fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
                                    )
                                  : const Icon(Icons.image),
                            ),
                          ),
                          DataCell(Text(banner['title'] ?? 'Banner')),
                          DataCell(Text(banner['link'] ?? 'yo\'q')),
                          DataCell(
                            Switch(value: true, onChanged: (v) {}),
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
}

