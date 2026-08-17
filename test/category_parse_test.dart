import 'package:flutter_test/flutter_test.dart';
import 'package:milliy_metr/core/mock/demo_data.dart';
import 'package:milliy_metr/features/categories/data/models/category_model.dart';

void main() {
  test('CategoryModel fromJson', () {
    final map = DemoData.categories.first;
    try {
      final model = CategoryModel.fromJson(map);
      print('SUCCESS: ${model.id}');
    } catch (e, stack) {
      print('ERROR: $e\n$stack');
      rethrow;
    }
  });
}
