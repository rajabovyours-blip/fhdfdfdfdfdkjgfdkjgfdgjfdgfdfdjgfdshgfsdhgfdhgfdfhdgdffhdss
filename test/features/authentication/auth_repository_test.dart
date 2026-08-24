import 'package:flutter_test/flutter_test.dart';
import 'package:milliy_metr/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:milliy_metr/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:milliy_metr/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:milliy_metr/features/authentication/data/models/token_model.dart';
import 'package:milliy_metr/features/authentication/data/models/user_model.dart';

class MockRemoteDataSource implements AuthRemoteDataSource {
  @override
  Future<TokenModel> login(String phone, String password) async {
    if (phone == '123' && password == 'password') {
      return const TokenModel(accessToken: 'token', refreshToken: 'refresh');
    }
    throw Exception('Invalid credentials');
  }

  @override
  Future<TokenModel> adminLogin(String email, String password) async {
    return const TokenModel(accessToken: 'admin_token', refreshToken: 'admin_refresh');
  }

  @override
  Future<void> register(String fullName, String phone, String password) async {
    return;
  }

  @override
  Future<void> requestOtp(String phone) async {
    return;
  }

  @override
  Future<TokenModel> verifyOtp(String phone, String otp, {String? fullName, String? surname}) async {
    if (otp == '0000') {
      return const TokenModel(accessToken: 'token', refreshToken: 'refresh');
    }
    throw Exception('Invalid OTP');
  }

  @override
  Future<TokenModel> socialLogin(String provider, String token) async {
    return const TokenModel(accessToken: 'token', refreshToken: 'refresh');
  }

  @override
  Future<bool> checkPhone(String phone) async {
    return true;
  }

  @override
  Future<UserModel> getCurrentUser() async {
    return const UserModel(id: '1', fullName: 'Test User', phone: '123');
  }
}

class MockLocalDataSource implements AuthLocalDataSource {
  String? _token;

  @override
  Future<void> saveToken(TokenModel tokenToCache) async {
    _token = tokenToCache.accessToken;
  }

  @override
  Future<void> clearSession() async {
    _token = null;
  }

  @override
  Future<String?> getAccessToken() async => _token;

  Future<String?> getRefreshToken() async => null;


}

void main() {
  late AuthRepositoryImpl repository;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  group('AuthRepositoryImpl', () {
    test('login success should cache token', () async {
      final result = await repository.login('123', 'password');
      expect(result.isRight(), true);

      final token = await mockLocal.getAccessToken();
      expect(token, 'token');
    });

    test('login failure should return ServerFailure', () async {
      final result = await repository.login('wrong', 'pass');
      expect(result.isLeft(), true);
    });

    test('verifyOtp success should return TokenEntity', () async {
      final result = await repository.verifyOtp('123', '0000');
      expect(result.isRight(), true);
    });

    test('logout should clear cache', () async {
      await mockLocal
          .saveToken(const TokenModel(accessToken: 't', refreshToken: 'r'));
      await repository.logout();
      final token = await mockLocal.getAccessToken();
      expect(token, null);
    });
  });
}
