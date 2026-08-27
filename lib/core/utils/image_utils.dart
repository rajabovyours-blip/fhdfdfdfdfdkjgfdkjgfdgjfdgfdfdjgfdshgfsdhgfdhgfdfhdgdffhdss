class ImageUtils {
  static String getFullImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return '';
    if (rawUrl.startsWith('assets/')) return rawUrl;
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) return rawUrl;
    if (rawUrl.startsWith('/uploads/')) {
      return 'https://milliymetr-backend.onrender.com$rawUrl';
    }
    if (rawUrl.startsWith('uploads/')) {
      return 'https://milliymetr-backend.onrender.com/$rawUrl';
    }
    return rawUrl;
  }
}
