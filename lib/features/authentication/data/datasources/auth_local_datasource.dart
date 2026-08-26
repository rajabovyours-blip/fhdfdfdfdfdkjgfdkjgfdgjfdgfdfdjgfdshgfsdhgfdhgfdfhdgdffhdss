import 'package:milliy_metr/core/storage/secure_storage.dart';
import 'package:milliy_metr/features/authentication/data/models/token_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveToken(TokenModel token);
  Future<void> clearSession();
  Future<String?> getAccessToken();
  Future<void> saveUserData(String userData);
  Future<String?> getUserData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<void> saveToken(TokenModel token) async {
    await SecureStorage.saveToken(token.accessToken);
    if (token.refreshToken != null) {
      await SecureStorage.saveRefreshToken(token.refreshToken!);
    }
  }

  @override
  Future<void> clearSession() async {
    await SecureStorage.clearAll();
  }

  @override
  Future<String?> getAccessToken() async {
    return await SecureStorage.getToken();
  }

  @override
  Future<void> saveUserData(String userData) async {
    await SecureStorage.saveUserData(userData);
  }

  @override
  Future<String?> getUserData() async {
    return await SecureStorage.getUserData();
  }
}
