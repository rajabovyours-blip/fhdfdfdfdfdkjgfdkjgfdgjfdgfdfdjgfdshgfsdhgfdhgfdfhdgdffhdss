import 'package:flutter_test/flutter_test.dart';
import 'package:milliy_metr/core/mock/demo_data.dart';
import 'package:milliy_metr/features/products/data/models/product_model.dart';

void main() {
  test('ProductModel fromJson with MockInterceptor mapping', () {
    final map = DemoData.products.first;
    
    // Exact mapping used in MockInterceptor
    final mapped = {
      ...map,
      'price': (map['price'] ?? 0).toDouble(),
      'oldPrice': map['old_price'] != null ? (map['old_price'] as num).toDouble() : null,
      'currency': 'UZS',
      'unit': map['unit'] ?? 'dona',
      'moq': 1,
      'stock': map['stockCount'] ?? 100,
      'stockStatus': 'in_stock',
      'rating': (map['rating'] ?? 0).toDouble(),
      'reviewCount': map['reviewCount'] ?? 0,
      'location': 'Tashkent',
    };
    
    try {
      final model = ProductModel.fromJson(mapped);
      print('SUCCESS: ${model.id}');
    } catch (e, stack) {
      print('ERROR: $e\n$stack');
      rethrow;
    }
  });
}
