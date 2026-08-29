import 'package:dio/dio.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';
import 'package:milliy_metr/core/errors/failures.dart';

class DioErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message = 'Kutilmagan xatolik yuz berdi.';
    
    if (err.type == DioExceptionType.connectionTimeout || 
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      message = 'Internetga ulanish vaqti tugadi.';
    } else if (err.type == DioExceptionType.connectionError) {
      message = 'Internetga ulanib bo\'lmadi. Tarmoqni tekshiring.';
    } else if (err.response != null) {
      message = extractErrorMessage(err.response?.data);
    } else {
      message = extractErrorMessage(err.message);
    }

    // Pass a new DioException that wraps our ServerException
    final customErr = DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: ServerException(message),
      message: message,
    );
    
    super.onError(customErr, handler);
  }
}
