import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/base/base_usecase.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/authentication/domain/repositories/auth_repository.dart';

class RegisterParams {
  final String fullName;
  final String phone;
  final String password;
  RegisterParams({
    required this.fullName,
    required this.phone,
    required this.password,
  });
}

class RegisterUseCase implements BaseUseCase<void, RegisterParams> {
  final AuthRepository repository;
  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RegisterParams params) {
    return repository.register(params.fullName, params.phone, params.password);
  }
}
