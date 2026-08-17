import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/admin/presentation/providers/admin_providers.dart';

class AdminSellersScreen extends ConsumerWidget {
  const AdminSellersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellersAsync = ref.watch(adminSellersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Search (Not implemented)')),
              );
            },
          ),
        ],
      ),
      body: sellersAsync.when(
        data: (sellers) {
          if (sellers.isEmpty) {
            return const Center(child: Text('No sellers found.'));
          }
          return ListView.builder(
            itemCount: sellers.length,
            itemBuilder: (context, index) {
              final seller = sellers[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.store)),
                title: Text(seller['business_name'] ?? 'Unknown Business'),
                subtitle: Text('Status: ${seller['status']}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    // Actions: View, Suspend
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Text('View Profile'),
                    ),
                    const PopupMenuItem(
                      value: 'suspend',
                      child: Text(
                        'Suspend',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
