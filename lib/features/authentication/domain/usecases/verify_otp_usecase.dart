import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/base/base_usecase.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/authentication/domain/entities/token_entity.dart';
import 'package:milliy_metr/features/authentication/domain/repositories/auth_repository.dart';

class VerifyOtpParams {
  final String phone;
  final String otp;
  final String? fullName;
  final String? surname;
  
  VerifyOtpParams({
    required this.phone, 
    required this.otp,
    this.fullName,
    this.surname,
  });
}

class VerifyOtpUseCase implements BaseUseCase<TokenEntity, VerifyOtpParams> {
  final AuthRepository repository;
  VerifyOtpUseCase(this.repository);

  @override
  Future<Either<Failure, TokenEntity>> call(VerifyOtpParams params) {
    return repository.verifyOtp(
      params.phone, 
      params.otp,
      fullName: params.fullName,
      surname: params.surname,
    );
  }
}
