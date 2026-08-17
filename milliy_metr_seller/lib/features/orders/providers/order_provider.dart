import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/order.dart';
import '../data/order_repository.dart';

final ordersProvider = FutureProvider<List<Order>>((ref) async {
  final repo = ref.watch(orderRepositoryProvider);
  return repo.getOrders();
});
