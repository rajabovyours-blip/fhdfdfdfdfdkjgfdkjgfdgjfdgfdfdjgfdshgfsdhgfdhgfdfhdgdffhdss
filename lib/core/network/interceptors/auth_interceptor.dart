import 'package:dio/dio.dart';
import 'package:milliy_metr/core/storage/secure_storage.dart';
import 'package:milliy_metr/core/constants/api_constants.dart';
import 'package:milliy_metr/core/events/auth_events.dart';

class AuthInterceptor extends Interceptor {
  bool _isRefreshing = false;
  final List<Map<String, dynamic>> _failedRequests = [];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await SecureStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken != null) {
        if (!_isRefreshing) {
          _isRefreshing = true;
          try {
            final dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
            final response = await dio.post(
              '/auth/refresh',
              data: {
                'refresh_token': refreshToken,
              },
            );

            if (response.statusCode == 200) {
              final newToken = response.data['access_token'];
              final newRefresh = response.data['refresh_token'];

              await SecureStorage.saveToken(newToken);
              if (newRefresh != null) {
                await SecureStorage.saveRefreshToken(newRefresh);
              }

              _isRefreshing = false;
              
              // Retry current request
              err.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              handler.resolve(await dio.fetch(err.requestOptions));

              // Retry queued requests
              for (var requestInfo in _failedRequests) {
                final options = requestInfo['options'] as RequestOptions;
                final requestHandler = requestInfo['handler'] as ErrorInterceptorHandler;
                options.headers['Authorization'] = 'Bearer $newToken';
                try {
                  final retryResponse = await dio.fetch(options);
                  requestHandler.resolve(retryResponse);
                } on DioException catch (retryError) {
                  requestHandler.reject(retryError);
                }
              }
              _failedRequests.clear();
              return;
            }
          } catch (e) {
            _isRefreshing = false;
            _failedRequests.clear();
            await SecureStorage.clearAll();
            AuthEventBus.emit(SessionExpiredEvent());
          }
        } else {
          // Queue the request
          _failedRequests.add({'options': err.requestOptions, 'handler': handler});
          return;
        }
      }
      
      await SecureStorage.clearAll();
      AuthEventBus.emit(SessionExpiredEvent());
    }
    super.onError(err, handler);
  }
}
