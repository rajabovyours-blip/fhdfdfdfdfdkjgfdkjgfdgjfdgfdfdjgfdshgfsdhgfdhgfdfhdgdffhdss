import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationItem {
  final String title;
  final String body;

  const NotificationItem({required this.title, required this.body});
}

class NotificationsNotifier extends StateNotifier<List<NotificationItem>> {
  NotificationsNotifier()
      : super(const [
          NotificationItem(
            title: 'Order created',
            body: 'Your order has been received.',
          ),
          NotificationItem(
            title: 'Payment successful',
            body: 'Payment was approved successfully.',
          ),
          NotificationItem(
            title: 'Order shipped',
            body: 'Your order is on the way.',
          ),
        ]);

  void add(NotificationItem item) {
    state = [...state, item];
  }
}

final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, List<NotificationItem>>((ref) {
  return NotificationsNotifier();
});
