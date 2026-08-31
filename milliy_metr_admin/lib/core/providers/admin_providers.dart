import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';

// ─── Users Provider ─────────────────────────────────────────────────────────
final usersProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/users');
    final data = response.data;
    if (data is Map && data['data'] != null) {
      return data['data'] as List<dynamic>;
    }
    if (data is List) return data;
    return [];
  } catch (_) {
    return [];
  }
});

// ─── Products Provider ──────────────────────────────────────────────────────
final productsProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/products');
    final data = response.data;
    if (data is Map && data['data'] != null) {
      return data['data'] as List<dynamic>;
    }
    if (data is List) return data;
    return [];
  } catch (_) {
    return [];
  }
});

// ─── Orders Provider ────────────────────────────────────────────────────────
final ordersProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/orders');
    final data = response.data;
    if (data is Map && data['data'] != null) {
      return data['data'] as List<dynamic>;
    }
    if (data is List) return data;
    return [];
  } catch (_) {
    return [];
  }
});

// ─── Categories Provider ──────────────────────────────────────────────────────
final categoriesProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/categories');
    final data = response.data;
    if (data is Map && data['data'] != null) {
      return data['data'] as List<dynamic>;
    }
    if (data is List) return data;
    return [];
  } catch (_) {
    return [];
  }
});

// ─── Banners Provider ───────────────────────────────────────────────────────
final bannersProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/banners');
    final data = response.data;
    if (data is Map && data['data'] != null) {
      return data['data'] as List<dynamic>;
    }
    if (data is List) return data;
    return [];
  } catch (_) {
    return [];
  }
});

// ─── Reviews Provider ───────────────────────────────────────────────────────
final reviewsProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/reviews');
    final data = response.data;
    if (data is Map && data['data'] != null) {
      return data['data'] as List<dynamic>;
    }
    if (data is List) return data;
    return [];
  } catch (_) {
    return [];
  }
});

// ─── Analytics Provider ──────────────────────────────────────────────────────
final analyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/analytics/dashboard');
    final data = response.data;
    if (data is Map && data['data'] != null) {
      return data['data'] as Map<String, dynamic>;
    }
    if (data is Map) return data as Map<String, dynamic>;
    return _fallbackAnalytics;
  } catch (_) {
    return _fallbackAnalytics;
  }
});

const Map<String, dynamic> _fallbackAnalytics = {
  'total_revenue': 0,
  'today_orders_count': 0,
  'active_customers_count': 0,
  'total_products_count': 0,
  'monthly_sales': [],
  'order_status_distribution': [],
  'recent_orders': [],
};

