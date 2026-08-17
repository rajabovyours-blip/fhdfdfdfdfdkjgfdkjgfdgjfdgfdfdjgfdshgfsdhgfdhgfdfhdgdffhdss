import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/product.dart';
import '../data/product_repository.dart';

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  return repo.getProducts();
});
