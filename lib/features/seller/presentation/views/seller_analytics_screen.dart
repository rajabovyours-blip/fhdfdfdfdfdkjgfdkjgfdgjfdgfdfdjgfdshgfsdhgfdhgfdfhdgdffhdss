import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/seller/presentation/providers/seller_dashboard_providers.dart';

import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/core/utils/currency_formatter.dart';

class SellerAnalyticsScreen extends ConsumerWidget {
  const SellerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // backend endpoint documented: /seller/analytics (or reuse dashboard stats)
    final dashboardAsync = ref.watch(sellerDashboardProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.analyticsAndReports),
      ),
      body: dashboardAsync.when(
        data: (dashboard) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sales Performance',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildListTile(
                  'Today\'s Revenue',
                  CurrencyFormatter.format(dashboard.todaySales, context),
                ),
                _buildListTile(
                  'Total Revenue',
                  CurrencyFormatter.format(dashboard.totalSales, context),
                ),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Order Fulfillment',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildListTile('Pending Orders', '${dashboard.pendingOrders}'),
                _buildListTile(
                  'Completed Orders',
                  '${dashboard.completedOrders}',
                ),
                _buildListTile(
                  'Cancelled Orders',
                  '${dashboard.cancelledOrders}',
                ),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'More analytics charts will appear here when backend supports historical trend endpoints.',
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: context.colors.textMedium,
                  ),
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

  Widget _buildListTile(String title, String trailing) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: Text(
        trailing,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}
