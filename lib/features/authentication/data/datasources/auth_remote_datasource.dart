import 'package:dio/dio.dart';
import 'package:milliy_metr/core/constants/api_constants.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/authentication/data/models/token_model.dart';
import 'package:milliy_metr/features/authentication/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<TokenModel> login(String phone, String password);
  Future<TokenModel> adminLogin(String email, String password);
  Future<void> register(String fullName, String phone, String password);
  Future<void> requestOtp(String phone);
  Future<bool> checkPhone(String phone);
  Future<TokenModel> verifyOtp(String phone, String otp, {String? fullName, String? surname});
  Future<TokenModel> socialLogin(String provider, String token);
  Future<UserModel> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<TokenModel> login(String phone, String password) async {
    try {
      final response = await dio.post(
        ApiConstants.loginEndpoint,
        data: {
          'phone': phone,
          'password': password,
        },
      );
      return TokenModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Failed to login');
    } catch (e) {
      throw ServerFailure('An unexpected error occurred');
    }
  }

  @override
  Future<TokenModel> adminLogin(String email, String password) async {
    try {
      final response = await dio.post(
        '/auth/admin-login',
        data: {
          'username': email,
          'password': password,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return TokenModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['detail'] ?? e.response?.data['message'] ?? 'Failed to login');
    } catch (e) {
      throw ServerFailure('An unexpected error occurred');
    }
  }

  @override
  Future<void> register(String fullName, String phone, String password) async {
    try {
      await dio.post(
        ApiConstants.registerEndpoint,
        data: {
          'full_name': fullName,
          'phone': phone,
          'password': password,
        },
      );
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Failed to register');
    } catch (e) {
      throw ServerFailure('An unexpected error occurred');
    }
  }

  @override
  Future<void> requestOtp(String phone) async {
    try {
      await dio.post(
        '/auth/request-otp',
        data: {
          'phone': phone,
        },
      );
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.data['message'] ?? 'Failed to request OTP',
      );
    } catch (e) {
      throw ServerFailure('An unexpected error occurred');
    }
  }

  @override
  Future<bool> checkPhone(String phone) async {
    try {
      final response = await dio.post(
        '/auth/check-phone',
        data: {
          'phone': phone,
        },
      );
      return response.data['data']['exists'] as bool;
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.data['message'] ?? 'Failed to check phone',
      );
    } catch (e) {
      throw ServerFailure('An unexpected error occurred');
    }
  }

  @override
  Future<TokenModel> verifyOtp(String phone, String otp, {String? fullName, String? surname}) async {
    try {
      final data = {
        'phone': phone,
        'otp': otp,
      };
      if (fullName != null) data['full_name'] = fullName;
      if (surname != null) data['surname'] = surname;
      
      final response = await dio.post(
        '/auth/verify-otp',
        data: data,
      );
      return TokenModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.data['message'] ?? 'Failed to verify OTP',
      );
    } catch (e) {
      throw ServerFailure('An unexpected error occurred');
    }
  }

  @override
  Future<TokenModel> socialLogin(String provider, String token) async {
    try {
      final response = await dio.post(
        '/auth/social-login',
        data: {
          'provider': provider,
          'token': token,
        },
      );
      return TokenModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerFailure(
        e.response?.data['message'] ?? 'Failed to login with $provider',
      );
    } catch (e) {
      throw ServerFailure('An unexpected error occurred');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dio.get('/auth/me');
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw ServerFailure(e.response?.data['message'] ?? 'Failed to get user');
    } catch (e) {
      throw ServerFailure('An unexpected error occurred');
    }
  }
}
