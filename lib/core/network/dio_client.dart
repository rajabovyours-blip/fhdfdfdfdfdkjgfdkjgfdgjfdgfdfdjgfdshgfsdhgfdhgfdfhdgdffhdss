import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:milliy_metr/core/network/interceptors/auth_interceptor.dart';
import 'package:milliy_metr/core/network/interceptors/logging_interceptor.dart';
import 'package:milliy_metr/core/network/interceptors/language_interceptor.dart';
import 'package:milliy_metr/core/constants/api_constants.dart';


class DioClient {
  final Dio _dio;

  DioClient() : _dio = Dio() {
    _dio.options
      ..baseUrl = (dotenv.isInitialized ? dotenv.env['API_BASE_URL'] : null) ?? ApiConstants.baseUrl
      ..connectTimeout = const Duration(seconds: 15)
      ..receiveTimeout = const Duration(seconds: 15)
      ..responseType = ResponseType.json
      ..headers = {'Bypass-Tunnel-Reminder': 'true'};

    _dio.interceptors.addAll([

      AuthInterceptor(),
      LanguageInterceptor(),
      LoggingInterceptor(),
    ]);
  }

  Dio get dio => _dio;
}
