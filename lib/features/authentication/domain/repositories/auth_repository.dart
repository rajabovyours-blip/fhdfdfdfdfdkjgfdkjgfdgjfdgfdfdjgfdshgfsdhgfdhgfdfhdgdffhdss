import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/authentication/domain/entities/user_entity.dart';
import 'package:milliy_metr/features/authentication/domain/entities/token_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, TokenEntity>> login(String phone, String password);
  Future<Either<Failure, TokenEntity>> adminLogin(String email, String password);
  Future<Either<Failure, void>> register(
    String fullName,
    String phone,
    String password,
  );
  Future<Either<Failure, void>> requestOtp(String phone);
  Future<Either<Failure, bool>> checkPhone(String phone);
  Future<Either<Failure, TokenEntity>> verifyOtp(String phone, String otp, {String? fullName, String? surname});
  Future<Either<Failure, TokenEntity>> socialLogin(
    String provider,
    String token,
  );
  Future<Either<Failure, UserEntity>> getCurrentUser();
  Future<Either<Failure, void>> logout();
  Future<void> saveDemoSession(UserEntity user);
}
