import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';

final usersProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/users/');
  return response.data as List<dynamic>;
});

final productsProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/products/');
  return response.data as List<dynamic>;
});

final categoriesProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  final response = await dio.get('/categories/');
  return response.data as List<dynamic>;
});

// Assuming endpoints for banners and reviews. If they fail, return empty list.
final bannersProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/banners/');
    return response.data as List<dynamic>;
  } catch (_) {
    return [];
  }
});

final reviewsProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/reviews/');
    return response.data as List<dynamic>;
  } catch (_) {
    return [];
  }
});
