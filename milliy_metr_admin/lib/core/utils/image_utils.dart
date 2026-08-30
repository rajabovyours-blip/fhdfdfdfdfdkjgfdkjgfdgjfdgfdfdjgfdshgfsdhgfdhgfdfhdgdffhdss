import 'package:milliy_metr_admin/core/config/app_config.dart';

class ImageUtils {
  static String getFullImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return '';
    if (rawUrl.startsWith('assets/')) return rawUrl;
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) return rawUrl;
    
    // Extract base URL without /api/v1
    final backendUrl = AppConfig.baseUrl.replaceAll('/api/v1', '');
    
    if (rawUrl.startsWith('/uploads/')) {
      return '$backendUrl$rawUrl';
    }
    if (rawUrl.startsWith('uploads/')) {
      return '$backendUrl/$rawUrl';
    }
    return rawUrl;
  }
}
