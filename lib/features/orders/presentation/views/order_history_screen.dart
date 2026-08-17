import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/features/orders/presentation/providers/order_notifier.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/core/utils/currency_formatter.dart';

class OrderHistoryScreen extends ConsumerStatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  ConsumerState<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends ConsumerState<OrderHistoryScreen> {
  final List<String> statuses = [
    'Pending',
    'Confirmed',
    'Packed',
    'Shipped',
    'Delivered',
    'Cancelled',
  ];
  String selectedStatus = 'All';
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.myOrders)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                labelText: context.l10n.searchOrders,
              ),
              onChanged: (value) => setState(() => searchText = value),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                'All',
                ...statuses,
              ].map((status) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(status),
                    selected: selectedStatus == status,
                    onSelected: (_) => setState(() => selectedStatus = status),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: state.maybeWhen(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e) => Center(child: Text(e.toString())),
              loaded: (orders) {
                final filtered = orders.where((order) {
                  final matchesStatus =
                      selectedStatus == 'All' || order.status == selectedStatus;
                  final matchesSearch = searchText.isEmpty ||
                      order.orderNumber
                          .toLowerCase()
                          .contains(searchText.toLowerCase());
                  return matchesStatus && matchesSearch;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(child: Text(context.l10n.noOrdersFound));
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = filtered[index];
                    return Card(
                      child: ListTile(
                        title: Text(
                          context.l10n.orderNumberLabel(order.orderNumber),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${context.l10n.status}: ${order.status}\n${context.l10n.total}: ${CurrencyFormatter.format(order.total, context)}',
                        ),
                        isThreeLine: true,
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(
                          AppRoutes.orderDetails.replaceFirst(':id', order.id),
                        ),
                      ),
                    );
                  },
                );
              },
              orElse: () => const Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
      ),
    );
  }
}
