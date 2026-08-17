import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/base/base_usecase.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/authentication/domain/repositories/auth_repository.dart';

class RequestOtpParams {
  final String phone;
  RequestOtpParams({required this.phone});
}

class RequestOtpUseCase implements BaseUseCase<void, RequestOtpParams> {
  final AuthRepository repository;
  RequestOtpUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RequestOtpParams params) {
    return repository.requestOtp(params.phone);
  }
}
