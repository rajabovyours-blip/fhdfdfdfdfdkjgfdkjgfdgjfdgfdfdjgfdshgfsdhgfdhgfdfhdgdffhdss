import 'package:dio/dio.dart';
import 'package:milliy_metr/core/storage/preferences.dart';

class LanguageInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Default to 'uz' if not set
    final lang = PreferencesManager.getLanguage();
    options.headers['Accept-Language'] = lang;
    super.onRequest(options, handler);
  }
}
