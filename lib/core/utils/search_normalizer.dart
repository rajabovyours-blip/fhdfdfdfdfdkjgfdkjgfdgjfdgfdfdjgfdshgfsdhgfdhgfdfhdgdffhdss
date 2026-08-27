class SearchNormalizer {
  static String normalizeSearch(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r"['`’‘ʻʼ]"), '')
        .trim();
  }
}
