with open('categories_list.txt', 'r', encoding='utf-16le') as f:
    lines = f.readlines()

dart_code = '''import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoriesNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  CategoriesNotifier() : super(_initialCategories);

  void addCategory(Map<String, dynamic> category) {
    state = [...state, category];
  }

  void updateCategory(Map<String, dynamic> category) {
    state = [
      for (final cat in state)
        if (cat['id'] == category['id']) category else cat
    ];
  }

  void deleteCategory(String id) {
    state = state.where((cat) => cat['id'] != id).toList();
  }

  static final List<Map<String, dynamic>> _initialCategories = [
'''

for line in lines:
    if not line.strip(): continue
    parts = line.strip().split('|')
    if len(parts) == 2:
        cat_id, name = parts
        name = name.replace("'", "\\'")
        dart_code += f"    {{'id': '{cat_id}', 'name': '{name}', 'image_url': 'assets/images/categories/{cat_id}.webp'}},\n"

dart_code += '''  ];
}

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<Map<String, dynamic>>>((ref) {
  return CategoriesNotifier();
});
'''

with open('admin_categories_provider.dart', 'w', encoding='utf-8') as f:
    f.write(dart_code)
