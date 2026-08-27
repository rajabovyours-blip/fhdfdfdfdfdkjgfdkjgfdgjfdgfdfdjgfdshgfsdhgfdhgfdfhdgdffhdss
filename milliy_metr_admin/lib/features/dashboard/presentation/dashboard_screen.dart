import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/providers/admin_providers.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  final formatCurrency = NumberFormat.currency(locale: 'uz_UZ', symbol: 'UZS', decimalDigits: 0);
  
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 900;
    final analyticsAsync = ref.watch(analyticsProvider);

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),
          analyticsAsync.when(
            data: (data) {
              final totalRevenue = data['total_revenue'] ?? 0;
              final todayOrdersCount = data['today_orders_count'] ?? 0;
              final activeCustomersCount = data['active_customers_count'] ?? 0;
              final totalProductsCount = data['total_products_count'] ?? 0;
              final monthlySales = data['monthly_sales'] as List<dynamic>? ?? [];
              final statusDistribution = data['order_status_distribution'] as List<dynamic>? ?? [];
              final recentOrders = data['recent_orders'] as List<dynamic>? ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildKpiRow(context, isMobile, totalRevenue, todayOrdersCount, activeCustomersCount, totalProductsCount),
                  const SizedBox(height: 24),
                  if (isMobile)
                    Column(
                      children: [
                        _buildSalesChart(context, monthlySales),
                        const SizedBox(height: 24),
                        _buildOrdersPieChart(context, statusDistribution),
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildSalesChart(context, monthlySales)),
                        const SizedBox(width: 24),
                        Expanded(flex: 1, child: _buildOrdersPieChart(context, statusDistribution)),
                      ],
                    ),
                  const SizedBox(height: 24),
                  _buildRecentOrdersTable(context, recentOrders),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFFFF7A00))),
            error: (err, stack) => Center(child: Text('Xatolik: $err')),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow(BuildContext context, bool isMobile, num revenue, num orders, num customers, num products) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildKpiCard(context, 'Jami Tushum', formatCurrency.format(revenue), Icons.attach_money, isMobile),
        _buildKpiCard(context, 'Bugungi Buyurtmalar', '$orders ta', Icons.shopping_cart_outlined, isMobile),
        _buildKpiCard(context, 'Faol Mijozlar', '$customers ta', Icons.people_outline, isMobile),
        _buildKpiCard(context, 'Mahsulotlar', '$products ta', Icons.inventory_2_outlined, isMobile),
      ],
    );
  }

  Widget _buildKpiCard(BuildContext context, String title, String value, IconData icon, bool isMobile) {
    final width = isMobile ? double.infinity : (MediaQuery.of(context).size.width - 260 - 48 - 48) / 4;
    return Container(
      width: isMobile ? double.infinity : (width > 200 ? width : 200),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF7A00).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFFFF7A00), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart(BuildContext context, List<dynamic> monthlySales) {
    double maxRevenue = 100000;
    for (var m in monthlySales) {
      if ((m['revenue'] ?? 0) > maxRevenue) maxRevenue = (m['revenue'] as num).toDouble();
    }
    
    // Fallback if empty
    if (monthlySales.isEmpty) {
      monthlySales = [
        {"month": "Yan", "revenue": 0},
        {"month": "Fev", "revenue": 0},
        {"month": "Mar", "revenue": 0},
        {"month": "Apr", "revenue": 0},
        {"month": "May", "revenue": 0},
        {"month": "Iyun", "revenue": 0},
      ];
    }

    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Oylik Savdo Grafigi', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxRevenue * 1.2,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        formatCurrency.format(rod.toY),
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
                        int index = value.toInt();
                        if (index < 0 || index >= monthlySales.length) return const SizedBox.shrink();
                        return SideTitleWidget(meta: meta, space: 4, child: Text(monthlySales[index]['month'].toString(), style: style));
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(monthlySales.length, (index) {
                  final revenue = (monthlySales[index]['revenue'] as num).toDouble();
                  return BarChartGroupData(
                    x: index, 
                    barRods: [BarChartRodData(toY: revenue, color: const Color(0xFFFF7A00), width: 16, borderRadius: BorderRadius.circular(4))]
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersPieChart(BuildContext context, List<dynamic> statusDistribution) {
    if (statusDistribution.isEmpty) {
      return Container(
        height: 350,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey),
              SizedBox(height: 16),
              Text("Hozircha buyurtmalar yo'q", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }
    
    int total = statusDistribution.fold(0, (sum, item) => sum + ((item['count'] ?? 0) as int));
    
    Color getColor(String status) {
      switch (status.toUpperCase()) {
        case 'DELIVERED': return const Color(0xFF10B981);
        case 'CONFIRMED': return const Color(0xFF3B82F6);
        case 'PENDING': return const Color(0xFFF59E0B);
        case 'CANCELLED': return const Color(0xFFEF4444);
        case 'SHIPPING': return const Color(0xFF8B5CF6);
        default: return Colors.grey;
      }
    }

    return Container(
      height: 350,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Buyurtma holatlari', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 50,
                sections: statusDistribution.map((item) {
                  final status = item['status'].toString();
                  final count = (item['count'] as num).toInt();
                  final percentage = total > 0 ? (count / total * 100).toStringAsFixed(1) : '0';
                  
                  return PieChartSectionData(
                    value: count.toDouble(), 
                    color: getColor(status), 
                    title: '$percentage%', 
                    radius: 40, 
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: statusDistribution.map((item) {
              return _buildLegend(getColor(item['status'].toString()), item['status'].toString());
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildRecentOrdersTable(BuildContext context, List<dynamic> recentOrders) {
    if (recentOrders.isEmpty) {
       return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.outline),
        ),
        child: const Center(child: Text("So'nggi buyurtmalar yo'q")),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('So\'nggi Buyurtmalar', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: const [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Mijoz')),
                DataColumn(label: Text('Telefon')),
                DataColumn(label: Text('Sana')),
                DataColumn(label: Text('Summa')),
                DataColumn(label: Text('Holat')),
              ],
              rows: recentOrders.map((order) {
                final dateStr = order['created_at'] != null ? DateFormat('dd.MM.yyyy, HH:mm').format(DateTime.parse(order['created_at'].toString())) : '';
                return _buildOrderRow(
                  context, 
                  order['id'].toString().substring(0, 8), 
                  order['user_name'] ?? "Noma'lum", 
                  order['user_phone'] ?? "", 
                  dateStr, 
                  formatCurrency.format(order['total_amount'] ?? 0), 
                  order['status'].toString(), 
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildOrderRow(BuildContext context, String id, String customer, String phone, String date, String amount, String status) {
    Color statusColor;
    switch (status.toUpperCase()) {
      case 'DELIVERED': statusColor = const Color(0xFF10B981); break;
      case 'CONFIRMED': statusColor = const Color(0xFF3B82F6); break;
      case 'PENDING': statusColor = const Color(0xFFF59E0B); break;
      case 'CANCELLED': statusColor = const Color(0xFFEF4444); break;
      case 'SHIPPING': statusColor = const Color(0xFF8B5CF6); break;
      default: statusColor = Colors.grey;
    }
    
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(customer)),
        DataCell(Text(phone)),
        DataCell(Text(date, style: const TextStyle(color: Colors.grey))),
        DataCell(Text(amount)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
      ],
    );
  }
}
