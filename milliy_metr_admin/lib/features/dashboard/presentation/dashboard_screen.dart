import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return SingleChildScrollView(
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
          _buildKpiRow(context, isMobile),
          const SizedBox(height: 24),
          if (isMobile)
            Column(
              children: [
                _buildSalesChart(context),
                const SizedBox(height: 24),
                _buildOrdersPieChart(context),
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 2, child: _buildSalesChart(context)),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildOrdersPieChart(context)),
              ],
            ),
          const SizedBox(height: 24),
          _buildRecentOrdersTable(context),
        ],
      ),
    );
  }

  Widget _buildKpiRow(BuildContext context, bool isMobile) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        _buildKpiCard(context, 'Jami Tushum', '125,000,000 UZS', Icons.attach_money, isMobile),
        _buildKpiCard(context, 'Bugungi Buyurtmalar', '24', Icons.shopping_cart_outlined, isMobile),
        _buildKpiCard(context, 'Faol Mijozlar', '1,245', Icons.people_outline, isMobile),
        _buildKpiCard(context, 'Mahsulotlar', '864', Icons.inventory_2_outlined, isMobile),
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
              color: const Color(0xFFFF7A00).withOpacity(0.1),
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

  Widget _buildSalesChart(BuildContext context) {
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
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const style = TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12);
                        Widget text;
                        switch (value.toInt()) {
                          case 0: text = const Text('Yan', style: style); break;
                          case 1: text = const Text('Fev', style: style); break;
                          case 2: text = const Text('Mar', style: style); break;
                          case 3: text = const Text('Apr', style: style); break;
                          case 4: text = const Text('May', style: style); break;
                          case 5: text = const Text('Iyun', style: style); break;
                          default: text = const Text('', style: style); break;
                        }
                        return SideTitleWidget(meta: meta, space: 4, child: text);
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 80, color: const Color(0xFFFF7A00), width: 16, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 60, color: const Color(0xFFFF7A00), width: 16, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 40, color: const Color(0xFFFF7A00), width: 16, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 90, color: const Color(0xFFFF7A00), width: 16, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 70, color: const Color(0xFFFF7A00), width: 16, borderRadius: BorderRadius.circular(4))]),
                  BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 100, color: const Color(0xFFFF7A00), width: 16, borderRadius: BorderRadius.circular(4))]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersPieChart(BuildContext context) {
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
                sections: [
                  PieChartSectionData(value: 40, color: const Color(0xFF10B981), title: '40%', radius: 40, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  PieChartSectionData(value: 30, color: const Color(0xFF3B82F6), title: '30%', radius: 40, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  PieChartSectionData(value: 20, color: const Color(0xFFF59E0B), title: '20%', radius: 40, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                  PieChartSectionData(value: 10, color: const Color(0xFFEF4444), title: '10%', radius: 40, titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(const Color(0xFF10B981), 'Yetkazildi'),
              const SizedBox(width: 8),
              _buildLegend(const Color(0xFF3B82F6), 'Tasdiqlandi'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(const Color(0xFFF59E0B), 'Kutilmoqda'),
              const SizedBox(width: 8),
              _buildLegend(const Color(0xFFEF4444), 'Bekor qilingan'),
            ],
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

  Widget _buildRecentOrdersTable(BuildContext context) {
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
                DataColumn(label: Text('Sana')),
                DataColumn(label: Text('Summa')),
                DataColumn(label: Text('Holat')),
              ],
              rows: [
                _buildOrderRow(context, '#12001', 'Alisher Usmonov', 'Bugun, 10:30', '1,450,000 UZS', 'Yetkazildi', const Color(0xFF10B981)),
                _buildOrderRow(context, '#12002', 'Rustam Qosimov', 'Bugun, 09:15', '450,000 UZS', 'Tasdiqlandi', const Color(0xFF3B82F6)),
                _buildOrderRow(context, '#12003', 'Olimjon Tohirov', 'Bugun, 08:40', '12,000,000 UZS', 'Kutilmoqda', const Color(0xFFF59E0B)),
                _buildOrderRow(context, '#12004', 'Murod Nazarov', 'Kecha, 18:20', '340,000 UZS', 'Yetkazildi', const Color(0xFF10B981)),
                _buildOrderRow(context, '#12005', 'Aziz Rahimov', 'Kecha, 15:10', '8,900,000 UZS', 'Bekor qilingan', const Color(0xFFEF4444)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildOrderRow(BuildContext context, String id, String customer, String date, String amount, String status, Color statusColor) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(fontWeight: FontWeight.bold))),
        DataCell(Text(customer)),
        DataCell(Text(date, style: const TextStyle(color: Colors.grey))),
        DataCell(Text(amount)),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
      ],
    );
  }
}

