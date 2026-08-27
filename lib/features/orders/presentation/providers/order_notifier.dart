import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/state/feature_state.dart';
import 'package:milliy_metr/features/checkout/domain/entities/order_entity.dart';
import 'package:milliy_metr/features/orders/presentation/providers/order_providers.dart';

class OrderNotifier extends StateNotifier<FeatureState<List<OrderEntity>>> {
  final Ref _ref;

  OrderNotifier(this._ref) : super(const FeatureState.initial()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    state = const FeatureState.loading();
    final repository = _ref.read(orderRepositoryProvider);
    final result = await repository.getOrders();

    state = result.fold(
      (l) => FeatureState.error(l.message),
      (r) => FeatureState.loaded(r),
    );
  }

  Future<void> cancelOrder(String orderId) async {
    final repository = _ref.read(orderRepositoryProvider);
    final result = await repository.cancelOrder(orderId);
    
    if (result.isRight()) {
      // Optimistically update state
      state.maybeWhen(
        loaded: (orders) {
          final newOrders = List<OrderEntity>.from(orders);
          final index = newOrders.indexWhere((o) => o.id == orderId);
          if (index != -1) {
            // Can't directly update status easily if entity doesn't have copyWith, so let's just reload
          }
        },
        orElse: () {},
      );
      // Let's just reload orders after cancel
      await loadOrders();
    }
  }
}

final orderNotifierProvider =
    StateNotifierProvider<OrderNotifier, FeatureState<List<OrderEntity>>>(
        (ref) {
  return OrderNotifier(ref);
});

final orderDetailsProvider =
    FutureProvider.family<OrderEntity, String>((ref, id) async {
  final repository = ref.read(orderRepositoryProvider);
  final result = await repository.getOrderById(id);

  return result.fold(
    (l) => throw l.message,
    (r) => r,
  );
});
