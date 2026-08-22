import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/providers/admin_providers.dart';

class UsersScreen extends ConsumerWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsyncValue = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(title: Text('users'.tr())),
      body: usersAsyncValue.when(
        data: (users) {
          if (users.isEmpty) {
            return Center(child: Text('no_data'.tr()));
          }
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(user['full_name'] ?? user['email'] ?? 'User'),
                subtitle: Text(user['role'] ?? 'Customer'),
                trailing: Text(user['is_active'] == true ? 'Active' : 'Inactive'),
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
