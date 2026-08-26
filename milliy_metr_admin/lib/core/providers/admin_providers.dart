import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';

// ─── Users Provider ─────────────────────────────────────────────────────────
final usersProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/users/');
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
    final response = await dio.get('/products/');
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
    final response = await dio.get('/orders/');
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

// ─── Categories Provider (StateNotifier with local 61 defaults) ─────────
class CategoriesNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  CategoriesNotifier() : super(_initialCategories);

  void addCategory(Map<String, dynamic> category) {
    state = [...state, category];
  }

  void updateCategory(Map<String, dynamic> category) {
    state = [
      for (final cat in state)
        if (cat['id'] == category['id']) category else cat,
    ];
  }

  void deleteCategory(String id) {
    state = state.where((cat) => cat['id'] != id).toList();
  }

  static final List<Map<String, dynamic>> _initialCategories = [
    {"id": "cat-1", "name": "G'isht va Bloklar", "image_url": "assets/images/categories/cat-1.webp"},
    {"id": "cat-2", "name": "Sement va Qorishmalar", "image_url": "assets/images/categories/cat-2.webp"},
    {"id": "cat-3", "name": "Taxta va Yog'och", "image_url": "assets/images/categories/cat-3.webp"},
    {"id": "cat-4", "name": "Armatura va Metall", "image_url": "assets/images/categories/cat-4.webp"},
    {"id": "cat-5", "name": "Tom yopish materiallari", "image_url": "assets/images/categories/cat-5.webp"},
    {"id": "cat-6", "name": "Issiqlik izolyatsiyasi", "image_url": "assets/images/categories/cat-6.webp"},
    {"id": "cat-7", "name": "Bo'yoqlar va Laklar", "image_url": "assets/images/categories/cat-7.webp"},
    {"id": "cat-8", "name": "Santexnika", "image_url": "assets/images/categories/cat-8.webp"},
    {"id": "cat-9", "name": "Elektr uskunalari", "image_url": "assets/images/categories/cat-9.webp"},
    {"id": "cat-10", "name": "Qurilish asboblari", "image_url": "assets/images/categories/cat-10.webp"},
    {"id": "cat-11", "name": "Qum va Shag'al", "image_url": "assets/images/categories/cat-11.webp"},
    {"id": "cat-12", "name": "Gipsokarton va Profillar", "image_url": "assets/images/categories/cat-12.webp"},
    {"id": "cat-13", "name": "Kafel va Keramika", "image_url": "assets/images/categories/cat-13.webp"},
    {"id": "cat-14", "name": "Eshik va Derazalar", "image_url": "assets/images/categories/cat-14.webp"},
    {"id": "cat-15", "name": "Qulf va Furnituralar", "image_url": "assets/images/categories/cat-15.webp"},
    {"id": "cat-16", "name": "Poydevor qoplamalari", "image_url": "assets/images/categories/cat-16.webp"},
    {"id": "cat-17", "name": "Gidroizolyatsiya", "image_url": "assets/images/categories/cat-17.webp"},
    {"id": "cat-18", "name": "Oyna va Ko'zgular", "image_url": "assets/images/categories/cat-18.webp"},
    {"id": "cat-19", "name": "Qurilish yelimlari", "image_url": "assets/images/categories/cat-19.webp"},
    {"id": "cat-20", "name": "Montaj ko'pigi", "image_url": "assets/images/categories/cat-20.webp"},
    {"id": "cat-21", "name": "Suv quvurlari", "image_url": "assets/images/categories/cat-21.webp"},
    {"id": "cat-22", "name": "Kanalizatsiya tizimlari", "image_url": "assets/images/categories/cat-22.webp"},
    {"id": "cat-23", "name": "Isitish tizimlari", "image_url": "assets/images/categories/cat-23.webp"},
    {"id": "cat-24", "name": "Ventilyatsiya", "image_url": "assets/images/categories/cat-24.webp"},
    {"id": "cat-25", "name": "Yoritish moslamalari", "image_url": "assets/images/categories/cat-25.webp"},
    {"id": "cat-26", "name": "Kabel va Simlar", "image_url": "assets/images/categories/cat-26.webp"},
    {"id": "cat-27", "name": "Rozetka va Viklyuchatellar", "image_url": "assets/images/categories/cat-27.webp"},
    {"id": "cat-28", "name": "Avtomatlar va Shitlar", "image_url": "assets/images/categories/cat-28.webp"},
    {"id": "cat-29", "name": "Perforatorlar", "image_url": "assets/images/categories/cat-29.webp"},
    {"id": "cat-30", "name": "Bolgarkalar", "image_url": "assets/images/categories/cat-30.webp"},
    {"id": "cat-31", "name": "Drel va Shurupovyortlar", "image_url": "assets/images/categories/cat-31.webp"},
    {"id": "cat-32", "name": "Lazerli sathlar", "image_url": "assets/images/categories/cat-32.webp"},
    {"id": "cat-33", "name": "O'lchov asboblari", "image_url": "assets/images/categories/cat-33.webp"},
    {"id": "cat-34", "name": "Qo'l asboblari", "image_url": "assets/images/categories/cat-34.webp"},
    {"id": "cat-35", "name": "Bolg'alar", "image_url": "assets/images/categories/cat-35.webp"},
    {"id": "cat-36", "name": "Otvyortkalar", "image_url": "assets/images/categories/cat-36.webp"},
    {"id": "cat-37", "name": "Ombirlar", "image_url": "assets/images/categories/cat-37.webp"},
    {"id": "cat-38", "name": "Shpatel va Kelmalar", "image_url": "assets/images/categories/cat-38.webp"},
    {"id": "cat-39", "name": "Qurilish chelaklari", "image_url": "assets/images/categories/cat-39.webp"},
    {"id": "cat-40", "name": "Narvonlar", "image_url": "assets/images/categories/cat-40.webp"},
    {"id": "cat-41", "name": "Arra va Kesuvchi asboblar", "image_url": "assets/images/categories/cat-41.webp"},
    {"id": "cat-42", "name": "Qumqog'oz (Shkurka)", "image_url": "assets/images/categories/cat-42.webp"},
    {"id": "cat-43", "name": "Qurilish kaskalari", "image_url": "assets/images/categories/cat-43.webp"},
    {"id": "cat-44", "name": "Qo'lqoplar", "image_url": "assets/images/categories/cat-44.webp"},
    {"id": "cat-45", "name": "Maxsus poyabzallar", "image_url": "assets/images/categories/cat-45.webp"},
    {"id": "cat-46", "name": "Himoya ko'zoynaklari", "image_url": "assets/images/categories/cat-46.webp"},
    {"id": "cat-47", "name": "Suyuq mixlar", "image_url": "assets/images/categories/cat-47.webp"},
    {"id": "cat-48", "name": "Germetiklar", "image_url": "assets/images/categories/cat-48.webp"},
    {"id": "cat-49", "name": "Qurilish skotchi", "image_url": "assets/images/categories/cat-49.webp"},
    {"id": "cat-50", "name": "Dyubel va Samorezlar", "image_url": "assets/images/categories/cat-50.webp"},
    {"id": "cat-51", "name": "Mixlar", "image_url": "assets/images/categories/cat-51.webp"},
    {"id": "cat-52", "name": "Bolt va Gaykalar", "image_url": "assets/images/categories/cat-52.webp"},
    {"id": "cat-53", "name": "Zanjir va Troslar", "image_url": "assets/images/categories/cat-53.webp"},
    {"id": "cat-54", "name": "Qurilish to'rlari", "image_url": "assets/images/categories/cat-54.webp"},
    {"id": "cat-55", "name": "Polietilen plyonkalar", "image_url": "assets/images/categories/cat-55.webp"},
    {"id": "cat-56", "name": "Tarozilar", "image_url": "assets/images/categories/cat-56.webp"},
    {"id": "cat-57", "name": "Zambilg'achlar (Tachkalar)", "image_url": "assets/images/categories/cat-57.webp"},
    {"id": "cat-58", "name": "Beton qorishtirgichlar", "image_url": "assets/images/categories/cat-58.webp"},
    {"id": "cat-59", "name": "Svarka apparatlari", "image_url": "assets/images/categories/cat-59.webp"},
    {"id": "cat-60", "name": "Elektrodlar", "image_url": "assets/images/categories/cat-60.webp"},
    {"id": "cat-61", "name": "Kompressorlar", "image_url": "assets/images/categories/cat-61.webp"},
  ];
}

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<Map<String, dynamic>>>((ref) {
  return CategoriesNotifier();
});

// ─── Banners Provider ───────────────────────────────────────────────────────
final bannersProvider = FutureProvider<List<dynamic>>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final response = await dio.get('/banners/');
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
    final response = await dio.get('/reviews/');
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
    return data as Map<String, dynamic>;
  } catch (_) {
    return {};
  }
});
