import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/base/base_usecase.dart';
import 'package:milliy_metr/core/network/dio_client.dart';
import 'package:milliy_metr/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:milliy_metr/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:milliy_metr/features/authentication/data/repositories/auth_repository_impl.dart';
import 'package:milliy_metr/features/authentication/domain/repositories/auth_repository.dart';
import 'package:milliy_metr/features/authentication/domain/usecases/login_usecase.dart';
import 'package:milliy_metr/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:milliy_metr/features/authentication/domain/usecases/register_usecase.dart';
import 'package:milliy_metr/features/authentication/domain/usecases/request_otp_usecase.dart';
import 'package:milliy_metr/features/authentication/domain/usecases/verify_otp_usecase.dart';
import 'package:milliy_metr/features/authentication/domain/usecases/social_login_usecase.dart';
import 'package:milliy_metr/features/authentication/presentation/providers/auth_state.dart';
import 'package:milliy_metr/features/authentication/data/models/user_model.dart';

import 'package:milliy_metr/core/events/auth_events.dart';
import 'dart:async';
import 'package:flutter/foundation.dart';
final dioProvider = Provider<Dio>((ref) => DioClient().dio);

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(ref.watch(dioProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.watch(authRepositoryProvider));
});

final requestOtpUseCaseProvider = Provider<RequestOtpUseCase>((ref) {
  return RequestOtpUseCase(ref.watch(authRepositoryProvider));
});

final verifyOtpUseCaseProvider = Provider<VerifyOtpUseCase>((ref) {
  return VerifyOtpUseCase(ref.watch(authRepositoryProvider));
});

