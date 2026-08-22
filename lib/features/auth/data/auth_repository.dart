import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/api/api_client.dart';

final secureStorageProvider = Provider((ref) => const FlutterSecureStorage());

final authRepositoryProvider = Provider((ref) {
  return AuthRepository(ref.watch(dioProvider), ref.watch(secureStorageProvider));
});

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  Future<bool> login(String email, String password) async {
    try {
      final response = await _dio.post('/auth/admin-login', data: {
        'username': email,
        'password': password,
      }, options: Options(
        contentType: Headers.formUrlEncodedContentType
      ));

      final token = response.data['access_token'];
      if (token != null) {
        await _storage.write(key: 'access_token', value: token);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'access_token');
  }

  Future<String?> getToken() async {
    return await _storage.read(key: 'access_token');
  }
}
