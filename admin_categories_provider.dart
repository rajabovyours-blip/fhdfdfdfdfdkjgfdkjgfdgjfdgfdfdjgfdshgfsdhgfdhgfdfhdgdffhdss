import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    {'id': '﻿cat-1', 'name': 'Bricks and Blocks', 'image_url': 'assets/images/categories/﻿cat-1.webp'},
    {'id': 'cat-2', 'name': 'Cement and Mixtures', 'image_url': 'assets/images/categories/cat-2.webp'},
    {'id': 'cat-3', 'name': 'Lumber', 'image_url': 'assets/images/categories/cat-3.webp'},
    {'id': 'cat-4', 'name': 'Rebar and Metal', 'image_url': 'assets/images/categories/cat-4.webp'},
    {'id': 'cat-5', 'name': 'Roofing Materials', 'image_url': 'assets/images/categories/cat-5.webp'},
    {'id': 'cat-6', 'name': 'Thermal Insulation', 'image_url': 'assets/images/categories/cat-6.webp'},
    {'id': 'cat-7', 'name': 'Paints and Varnishes', 'image_url': 'assets/images/categories/cat-7.webp'},
    {'id': 'cat-8', 'name': 'Plumbing', 'image_url': 'assets/images/categories/cat-8.webp'},
    {'id': 'cat-9', 'name': 'Electrical Equipment', 'image_url': 'assets/images/categories/cat-9.webp'},
    {'id': 'cat-10', 'name': 'Construction Tools', 'image_url': 'assets/images/categories/cat-10.webp'},
    {'id': 'cat-11', 'name': 'Sand and Gravel', 'image_url': 'assets/images/categories/cat-11.webp'},
    {'id': 'cat-12', 'name': 'Drywall and Profiles', 'image_url': 'assets/images/categories/cat-12.webp'},
    {'id': 'cat-13', 'name': 'Tiles and Ceramics', 'image_url': 'assets/images/categories/cat-13.webp'},
    {'id': 'cat-14', 'name': 'Doors and Windows', 'image_url': 'assets/images/categories/cat-14.webp'},
    {'id': 'cat-15', 'name': 'Locks and Hardware', 'image_url': 'assets/images/categories/cat-15.webp'},
    {'id': 'cat-16', 'name': 'Floor Coverings', 'image_url': 'assets/images/categories/cat-16.webp'},
    {'id': 'cat-17', 'name': 'Waterproofing', 'image_url': 'assets/images/categories/cat-17.webp'},
    {'id': 'cat-18', 'name': 'Glass and Mirrors', 'image_url': 'assets/images/categories/cat-18.webp'},
    {'id': 'cat-19', 'name': 'Construction Adhesives', 'image_url': 'assets/images/categories/cat-19.webp'},
    {'id': 'cat-20', 'name': 'Mounting Foam', 'image_url': 'assets/images/categories/cat-20.webp'},
    {'id': 'cat-21', 'name': 'Water Pipes', 'image_url': 'assets/images/categories/cat-21.webp'},
    {'id': 'cat-22', 'name': 'Sewage Systems', 'image_url': 'assets/images/categories/cat-22.webp'},
    {'id': 'cat-23', 'name': 'Heating Systems', 'image_url': 'assets/images/categories/cat-23.webp'},
    {'id': 'cat-24', 'name': 'Ventilation', 'image_url': 'assets/images/categories/cat-24.webp'},
    {'id': 'cat-25', 'name': 'Lighting Fixtures', 'image_url': 'assets/images/categories/cat-25.webp'},
    {'id': 'cat-26', 'name': 'Cables and Wires', 'image_url': 'assets/images/categories/cat-26.webp'},
    {'id': 'cat-27', 'name': 'Sockets and Switches', 'image_url': 'assets/images/categories/cat-27.webp'},
    {'id': 'cat-28', 'name': 'Circuit Breakers and Panels', 'image_url': 'assets/images/categories/cat-28.webp'},
    {'id': 'cat-29', 'name': 'Rotary Hammers', 'image_url': 'assets/images/categories/cat-29.webp'},
    {'id': 'cat-30', 'name': 'Angle Grinders', 'image_url': 'assets/images/categories/cat-30.webp'},
    {'id': 'cat-31', 'name': 'Drills and Screwdrivers', 'image_url': 'assets/images/categories/cat-31.webp'},
    {'id': 'cat-32', 'name': 'Laser Levels', 'image_url': 'assets/images/categories/cat-32.webp'},
    {'id': 'cat-33', 'name': 'Measuring Tools', 'image_url': 'assets/images/categories/cat-33.webp'},
    {'id': 'cat-34', 'name': 'Hand Tools', 'image_url': 'assets/images/categories/cat-34.webp'},
    {'id': 'cat-35', 'name': 'Hammers', 'image_url': 'assets/images/categories/cat-35.webp'},
    {'id': 'cat-36', 'name': 'Screwdrivers', 'image_url': 'assets/images/categories/cat-36.webp'},
    {'id': 'cat-37', 'name': 'Pliers and Tongs', 'image_url': 'assets/images/categories/cat-37.webp'},
    {'id': 'cat-38', 'name': 'Spatulas and Trowels', 'image_url': 'assets/images/categories/cat-38.webp'},
    {'id': 'cat-39', 'name': 'Construction Buckets', 'image_url': 'assets/images/categories/cat-39.webp'},
    {'id': 'cat-40', 'name': 'Ladders', 'image_url': 'assets/images/categories/cat-40.webp'},
    {'id': 'cat-41', 'name': 'Saws and Cutting', 'image_url': 'assets/images/categories/cat-41.webp'},
    {'id': 'cat-42', 'name': 'Sandpaper', 'image_url': 'assets/images/categories/cat-42.webp'},
    {'id': 'cat-43', 'name': 'Construction Helmets', 'image_url': 'assets/images/categories/cat-43.webp'},
    {'id': 'cat-44', 'name': 'Work Gloves', 'image_url': 'assets/images/categories/cat-44.webp'},
    {'id': 'cat-45', 'name': 'Safety Shoes', 'image_url': 'assets/images/categories/cat-45.webp'},
    {'id': 'cat-46', 'name': 'Safety Glasses', 'image_url': 'assets/images/categories/cat-46.webp'},
    {'id': 'cat-47', 'name': 'Liquid Nails', 'image_url': 'assets/images/categories/cat-47.webp'},
    {'id': 'cat-48', 'name': 'Sealants', 'image_url': 'assets/images/categories/cat-48.webp'},
    {'id': 'cat-49', 'name': 'Construction Tape', 'image_url': 'assets/images/categories/cat-49.webp'},
    {'id': 'cat-50', 'name': 'Dowels and Screws', 'image_url': 'assets/images/categories/cat-50.webp'},
    {'id': 'cat-51', 'name': 'Nails', 'image_url': 'assets/images/categories/cat-51.webp'},
    {'id': 'cat-52', 'name': 'Bolts and Nuts', 'image_url': 'assets/images/categories/cat-52.webp'},
    {'id': 'cat-53', 'name': 'Chains and Cables', 'image_url': 'assets/images/categories/cat-53.webp'},
    {'id': 'cat-54', 'name': 'Construction Nets', 'image_url': 'assets/images/categories/cat-54.webp'},
    {'id': 'cat-55', 'name': 'Polyethylene Films', 'image_url': 'assets/images/categories/cat-55.webp'},
    {'id': 'cat-56', 'name': 'Scales', 'image_url': 'assets/images/categories/cat-56.webp'},
    {'id': 'cat-57', 'name': 'Wheelbarrows', 'image_url': 'assets/images/categories/cat-57.webp'},
    {'id': 'cat-58', 'name': 'Cement Mixers', 'image_url': 'assets/images/categories/cat-58.webp'},
    {'id': 'cat-59', 'name': 'Welding Machines', 'image_url': 'assets/images/categories/cat-59.webp'},
    {'id': 'cat-60', 'name': 'Electrodes', 'image_url': 'assets/images/categories/cat-60.webp'},
    {'id': 'cat-61', 'name': 'Compressors', 'image_url': 'assets/images/categories/cat-61.webp'},
  ];
}

final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<Map<String, dynamic>>>((ref) {
  return CategoriesNotifier();
});
