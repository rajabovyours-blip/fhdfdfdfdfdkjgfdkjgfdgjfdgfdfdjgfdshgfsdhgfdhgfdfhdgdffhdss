import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/admin_users_provider.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends ConsumerState<AdminUsersScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'ADMIN';

  void _showCreateDialog() {
    _usernameController.clear();
    _fullNameController.clear();
    _passwordController.clear();
    _selectedRole = 'ADMIN';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yangi Administrator'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (v) => v!.isEmpty ? 'Kiritish majburiy' : null,
              ),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'F.I.Sh (Full Name)'),
                validator: (v) => v!.isEmpty ? 'Kiritish majburiy' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Parol'),
                obscureText: true,
                validator: (v) => v!.length < 6 ? 'Kamida 6 ta belgi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                  DropdownMenuItem(value: 'OWNER', child: Text('OWNER')),
                ],
                onChanged: (v) => setState(() => _selectedRole = v!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final nav = Navigator.of(context);
                await ref.read(createAdminProvider)(
                  _usernameController.text,
                  _fullNameController.text,
                  _passwordController.text,
                  _selectedRole,
                );
                if (mounted) nav.pop();
              }
            },
            child: const Text('Saqlash'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final asyncUsers = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administratorlar (Tizim Boshqaruvi)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateDialog,
          ),
        ],
      ),
      body: asyncUsers.when(
        data: (users) {
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                title: Text(user.fullName),
                subtitle: Text('Username: ${user.username} | Role: ${user.role}'),
                trailing: Switch(
                  value: user.isActive,
                  onChanged: (val) async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await ref.read(toggleAdminStatusProvider)(user.id, val);
                    } catch (e) {
                      messenger.showSnackBar(
                        const SnackBar(content: Text('Xatolik yoki o\'zingizni o\'chira olmaysiz')),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Xatolik: $err')),
      ),
    );
  }
}
