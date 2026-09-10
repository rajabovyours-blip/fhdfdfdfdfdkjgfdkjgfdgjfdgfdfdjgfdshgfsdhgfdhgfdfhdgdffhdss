import 'package:dio/dio.dart';
import 'package:milliy_metr/core/errors/app_exception.dart';

abstract class ChatRemoteDataSource {
  Future<Map<String, dynamic>> startSession(String name, String phone);
  Future<List<dynamic>> getMessages(String sessionId);
  Future<Map<String, dynamic>> sendMessage(String sessionId, String text);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final Dio dio;

  ChatRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> startSession(String name, String phone) async {
    try {
      final response = await dio.post('/chat/start', data: {
        'name': name,
        'phone': phone,
      });
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }

  @override
  Future<List<dynamic>> getMessages(String sessionId) async {
    try {
      final response = await dio.get('/chat/$sessionId/messages');
      return response.data['data'] as List<dynamic>;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }

  @override
  Future<Map<String, dynamic>> sendMessage(String sessionId, String text) async {
    try {
      final response = await dio.post('/chat/$sessionId/messages', data: {
        'text': text,
      });
      return response.data['data'] as Map<String, dynamic>;
    } on DioException catch (e) {
      throw ServerException(e.message ?? 'Network error');
    }
  }
}
