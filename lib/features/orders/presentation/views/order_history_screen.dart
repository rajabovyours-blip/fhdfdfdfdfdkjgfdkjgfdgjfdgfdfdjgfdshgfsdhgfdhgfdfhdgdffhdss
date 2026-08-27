import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/core/utils/search_normalizer.dart';
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
    'Processing',
    'Delivered',
    'Cancelled',
  ];
  String selectedStatus = 'All';
  String searchText = '';


  Widget _buildStatusBadge(String status, BuildContext context) {
    Color bgColor;
    Color fgColor;

    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = const Color(0xFFFFF7ED);
        fgColor = const Color(0xFFFF7A00);
        break;
      case 'confirmed':
        bgColor = const Color(0xFFEFF6FF);
        fgColor = const Color(0xFF2563EB);
        break;
      case 'processing':
        bgColor = const Color(0xFFFAF5FF);
        fgColor = const Color(0xFF9333EA);
        break;
      case 'delivered':
        bgColor = const Color(0xFFECFDF5);
        fgColor = const Color(0xFF10B981);
        break;
      case 'cancelled':
        bgColor = const Color(0xFFFEF2F2);
        fgColor = const Color(0xFFEF4444);
        break;
      default:
        bgColor = const Color(0xFFF3F4F6);
        fgColor = const Color(0xFF4B5563);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: fgColor.withOpacity(0.5)),
      ),
      child: Text(
        getLocalizedOrderStatus(status, context),
        style: TextStyle(
          color: fgColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showCancelDialog(BuildContext context, String orderId, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Buyurtmani bekor qilish"),
        content: const Text("Haqiqatan ham ushbu buyurtmani bekor qilmoqchimisiz?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Yo'q"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(orderNotifierProvider.notifier).cancelOrder(orderId);
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
            child: const Text("Ha, bekor qilish"),
          ),
        ],
      ),
    );
  }

  String getLocalizedOrderStatus(String status, BuildContext context) {
    switch (status.toLowerCase()) {
      case 'all': return context.l10n.orderStatusAll;
      case 'pending': return context.l10n.orderStatusPending;
      case 'confirmed': return context.l10n.orderStatusConfirmed;
      case 'processing': return context.l10n.orderStatusProcessing;
      case 'delivered': return context.l10n.orderStatusDelivered;
      case 'cancelled': return context.l10n.orderStatusCancelled;
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.myOrders)),
      body: Column(
        children: [
          Expanded(
            child: state.maybeWhen(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.wifi_off_rounded,
                          size: 64,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Ulanishda xatolik',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Tarmoqqa ulanishni tekshirib qayta urinib ko'ring.",
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 44,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => ref.read(orderNotifierProvider.notifier).loadOrders(),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Qayta urinish',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              loaded: (orders) {
                if (orders.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            context.l10n.noOrdersFound,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            height: 44,
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => context.go('/home'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                context.l10n.viewProducts,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final filtered = orders.where((order) {
                  final matchesStatus =
                      selectedStatus == 'All' || order.status == selectedStatus;
                  final matchesSearch = searchText.isEmpty ||
                      SearchNormalizer.normalizeSearch(order.orderNumber)
                          .contains(SearchNormalizer.normalizeSearch(searchText));
                  return matchesStatus && matchesSearch;
                }).toList();

                return Column(
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
                              label: Text(getLocalizedOrderStatus(status, context)),
                              selected: selectedStatus == status,
                              onSelected: (_) => setState(() => selectedStatus = status),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Expanded(
                      child: filtered.isEmpty
                          ? Center(
                              child: Text(
                                context.l10n.noOrdersFound,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : ListView.separated(
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
                                      '${context.l10n.status}: ${getLocalizedOrderStatus(order.status, context)}\n${context.l10n.total}: ${CurrencyFormatter.format(order.total, context)}',
                                    ),
                                    isThreeLine: true,
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () => context.push(
                                      AppRoutes.orderDetails.replaceFirst(':id', order.id),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
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
