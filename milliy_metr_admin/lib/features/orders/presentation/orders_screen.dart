import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:milliy_metr_admin/shared/utils/responsive_modal.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/api/api_client.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final formatCurrency = NumberFormat.currency(locale: 'uz_UZ', symbol: '', decimalDigits: 0);

  final List<String> _tabs = [
    "Barchasi",
    "Kutilmoqda",
    "Tasdiqlangan",
    "Yetkazilmoqda",
    "Yetkazildi",
    "Bekor qilingan"
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _updateOrderStatus(BuildContext context, String id, String newStatus, StateSetter setDialogState) async {
    setDialogState(() {});
    try {
      final dio = ref.read(dioProvider);
      await dio.patch('/orders/$id/status', data: {'status': newStatus});
      ref.invalidate(ordersProvider);
      ref.invalidate(analyticsProvider);
      if (context.mounted) {
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Holat yangilandi: $newStatus'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xatolik: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    final orderId = order['id'].toString();
    final shortId = orderId.substring(0, 8);
    final user = order['user'] ?? {};
    final userName = user['full_name'] ?? user['fullName'] ?? "${user['first_name'] ?? ''} ${user['last_name'] ?? ''}".trim();
    final userPhone = user['phone_number'] ?? user['phoneNumber'] ?? 'Noma\'lum';
    final address = order['delivery_address'] ?? 'Kiritilmagan';
    final payment = order['payment_method'] ?? 'Noma\'lum';
    final total = "${formatCurrency.format(order['total'] ?? 0)} UZS";
    final status = order['status'].toString().toUpperCase();

    showAdminFormModal(
      context: context,
      title: "Buyurtma #$shortId",
      icon: Icons.list_alt,
      builder: (modalContext, setModalState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Xaridor:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    Text(userName.isEmpty ? 'Noma\'lum Mijoz' : userName, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 12),
                    
                    Text("Telefon:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    Text(userPhone, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 12),
                    
                    Text("Manzil:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade600)),
                    const SizedBox(height: 4),
                    Text(address, style: const TextStyle(fontSize: 16)),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("To'lov turi:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade600)),
                              const SizedBox(height: 4),
                              Text(payment, style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Joriy holat:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade600)),
                              const SizedBox(height: 4),
                              _buildStatusBadge(status),
                            ],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    Text("Tovarlar:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.primary)),
                    const SizedBox(height: 8),
                    if (order['items'] != null && (order['items'] as List).isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: (order['items'] as List).map((item) {
                            final p = item['product'] ?? {};
                            final pName = p['name'] is Map ? (p['name']['uz'] ?? p['name']['en']) : p['name'];
                            final quantity = item['quantity'] ?? 1;
                            final price = item['price_at_time'] ?? 0;
                            return ListTile(
                              title: Text("$pName"),
                              subtitle: Text("$quantity ${p['unit'] ?? 'dona'} x ${formatCurrency.format(price)} UZS"),
                              trailing: Text("${formatCurrency.format(price * quantity)} UZS", style: const TextStyle(fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                        ),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text("Tovarlar topilmadi"),
                      ),
                    
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Jami:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), 
                          Text(total, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF10B981))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Actions
            Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(modalContext).viewInsets.bottom > 0 ? 12 : 24,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                border: const Border(top: BorderSide(color: Colors.white12)),
              ),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(modalContext),
                    child: const Text("Yopish"),
                  ),
                  if (status == 'PENDING')
                    ElevatedButton(
                      onPressed: () => _updateOrderStatus(modalContext, orderId, 'CONFIRMED', setModalState),
                      child: const Text("Tasdiqlash"),
                    ),
                  if (status == 'CONFIRMED')
                    ElevatedButton(
                      onPressed: () => _updateOrderStatus(modalContext, orderId, 'SHIPPING', setModalState),
                      child: const Text("Yetkazish"),
                    ),
                  if (status != 'DELIVERED' && status != 'CANCELLED')
                    ElevatedButton(
                      onPressed: () => _updateOrderStatus(modalContext, orderId, 'DELIVERED', setModalState),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                      child: const Text("Yetkazildi"),
                    ),
                  if (status != 'CANCELLED' && status != 'DELIVERED')
                    TextButton(
                      onPressed: () => _updateOrderStatus(modalContext, orderId, 'CANCELLED', setModalState),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text("Bekor qilish"),
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String text;

    switch (status.toUpperCase()) {
      case 'PENDING':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        text = 'Kutilmoqda';
        break;
      case 'CONFIRMED':
        bgColor = Colors.blue.shade100;
        textColor = Colors.blue.shade800;
        text = 'Tasdiqlangan';
        break;
      case 'SHIPPING':
        bgColor = Colors.purple.shade100;
        textColor = Colors.purple.shade800;
        text = 'Yetkazilmoqda';
        break;
      case 'DELIVERED':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        text = 'Yetkazildi';
        break;
      case 'CANCELLED':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        text = 'Bekor qilingan';
        break;
      default:
        bgColor = Colors.grey.shade200;
        textColor = Colors.grey.shade800;
        text = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 640;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            "Buyurtmalar",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFFFF7A00),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFFFF7A00),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
        Expanded(
          child: ordersAsync.when(
            data: (allOrders) {
              return TabBarView(
                controller: _tabController,
                children: _tabs.map((tab) {
                  return _buildOrdersList(context, tab, allOrders.cast<Map<String, dynamic>>(), isMobile);
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A00))),
            error: (err, stack) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text('Xatolik: $err'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(ordersProvider),
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

  Widget _buildOrdersList(BuildContext context, String tabStatus, List<Map<String, dynamic>> allOrders, bool isMobile) {
    String statusFilter = '';
    switch (tabStatus) {
      case 'Kutilmoqda': statusFilter = 'PENDING'; break;
      case 'Tasdiqlangan': statusFilter = 'CONFIRMED'; break;
      case 'Yetkazilmoqda': statusFilter = 'SHIPPING'; break;
      case 'Yetkazildi': statusFilter = 'DELIVERED'; break;
      case 'Bekor qilingan': statusFilter = 'CANCELLED'; break;
    }

    final filteredOrders = statusFilter.isEmpty 
        ? allOrders 
        : allOrders.where((o) => o['status'].toString().toUpperCase() == statusFilter).toList();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text("Ushbu holatdagi buyurtmalar yo'q", style: TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      );
    }

    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          final shortId = order['id'].toString().substring(0, 8);
          final user = order['user'] ?? {};
          final userName = user['full_name'] ?? user['fullName'] ?? "${user['first_name'] ?? ''} ${user['last_name'] ?? ''}".trim();
          final userPhone = user['phone_number'] ?? user['phoneNumber'] ?? '';
          final total = "${formatCurrency.format(order['total'] ?? 0)} UZS";
          final status = order['status'].toString();
          final dateStr = order['created_at'] != null ? DateFormat('dd.MM.yyyy, HH:mm').format(DateTime.parse(order['created_at'].toString())) : '';

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _showOrderDetails(context, order),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ORD-$shortId", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        _buildStatusBadge(status),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(userName.isEmpty ? 'Noma\'lum Mijoz' : userName),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.phone_outlined, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(userPhone.isEmpty ? '-' : userPhone),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text(dateStr, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Jami:", style: TextStyle(color: Colors.grey)),
                        Text(total, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF10B981))),
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
      padding: const EdgeInsets.all(24),
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
            columns: const [
              DataColumn(label: Text('Buyurtma ID', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Xaridor', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Sana', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Umumiy summa', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Holat', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Harakatlar', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: filteredOrders.map((order) {
              final shortId = order['id'].toString().substring(0, 8);
              final user = order['user'] ?? {};
              final userName = user['full_name'] ?? user['fullName'] ?? "${user['first_name'] ?? ''} ${user['last_name'] ?? ''}".trim();
              final total = "${formatCurrency.format(order['total'] ?? 0)} UZS";
              final status = order['status'].toString();
              final dateStr = order['created_at'] != null ? DateFormat('dd.MM.yyyy, HH:mm').format(DateTime.parse(order['created_at'].toString())) : '';

              return DataRow(
                cells: [
                  DataCell(Text("ORD-$shortId", style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(userName.isEmpty ? 'Noma\'lum' : userName)),
                  DataCell(Text(dateStr)),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        total,
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  DataCell(_buildStatusBadge(status)),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                      tooltip: "Ko'rish",
                      onPressed: () => _showOrderDetails(context, order),
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
}
