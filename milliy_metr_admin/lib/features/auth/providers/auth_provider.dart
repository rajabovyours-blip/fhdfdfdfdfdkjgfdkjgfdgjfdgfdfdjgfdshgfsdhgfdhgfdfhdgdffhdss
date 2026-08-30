import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../main.dart'; // To access sharedPrefs
import '../../../core/api/api_client.dart';

final authStateProvider = StateNotifierProvider<AuthNotifier, bool>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthNotifier(dio);
});

class AuthNotifier extends StateNotifier<bool> {
  final Dio _dio;

  AuthNotifier(this._dio) : super(false) {
    _checkStatus();
  }

  void _checkStatus() {
    final token = sharedPrefs.getString('admin_token');
    if (token != null && token.isNotEmpty) {
      state = true;
    }
  }

  Future<bool> login(String username, String password) async {
    try {
      final response = await _dio.post('/auth/admin-login', data: {
        'username': username,
        'password': password,
      }, options: Options(contentType: 'application/x-www-form-urlencoded'));
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['data'] != null && data['data']['access_token'] != null) {
          final token = data['data']['access_token'];
          await sharedPrefs.setString('admin_token', token);
          state = true;
          return true;
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await sharedPrefs.remove('admin_token');
    state = false;
  }
}
