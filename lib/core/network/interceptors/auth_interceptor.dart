import 'package:dio/dio.dart';
import 'package:milliy_metr/core/storage/secure_storage.dart';
import 'package:milliy_metr/core/constants/api_constants.dart';

class AuthInterceptor extends Interceptor {
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

            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newToken';

            final retryResponse = await dio.fetch(opts);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          await SecureStorage.clearAll();
          // Dispatch session expired event if possible, handled by UI/State
        }
      }
      await SecureStorage.clearAll();
    }
    super.onError(err, handler);
  }
}