final socialLoginUseCaseProvider = Provider<SocialLoginUseCase>((ref) {
  return SocialLoginUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final RequestOtpUseCase _requestOtpUseCase;
  final VerifyOtpUseCase _verifyOtpUseCase;
  final SocialLoginUseCase _socialLoginUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthRepository _repository;
  final Dio _dio;

  // Temporarily hold registration info before OTP is verified
  String? _tempFullName;
  String? _tempSurname;

  StreamSubscription? _authSubscription;

  AuthController({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required RequestOtpUseCase requestOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required SocialLoginUseCase socialLoginUseCase,
    required LogoutUseCase logoutUseCase,
    required AuthRepository repository,
    required Dio dio,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _requestOtpUseCase = requestOtpUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _socialLoginUseCase = socialLoginUseCase,
        _logoutUseCase = logoutUseCase,
        _repository = repository,
        _dio = dio,
        super(const AuthState.initial()) {
    checkAuthStatus();
    _listenToAuthEvents();
  }

  void _listenToAuthEvents() {
    _authSubscription = AuthEventBus.stream.listen((event) {
      if (event is SessionExpiredEvent) {
        state = const AuthState.unauthenticated();
      }
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }


  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();
    // Try to get cached user first for immediate UI render
    final cachedResult = await _repository.getCachedUser();
    cachedResult.fold(
      (_) {},
      (user) {
        if (user != null) {
          state = AuthState.authenticated(user);
        }
      },
    );

    final result = await _repository.getCurrentUser();
    if (!mounted) return;
    result.fold(
      (failure) {
        // If we already have a cached user, don't unauthenticate just because of network failure
        final isAuthenticated = state.maybeWhen(
          authenticated: (_) => true,
          orElse: () => false,
        );
        if (!isAuthenticated) {
          state = const AuthState.unauthenticated();
        }
      },
      (user) => state = AuthState.authenticated(user),
    );
  }

  Future<bool> checkPhone(String phone) async {
    state = const AuthState.loading();
    final result = await _repository.checkPhone(phone);
    return result.fold(
      (failure) {
        state = AuthState.error(failure.message);
        return false;
      },
      (exists) {
        state = const AuthState.unauthenticated();
        return exists;
      },
    );
  }

  void clearError() {
    state.maybeWhen(
      error: (_) => state = const AuthState.unauthenticated(),
      orElse: () {},
    );
  }

  void saveRegistrationData(String fullName, String surname) {
    _tempFullName = fullName;
    _tempSurname = surname;
  }

  Future<bool> requestOtp(String phone) async {
    // Normal flow
    state = const AuthState.loading();
    final result = await _requestOtpUseCase(RequestOtpParams(phone: phone));
    return result.fold(
      (failure) {
        state = AuthState.error(failure.message);
        return false;
      },
      (_) {
        state = const AuthState.unauthenticated();
        return true;
      },
    );
  }

  Future<void> login(String phone, String password) async {
    state = const AuthState.loading();
    final result =
        await _loginUseCase(LoginParams(phone: phone, password: password));
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (token) => checkAuthStatus(), // fetch user info after getting token
    );
  }

  Future<String?> adminLogin(String email, String password) async {
    state = const AuthState.loading();
    final result = await _repository.adminLogin(email, password);
    return result.fold(
      (failure) {
        state = AuthState.error(failure.message);
        return failure.message;
      },
      (token) {
        checkAuthStatus(); // fetch user info after getting token
        return null; // success
      },
    );
  }

  Future<bool> register(String fullName, String phone, String password) async {
    state = const AuthState.loading();
    final result = await _registerUseCase(
      RegisterParams(fullName: fullName, phone: phone, password: password),
    );
    return result.fold(
      (failure) {
        state = AuthState.error(failure.message);
        return false;
      },
      (_) {
        state = const AuthState.unauthenticated(); // Ready for OTP
        return true;
      },
    );
  }

  Future<bool> verifyOtp(String phone, String otp) async {
    state = const AuthState.loading();
    final result = await _verifyOtpUseCase(VerifyOtpParams(
      phone: phone, 
      otp: otp,
      fullName: _tempFullName,
      surname: _tempSurname,
    ),);
    return result.fold(
      (failure) {
        state = AuthState.error(failure.message);
        return false;
      },
      (token) {
        // Clear temp data
        _tempFullName = null;
        _tempSurname = null;
        checkAuthStatus();
        return true;
      },
    );
  }

  Future<void> socialLogin(String provider, String token) async {
    state = const AuthState.loading();
    final result = await _socialLoginUseCase(
      SocialLoginParams(provider: provider, token: token),
    );
    result.fold(
      (failure) => state = AuthState.error(failure.message),
      (token) => checkAuthStatus(),
    );
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    await _logoutUseCase(NoParams());
    state = const AuthState.unauthenticated();
  }



  Future<String?> updateProfile(String fullName, String email, String avatarUrl) async {
    // Save current state in case of failure
    final currentState = state;
    try {
      final response = await _dio.put('/users/me', data: {
        'full_name': fullName,
        'fullName': fullName,
        'email': email.isEmpty ? null : email,
        'avatar_url': avatarUrl,
        'avatarUrl': avatarUrl,
      },);
      
      if (mounted) {
        try {
          final user = UserModel.fromJson(response.data['data']).toEntity();
          state = AuthState.authenticated(user);
          await _repository.cacheUser(user);
        } catch (e) {
          debugPrint('Failed to parse updated user: $e');
        }
      }
      return null;
    } on DioException catch (e) {
      debugPrint('Profile update failed: ${e.response?.data}');
      state = currentState;
      return e.response?.data?['detail'] ?? 'Profile update failed';
    } catch (e) {
      state = currentState;
      return 'An unexpected error occurred';
    }
  }
}

final authProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    loginUseCase: ref.watch(loginUseCaseProvider),
    registerUseCase: ref.watch(registerUseCaseProvider),
    requestOtpUseCase: ref.watch(requestOtpUseCaseProvider),
    verifyOtpUseCase: ref.watch(verifyOtpUseCaseProvider),
    socialLoginUseCase: ref.watch(socialLoginUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    repository: ref.watch(authRepositoryProvider),
    dio: ref.watch(dioProvider),
  );
});
