import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/providers/admin_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  void _showCategoryDialog(BuildContext context, WidgetRef ref, {Map<String, dynamic>? category}) {
    final isEditing = category != null;
    final nameController = TextEditingController(text: isEditing ? category['name'] : '');
    final idController = TextEditingController(text: isEditing ? category['id'] : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'edit_category'.tr(fallback: 'Edit Category') : 'add_category'.tr(fallback: 'Add Category')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isEditing)
              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: 'Category ID (e.g. cat-99)'),
              ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr(fallback: 'Cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              final newCat = {
                'id': isEditing ? category['id'] : idController.text,
                'name': nameController.text,
                'image_url': isEditing ? category['image_url'] : 'assets/images/categories/default.webp',
              };
              if (isEditing) {
                ref.read(categoriesProvider.notifier).updateCategory(newCat);
              } else {
                ref.read(categoriesProvider.notifier).addCategory(newCat);
              }
              Navigator.pop(context);
            },
            child: Text('save'.tr(fallback: 'Save')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('categories'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Category',
            onPressed: () => _showCategoryDialog(context, ref),
          ),
        ],
      ),
      body: categories.isEmpty
          ? Center(child: Text('no_data'.tr()))
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.category)),
                  title: Text(category['name'] ?? 'Category'),
                  subtitle: Text('ID: ${category['id']}'),
                  trailing: Row(
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
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}
