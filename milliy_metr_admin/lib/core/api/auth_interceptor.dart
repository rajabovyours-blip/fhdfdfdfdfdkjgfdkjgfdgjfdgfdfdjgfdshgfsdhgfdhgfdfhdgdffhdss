import 'package:dio/dio.dart';
import '../../../main.dart'; // To access sharedPrefs

class AuthInterceptor extends Interceptor {
  AuthInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = sharedPrefs.getString('admin_token');
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Let errors pass through for the UI to handle, but could also trigger global logout on 401
    handler.next(err);
  }
}
