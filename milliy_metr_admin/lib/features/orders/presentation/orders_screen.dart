import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/providers/admin_providers.dart';
import '../../../core/api/api_client.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final formatCurrency = NumberFormat.currency(locale: 'uz_UZ', symbol: 'UZS', decimalDigits: 0);

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

  Future<void> _updateOrderStatus(BuildContext context, String id, String newStatus) async {
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
    final userName = user['full_name'] ?? "${user['first_name'] ?? ''} ${user['last_name'] ?? ''}".trim();
    final userPhone = user['phone_number'] ?? 'Noma\'lum';
    final address = order['delivery_address'] ?? 'Kiritilmagan';
    final payment = order['payment_method'] ?? 'Noma\'lum';
    final total = formatCurrency.format(order['total'] ?? 0);
    final status = order['status'].toString().toUpperCase();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Buyurtma tafsilotlari - #$shortId"),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Xaridor: ${userName.isEmpty ? 'Noma\'lum Mijoz' : userName}", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Telefon: $userPhone"),
                const SizedBox(height: 16),
                Text("Manzil: $address", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("To'lov turi: $payment", style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Joriy holat: $status", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                const SizedBox(height: 16),
                const Text("Tovarlar:"),
                // In a real app we'd map order['items'], but the endpoint might not return it fully or it might be empty
                if (order['items'] != null)
                  ...(order['items'] as List).map((item) {
                     final p = item['product'] ?? {};
                     final pName = p['name'] is Map ? (p['name']['uz'] ?? p['name']['en']) : p['name'];
                     return ListTile(
                       title: Text("$pName - ${item['quantity']} ${p['unit'] ?? 'dona'}"),
                       trailing: Text(formatCurrency.format((item['price_at_time'] ?? 0) * (item['quantity'] ?? 1))),
                     );
                  }),
                const Divider(),
                ListTile(
                  title: const Text("Jami:", style: TextStyle(fontWeight: FontWeight.bold)), 
                  trailing: Text(total, style: const TextStyle(fontWeight: FontWeight.bold))
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Yopish")),
          if (status == 'PENDING')
            ElevatedButton(onPressed: () => _updateOrderStatus(context, orderId, 'CONFIRMED'), child: const Text("Tasdiqlash")),
          if (status == 'CONFIRMED')
            ElevatedButton(onPressed: () => _updateOrderStatus(context, orderId, 'SHIPPING'), child: const Text("Yetkazish")),
          if (status != 'DELIVERED' && status != 'CANCELLED')
            ElevatedButton(
              onPressed: () => _updateOrderStatus(context, orderId, 'DELIVERED'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              child: const Text("Yetkazildi"),
            ),
          if (status != 'CANCELLED' && status != 'DELIVERED')
            TextButton(
              onPressed: () => _updateOrderStatus(context, orderId, 'CANCELLED'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text("Bekor qilish"),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            "Buyurtmalar Konveyeri",
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
                  return _buildOrdersList(context, tab, allOrders.cast<Map<String, dynamic>>());
                }).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A00))),
            error: (err, stack) => Center(child: Text('Xatolik: $err')),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList(BuildContext context, String tabStatus, List<Map<String, dynamic>> allOrders) {
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
      return const Center(child: Text("Ushbu holatdagi buyurtmalar yo'q"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        final shortId = order['id'].toString().substring(0, 8);
        final user = order['user'] ?? {};
        final userName = user['full_name'] ?? "${user['first_name'] ?? ''} ${user['last_name'] ?? ''}".trim();
        final userPhone = user['phone_number'] ?? '';
        final total = formatCurrency.format(order['total'] ?? 0);
        final status = order['status'].toString();
        final dateStr = order['created_at'] != null ? DateFormat('dd.MM.yyyy, HH:mm').format(DateTime.parse(order['created_at'].toString())) : '';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFFF7A00).withValues(alpha: 0.1),
              child: const Icon(Icons.shopping_bag, color: Color(0xFFFF7A00)),
            ),
            title: Text("Buyurtma #$shortId", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text("${userName.isEmpty ? 'Mijoz' : userName} ${userPhone.isNotEmpty ? '• $userPhone' : ''}"),
                const SizedBox(height: 4),
                Text("Holat: $status", style: const TextStyle(color: Colors.grey)),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(total, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(dateStr, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            onTap: () => _showOrderDetails(context, order),
          ),
        );
      },
    );
  }
}
