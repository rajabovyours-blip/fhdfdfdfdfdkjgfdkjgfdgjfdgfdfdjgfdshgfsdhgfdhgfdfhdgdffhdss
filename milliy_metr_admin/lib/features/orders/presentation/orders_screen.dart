import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrdersScreen extends ConsumerStatefulWidget {
  const OrdersScreen({super.key});

  @override
  ConsumerState<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends ConsumerState<OrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
  }

  void _showOrderDetails(BuildContext context, String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Buyurtma tafsilotlari - $orderId"),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Xaridor: Alisher Usmonov", style: TextStyle(fontWeight: FontWeight.bold)),
                const Text("Telefon: +998 90 843 13 37"),
                const SizedBox(height: 16),
                const Text("Manzil: Toshkent sh., Chilonzor tumani, 1-mavze, 14-uy", style: TextStyle(fontWeight: FontWeight.bold)),
                const Text("To'lov turi: Naqd", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                const Text("Tovarlar:"),
                const ListTile(title: Text("G'isht - 1000 dona"), trailing: Text("1,000,000 UZS")),
                const ListTile(title: Text("Sement (50kg) - 10 qop"), trailing: Text("450,000 UZS")),
                const Divider(),
                const ListTile(title: Text("Jami:", style: TextStyle(fontWeight: FontWeight.bold)), trailing: Text("1,450,000 UZS", style: TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Yopish")),
          ElevatedButton(onPressed: () {}, child: const Text("Tasdiqlash")),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
            child: const Text("Yetkazildi"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          child: TabBarView(
            controller: _tabController,
            children: _tabs.map((tab) {
              return _buildOrdersList(context, tab);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList(BuildContext context, String status) {
    // Mock data
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFFFF7A00).withOpacity(0.1),
              child: const Icon(Icons.shopping_bag, color: Color(0xFFFF7A00)),
            ),
            title: Text("Buyurtma #${12001 + index}", style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                const Text("Alisher Usmonov • +998 90 843 13 37"),
                const SizedBox(height: 4),
                Text("Holat: $status", style: const TextStyle(color: Colors.grey)),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("1,450,000 UZS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text("Bugun, 10:30", style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
            onTap: () => _showOrderDetails(context, "#${12001 + index}"),
          ),
        );
      },
    );
  }
}
