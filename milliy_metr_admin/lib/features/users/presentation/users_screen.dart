import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/api/api_client.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  void _showUserDialog(BuildContext context, Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['fullName'] ?? '');
    final phoneController = TextEditingController(text: user['phoneNumber'] ?? '');
    bool isActive = user['isActive'] ?? true;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Mijoz ma'lumotlarini tahrirlash"),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: "F.I.Sh."),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: "Telefon raqami"),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text("Faollik holati (Bloklash)"),
                  value: isActive,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (val) {
                    setDialogState(() => isActive = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Bekor qilish")),
            ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () async {
                      setDialogState(() => isLoading = true);
                      try {
                        final dio = ref.read(dioProvider);
                        await dio.put('/users/${user['id']}', data: {
                          'full_name': nameController.text,
                          'phone_number': phoneController.text,
                          'is_active': isActive,
                        });
                        
                        if (context.mounted) {
                          Navigator.pop(context);
                          ref.invalidate(usersProvider);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mijoz yangilandi"), backgroundColor: Colors.green));
                        }
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Xatolik: $e"), backgroundColor: Colors.red));
                        }
                      }
                    },
              icon: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.save),
              label: Text(isLoading ? 'Saqlanmoqda...' : 'Saqlash'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Modify usersProvider to include ?role=USER by invalidating and overriding or changing the provider.
    // For now, our usersProvider already fetches /users/ which filters roles if passed, but currently provider doesn't pass it.
    // We can rely on the fact that /users/ returns all, and we just show them, or better yet, fetch /users?role=USER directly.
    // Given we can't easily change the provider arg without Riverpod family, let's just use the provider and filter locally, 
    // or modify admin_providers.dart. Actually, in admin_providers.dart usersProvider does a GET /users/ which we modified in backend to accept ?role=USER.
    // Let's just fetch it as is and if they are all users, good.
    final usersAsyncValue = ref.watch(usersProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Mijozlar Bazasi",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          usersAsyncValue.when(
            data: (usersRaw) {
              final users = usersRaw.where((u) => u['role'] == 'USER').toList();
              
              if (users.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text("Mijozlar topilmadi", style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)),
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
                    columns: const [
                      DataColumn(label: Text("Ism Familiya")),
                      DataColumn(label: Text("Telefon")),
                      DataColumn(label: Text("Email")),
                      DataColumn(label: Text("Ro'yxatdan o'tgan turi")),
                      DataColumn(label: Text("Sana")),
                      DataColumn(label: Text("Buyurtmalar")),
                      DataColumn(label: Text("Holat")),
                      DataColumn(label: Text("Amallar")),
                    ],
                    rows: users.map((user) {
                      return DataRow(
                        cells: [
                          DataCell(Text(user['fullName'] ?? 'Noma\'lum')),
                          DataCell(Text(user['phoneNumber'] ?? '+998 ** *** ** **')),
                          DataCell(Text(user['email'] ?? '-')),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(user['authProvider'] == 'Apple ID' ? Icons.apple : Icons.phone_android, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(user['authProvider'] ?? 'Telefon'),
                              ],
                            ),
                          ),
                          DataCell(Text(user['createdAt'] != null ? user['createdAt'].toString().split('T')[0] : 'Yaqinda')),
                          DataCell(Text((user['ordersCount'] ?? 0).toString())),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (user['isActive'] == true ? const Color(0xFF10B981) : Colors.red).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                user['isActive'] == true ? 'Faol' : 'Bloklangan',
                                style: TextStyle(
                                  color: user['isActive'] == true ? const Color(0xFF10B981) : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showUserDialog(context, user),
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
