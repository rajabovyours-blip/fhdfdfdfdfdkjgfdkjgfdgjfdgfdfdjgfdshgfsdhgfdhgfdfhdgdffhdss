import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/seller/presentation/providers/seller_dashboard_providers.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/core/utils/currency_formatter.dart';

class SellerDashboardScreen extends ConsumerWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(sellerDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.sellerDashboard),
      ),
      body: dashboardAsync.when(
        data: (dashboard) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.salesOverview,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold,),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        context.l10n.todaySales,
                        CurrencyFormatter.format(dashboard.todaySales, context),
                        Icons.trending_up,
                        context.colors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        context.l10n.totalSales,
                        CurrencyFormatter.format(dashboard.totalSales, context),
                        Icons.account_balance_wallet,
                        context.colors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  context.l10n.orderManagement,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold,),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        context.l10n.pending,
                        '${dashboard.pendingOrders}',
                        Icons.pending_actions,
                        context.colors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        context.l10n.completed,
                        '${dashboard.completedOrders}',
                        Icons.check_circle,
                        context.colors.success,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        context.l10n.cancelled,
                        '${dashboard.cancelledOrders}',
                        Icons.cancel,
                        context.colors.danger,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  context.l10n.inventoryStatus,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold,),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        context.l10n.lowStock,
                        '${dashboard.lowStockProducts}',
                        Icons.warning_amber,
                        context.colors.secondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        context.l10n.outOfStock,
                        '${dashboard.outOfStockProducts}',
                        Icons.inventory_2_outlined,
                        context.colors.danger,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        'Store Rating',
                        '${dashboard.storeRating}/5.0',
                        Icons.star,
                        context.colors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: context.colors.textMedium),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
