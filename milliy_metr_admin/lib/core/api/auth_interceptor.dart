import 'package:dio/dio.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Authentication is disabled for the admin panel.
    // No Authorization token is attached to prevent 401/403 errors.
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Let errors pass through for the UI to handle
    handler.next(err);
  }
}
