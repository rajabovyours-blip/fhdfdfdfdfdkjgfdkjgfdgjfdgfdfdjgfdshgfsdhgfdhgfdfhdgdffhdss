import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:milliy_metr_admin/shared/utils/responsive_modal.dart';
import 'package:milliy_metr_admin/core/api/api_client.dart';
import 'package:dio/dio.dart';
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

  void _showFormDialog({AdminUser? user}) {
    _usernameController.text = user?.username ?? '';
    _fullNameController.text = user?.fullName ?? '';
    _passwordController.clear();
    _selectedRole = user?.role ?? 'ADMIN';

    showAdminFormModal(
      context: context,
      title: user == null ? 'Yangi Administrator' : 'Administratorni tahrirlash',
      icon: Icons.admin_panel_settings,
      builder: (dialogContext, setDialogState) {
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username (Login)'),
                readOnly: user != null, // Typically username is not editable after creation
                validator: (v) => v!.isEmpty ? 'Kiritish majburiy' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'F.I.Sh (Full Name)'),
                validator: (v) => v!.isEmpty ? 'Kiritish majburiy' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: user == null ? 'Parol' : 'Yangi Parol (ixtiyoriy)',
                ),
                obscureText: true,
                validator: (v) {
                  if (user == null && (v == null || v.isEmpty)) {
                    return 'Yangi admin uchun parol majburiy';
                  }
                  if (v != null && v.isNotEmpty && v.length < 6) {
                    return 'Kamida 6 ta belgi bo\'lishi shart';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(value: 'ADMIN', child: Text('ADMIN')),
                  DropdownMenuItem(value: 'OWNER', child: Text('OWNER')),
                ],
                onChanged: (v) => setDialogState(() => _selectedRole = v!),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Bekor qilish'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        final nav = Navigator.of(dialogContext);
                        final scaffold = ScaffoldMessenger.of(context);
                        
                        try {
                          if (user == null) {
                            await ref.read(createAdminProvider)(
                              _usernameController.text.trim(),
                              _fullNameController.text.trim(),
                              _passwordController.text,
                              _selectedRole,
                            );
                            scaffold.showSnackBar(const SnackBar(content: Text('Muvaffaqiyatli qo\'shildi'), backgroundColor: Colors.green));
                          } else {
                            await ref.read(editAdminProvider)(
                              user.id,
                              _fullNameController.text.trim(),
                              _passwordController.text.isEmpty ? null : _passwordController.text,
                              _selectedRole,
                            );
                            scaffold.showSnackBar(const SnackBar(content: Text('Muvaffaqiyatli tahrirlandi'), backgroundColor: Colors.green));
                          }
                          if (mounted) nav.pop();
                        } on DioException catch (e) {
                          final msg = e.response?.data?['detail'] ?? 'Xatolik yuz berdi';
                          scaffold.showSnackBar(SnackBar(content: Text(msg.toString()), backgroundColor: Colors.red));
                        } catch (e) {
                          scaffold.showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                        }
                      }
                    },
                    child: const Text('Saqlash'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleStatus(AdminUser user, bool val) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(toggleAdminStatusProvider)(user.id, val);
    } on DioException catch (e) {
      final detail = e.response?.data?['detail'] ?? 'Xatolik yuz berdi';
      messenger.showSnackBar(
        SnackBar(content: Text(detail.toString()), backgroundColor: Colors.red),
      );
    } catch (e) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Xatolik yuz berdi'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncUsers = ref.watch(adminUsersProvider);
    final isDesktop = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      backgroundColor: Colors.transparent, // Managed by shell
      appBar: AppBar(
        title: const Text('Administratorlar (Tizim Boshqaruvi)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (isDesktop && asyncUsers.hasValue && asyncUsers.value != null)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ElevatedButton.icon(
                onPressed: () => _showFormDialog(),
                icon: const Icon(Icons.add),
                label: const Text('Yangi Administrator'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: (!isDesktop && asyncUsers.hasValue && asyncUsers.value != null)
          ? FloatingActionButton(
              onPressed: () => _showFormDialog(),
              backgroundColor: Theme.of(context).primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
      body: asyncUsers.when(
        data: (users) {
          if (isDesktop) {
            return _buildDesktopTable(users);
          } else {
            return _buildMobileList(users);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) {
          if (err is AdminAccessDeniedException) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Ruxsat etilmagan',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    err.message,
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return Center(child: Text('Xatolik: $err', style: const TextStyle(color: Colors.red)));
        },
      ),
    );
  }

  Widget _buildDesktopTable(List<AdminUser> users) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.resolveWith((states) => Colors.grey.shade100),
            columns: const [
              DataColumn(label: Text('Ism Familiya (F.I.Sh)', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Username', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Rol', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Holati', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Amallar', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: users.map((user) {
              return DataRow(
                cells: [
                  DataCell(Text(user.fullName, style: const TextStyle(fontWeight: FontWeight.w500))),
                  DataCell(Text(user.username)),
                  DataCell(_buildRoleBadge(user.role)),
                  DataCell(
                    Switch(
                      value: user.isActive,
                      onChanged: (val) => _toggleStatus(user, val),
                      activeColor: Colors.green,
                    ),
                  ),
                  DataCell(
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showFormDialog(user: user),
                          tooltip: 'Tahrirlash',
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
  }

  Widget _buildMobileList(List<AdminUser> users) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        user.fullName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    _buildRoleBadge(user.role),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Username: ${user.username}', style: TextStyle(color: Colors.grey.shade700)),
                const SizedBox(height: 16),
                const Divider(height: 1),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('Faol: '),
                        Switch(
                          value: user.isActive,
                          onChanged: (val) => _toggleStatus(user, val),
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Tahrirlash'),
                      onPressed: () => _showFormDialog(user: user),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleBadge(String role) {
    final isOwner = role.toUpperCase() == 'OWNER';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isOwner ? Colors.purple.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isOwner ? Colors.purple.shade200 : Colors.blue.shade200),
      ),
      child: Text(
        role,
        style: TextStyle(
          color: isOwner ? Colors.purple.shade700 : Colors.blue.shade700,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
