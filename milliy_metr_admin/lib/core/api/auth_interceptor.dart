import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Authentication is disabled for the admin panel. 
    // We do not attach any Authorization token to prevent 401 errors from invalid tokens.
    handler.next(options);
  }
}
