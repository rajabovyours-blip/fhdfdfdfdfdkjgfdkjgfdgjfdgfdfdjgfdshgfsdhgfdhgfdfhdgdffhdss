import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/admin_providers.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  @override
  Widget build(BuildContext context) {
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
            data: (users) {
              if (users.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Text("Mijozlar topilmadi", style: Theme.of(context).textTheme.titleLarge),
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
                    ],
                    rows: users.map((user) {
                      return DataRow(
                        cells: [
                          DataCell(Text(user['full_name'] ?? 'Noma\'lum')),
                          DataCell(Text(user['phone'] ?? '+998 ** *** ** **')),
                          DataCell(Text(user['email'] ?? '-')),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.phone_android, size: 16, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text(user['auth_provider'] ?? 'Telefon'),
                              ],
                            ),
                          ),
                          DataCell(Text(user['created_at'] != null ? user['created_at'].toString().split('T')[0] : 'Yaqinda')),
                          DataCell(Text((user['total_orders'] ?? 0).toString())),
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

