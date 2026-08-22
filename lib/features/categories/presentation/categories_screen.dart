import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/providers/admin_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsyncValue = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('categories'.tr())),
      body: categoriesAsyncValue.when(
        data: (categories) {
          if (categories.isEmpty) {
            return Center(child: Text('no_data'.tr()));
          }
          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.category)),
                title: Text(category['name'] ?? category['title'] ?? 'Category'),
                trailing: const Icon(Icons.chevron_right),
              );
            },
          );
        },
        loading: () => Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('loading'.tr()),
          ],
        )),
        error: (error, stack) => Center(child: Text('${'error'.tr()}: $error')),
      ),
    );
  }
}
