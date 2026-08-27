class SearchNormalizer {
  static const Map<String, String> _synonyms = {
    'kraska': "bo'yoq",
    'sement': 'cement',
    'oboy': "gulqog'oz",
    'gipsokarton': 'gips karton',
    'shpatlevka': 'shpaklyovka',
    'shurup': 'vint',
    'kley': 'yelim',
    'truba': 'quvur',
    'armatura': 'temir',
  };

  static String normalizeSearch(String input) {
    String normalized = input
        .toLowerCase()
        .replaceAll(RegExp(r"['’‘ʻʼ]"), '')
        .trim();
        
    // Check if it's a known synonym
    _synonyms.forEach((key, value) {
      if (normalized.contains(key)) {
        normalized = normalized.replaceAll(key, value);
      }
    });

    return normalized;
  }
}
