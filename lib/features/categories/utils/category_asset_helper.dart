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

    // 2. If it's a UUID or doesn't have a valid number, hash it deterministically to 1-61
    final inputString = slug != null && slug.isNotEmpty ? slug : categoryId;
    final bytes = utf8.encode(inputString);
    final digest = sha256.convert(bytes);
    
    // Use the first 4 bytes of the hash to create an integer
    int hashInt = 0;
    for (int i = 0; i < 4; i++) {
      hashInt = (hashInt << 8) + digest.bytes[i];
    }
    
    // Map to 1-61
    final index = (hashInt.abs() % 61) + 1;
    return 'assets/images/categories/cat-$index.webp';
  }
}
