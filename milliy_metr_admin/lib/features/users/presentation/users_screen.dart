import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr_admin/shared/utils/responsive_modal.dart';
import 'package:milliy_metr_admin/shared/widgets/admin_page_header.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/api/api_client.dart';
import 'package:easy_localization/easy_localization.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showUserDialog(BuildContext context, Map<String, dynamic> user) {
    final nameController = TextEditingController(text: user['fullName'] ?? '');
    final phoneController = TextEditingController(text: user['phoneNumber'] ?? '');
    bool isActive = user['isActive'] ?? true;
    bool isLoading = false;
    
    final registrationDate = user['createdAt'] != null ? user['createdAt'].toString().split('T')[0] : 'recently'.tr();
    final ordersCount = (user['ordersCount'] ?? 0).toString();
    final authProvider = user['authProvider'] ?? 'unknown'.tr();

    showAdminFormModal(
      context: context,
      title: "customer_details".tr(),
      icon: Icons.person,
      builder: (dialogContext, setDialogState) {
        return Column(
          children: [
            // Read-only stats block
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("registered_date".tr(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(registrationDate, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("orders_count".tr(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(ordersCount, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("login_method".tr(), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(authProvider == 'Apple ID' ? Icons.apple : Icons.phone_android, size: 14, color: Colors.grey.shade700),
                            const SizedBox(width: 4),
                            Text(authProvider, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Editable fields
            Text("full_name_abbr".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            
            Text("phone_number_label".tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 24),
            
            // Status toggle
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: isActive ? Colors.green.shade200 : Colors.red.shade200),
                borderRadius: BorderRadius.circular(8),
                color: isActive ? Colors.green.withValues(alpha: 0.05) : Colors.red.withValues(alpha: 0.05),
              ),
              child: SwitchListTile(
                title: Text(
                  isActive ? "customer_active".tr() : "customer_blocked".tr(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.green.shade700 : Colors.red.shade700
                  )
                ),
                subtitle: Text(
                  isActive 
                    ? "customer_active_desc".tr() 
                    : "customer_blocked_desc".tr(),
                  style: const TextStyle(fontSize: 12)
                ),
                value: isActive,
                activeColor: Colors.green,
                inactiveThumbColor: Colors.red,
                inactiveTrackColor: Colors.red.shade200,
                onChanged: (val) {
                  setDialogState(() => isActive = val);
                },
              ),
            ),
          ],
        );
      },
      actionsBuilder: (dialogContext, setDialogState) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext), 
              child: Text("close_btn".tr())
            ),
            const SizedBox(width: 16),
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
                        
                        if (dialogContext.mounted) {
                          Navigator.pop(dialogContext);
                          ref.invalidate(usersProvider);
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text("customer_updated".tr()), backgroundColor: Colors.green)
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isLoading = false);
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text("${"error_prefix".tr()}: $e"), backgroundColor: Colors.red)
                          );
                        }
                      }
                    },
              icon: isLoading 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                  : const Icon(Icons.save),
              label: Text(isLoading ? 'saving'.tr() : 'save'.tr()),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersAsyncValue = ref.watch(usersProvider);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 640;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminPageHeader(
          title: 'customers'.tr(),
        ),
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                constraints: const BoxConstraints(maxWidth: 400),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: "search_customer_hint".tr(),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty 
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val.toLowerCase();
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        
        Expanded(
          child: usersAsyncValue.when(
            data: (usersRaw) {
              // Filter to customers only, then apply search query
              var users = usersRaw.where((u) => u['role'] == 'USER').toList();
              
              if (_searchQuery.isNotEmpty) {
                users = users.where((u) {
                  final name = (u['fullName'] ?? '').toString().toLowerCase();
                  final phone = (u['phoneNumber'] ?? '').toString().toLowerCase();
                  return name.contains(_searchQuery) || phone.contains(_searchQuery);
                }).toList();
              }
              
              if (users.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(48.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isNotEmpty ? "no_customer_found".tr() : "no_customers_msg".tr(), 
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.grey)
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (isMobile) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final name = user['fullName'] ?? 'unknown'.tr();
                    final phone = user['phoneNumber'] ?? 'no_phone_provided'.tr();
                    final date = user['createdAt'] != null ? user['createdAt'].toString().split('T')[0] : 'recently'.tr();
                    final ordersCount = (user['ordersCount'] ?? 0).toString();
                    final isActive = user['isActive'] == true;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 1,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showUserDialog(context, user),
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
                                      name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  _buildStatusBadge(isActive),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(phone),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.shopping_bag_outlined, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text("$ordersCount ${'orders_word'.tr()}", style: const TextStyle(color: Colors.grey)),
                                  const Spacer(),
                                  Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surfaceContainerHighest),
                      headingTextStyle: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      columns: [
                        DataColumn(label: Text("full_name_abbr".tr())),
                        DataColumn(label: Text("phone_number_label".tr())),
                        DataColumn(label: Text("email".tr())),
                        DataColumn(label: Text("login_type".tr())),
                        DataColumn(label: Text("date".tr())),
                        DataColumn(label: Text("orders".tr())),
                        DataColumn(label: Text("status".tr())),
                        DataColumn(label: Text("actions".tr())),
                      ],
                      rows: users.map((user) {
                        final authProvider = user['authProvider'] ?? 'Telefon';
                        return DataRow(
                          cells: [
                            DataCell(Text(user['fullName'] ?? 'unknown'.tr(), style: const TextStyle(fontWeight: FontWeight.w500))),
                            DataCell(Text(user['phoneNumber'] ?? '-')),
                            DataCell(Text(user['email'] ?? '-')),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(authProvider == 'Apple ID' ? Icons.apple : Icons.phone_android, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Text(authProvider, style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                            DataCell(Text(user['createdAt'] != null ? user['createdAt'].toString().split('T')[0] : 'recently'.tr())),
                            DataCell(Text((user['ordersCount'] ?? 0).toString())),
                            DataCell(_buildStatusBadge(user['isActive'] == true)),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                                tooltip: 'details_and_edit'.tr(),
                                onPressed: () => _showUserDialog(context, user),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A00))),
            error: (error, stack) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Xatolik: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(usersProvider),
                    child: const Text("Qayta urinish"),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? const Color(0xFF10B981) : Colors.red).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isActive ? 'active_status'.tr() : 'blocked_status'.tr(),
        style: TextStyle(
          color: isActive ? const Color(0xFF10B981) : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
