import 'dart:convert';
import 'package:crypto/crypto.dart';

class CategoryAssetHelper {
  /// Returns a deterministic local asset path for a category.
  /// Assets must be named cat-1.webp through cat-61.webp.
  static String getAssetPath(String categoryId, String? slug) {
    // 1. Check if ID contains a number (e.g., 'cat-1' or '1')
    final numberMatch = RegExp(r'\d+').firstMatch(categoryId);
    if (numberMatch != null) {
      final number = int.tryParse(numberMatch.group(0)!);
      if (number != null && number >= 1 && number <= 61) {
        return 'assets/images/categories/cat-$number.webp';
      }
    }

    // 2. Semantic dictionary mapping
    final name = (slug ?? categoryId).toLowerCase();
    
    if (name.contains('brick') || name.contains('block') || name.contains("g'isht")) {
      return 'assets/images/categories/cat-1.webp';
    } else if (name.contains('cement') || name.contains('mortar') || name.contains('sement') || name.contains('qorishma')) {
      return 'assets/images/categories/cat-2.webp';
    } else if (name.contains('wood') || name.contains('timber') || name.contains('lumber') || name.contains('taxta') || name.contains("yog'och")) {
      return 'assets/images/categories/cat-3.webp';
    } else if (name.contains('rebar') || name.contains('steel') || name.contains('metal') || name.contains('armatura')) {
      return 'assets/images/categories/cat-4.webp';
    } else if (name.contains('roof') || name.contains('tom yopish')) {
      return 'assets/images/categories/cat-5.webp';
    } else if (name.contains('insulat') || name.contains('issiqlik izolyatsiyasi')) {
      return 'assets/images/categories/cat-6.webp';
    } else if (name.contains('paint') || name.contains('varnish') || name.contains("bo'yoq") || name.contains('lak')) {
      return 'assets/images/categories/cat-7.webp';
    } else if (name.contains('plumb') || name.contains('pipe') || name.contains('santexnika')) {
      return 'assets/images/categories/cat-8.webp';
    } else if (name.contains('electric') || name.contains('wire') || name.contains('elektr')) {
      return 'assets/images/categories/cat-9.webp';
    } else if (name.contains('tool') || name.contains('equipment') || name.contains('asbob') || name.contains('uskuna')) {
      return 'assets/images/categories/cat-10.webp';
    } else if (name.contains('sand') || name.contains('gravel') || name.contains('qum')) {
      return 'assets/images/categories/cat-11.webp';
    } else if (name.contains('drywall') || name.contains('gypsum')) {
      return 'assets/images/categories/cat-12.webp';
    } else if (name.contains('tile') || name.contains('ceramic') || name.contains('kafel') || name.contains('keramika')) {
      return 'assets/images/categories/cat-13.webp';
    } else if (name.contains('door') || name.contains('window') || name.contains('eshik') || name.contains('deraza')) {
      return 'assets/images/categories/cat-14.webp';
    } else if (name.contains('lock') || name.contains('hardware') || name.contains('qulf')) {
      return 'assets/images/categories/cat-15.webp';
    } else if (name.contains('floor') || name.contains('laminate') || name.contains('pol')) {
      return 'assets/images/categories/cat-16.webp';
    } else if (name.contains('waterproof') || name.contains('gidroizolyatsiya')) {
      return 'assets/images/categories/cat-17.webp';
    } else if (name.contains('glass') || name.contains('mirror') || name.contains('oyna') || name.contains('shisha')) {
      return 'assets/images/categories/cat-18.webp';
    } else if (name.contains('adhesive') || name.contains('glue') || name.contains('yelim') || name.contains('kley')) {
      return 'assets/images/categories/cat-19.webp';
    } else if (name.contains('fasten') || name.contains('nail') || name.contains('screw') || name.contains('bolt') || name.contains('mix') || name.contains('shurup')) {
      return 'assets/images/categories/cat-20.webp';
    }

    // 3. Fallback: Hash deterministically to 21-61
    final inputString = slug != null && slug.isNotEmpty ? slug : categoryId;
    final bytes = utf8.encode(inputString);
    final digest = sha256.convert(bytes);
    
    int hashInt = 0;
    for (int i = 0; i < 4; i++) {
      hashInt = (hashInt << 8) + digest.bytes[i];
    }
    
    final index = (hashInt.abs() % 41) + 21; // Maps to 21-61 to avoid overriding first 20 semantic categories
    return 'assets/images/categories/cat-$index.webp';
  }
}
