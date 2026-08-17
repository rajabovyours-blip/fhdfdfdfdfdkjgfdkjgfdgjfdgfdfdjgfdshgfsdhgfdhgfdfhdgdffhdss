import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/admin/presentation/providers/admin_roles_providers.dart';

class AdminRolesScreen extends ConsumerWidget {
  const AdminRolesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(adminRolesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Roles'),
      ),
      body: asyncData.when(
        data: (items) {
          if (items.isEmpty) return const Center(child: Text('No items found'));
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text('Item $index'),
                subtitle: Text(item.toString()),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
