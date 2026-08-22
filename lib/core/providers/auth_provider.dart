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
import 'package:milliy_metr/features/authentication/domain/entities/user_entity.dart';

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

  // Temporarily hold registration info before OTP is verified
  String? _tempFullName;
  String? _tempSurname;

  AuthController({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required RequestOtpUseCase requestOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required SocialLoginUseCase socialLoginUseCase,
    required LogoutUseCase logoutUseCase,
    required AuthRepository repository,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _requestOtpUseCase = requestOtpUseCase,
        _verifyOtpUseCase = verifyOtpUseCase,
        _socialLoginUseCase = socialLoginUseCase,
        _logoutUseCase = logoutUseCase,
        _repository = repository,
        super(const AuthState.initial()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();
    final result = await _repository.getCurrentUser();
    if (!mounted) return;
    result.fold(
      (failure) => state = const AuthState.unauthenticated(),
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

  Future<void> demoBypassAuth() async {
    state = const AuthState.loading();
    await Future.delayed(const Duration(milliseconds: 500));
    // For demo purposes, we can bypass the backend and just simulate an authenticated state
    // But since auth needs a UserEntity, we just use checkAuthStatus which relies on token.
    // If there's no token, we can just save a dummy token in secure storage and then check!
    const dummyUser = UserEntity(
      id: 'demo-google-123',
      fullName: 'Demo User',
      phone: '+998901234567',
    );
    await _repository.saveDemoSession(dummyUser);
    state = AuthState.authenticated(dummyUser);
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
  );
});
