import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/base/base_usecase.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/authentication/domain/entities/token_entity.dart';
import 'package:milliy_metr/features/authentication/domain/repositories/auth_repository.dart';

class LoginParams {
  final String phone;
  final String password;
  LoginParams({required this.phone, required this.password});
}

class LoginUseCase implements BaseUseCase<TokenEntity, LoginParams> {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  @override
  Future<Either<Failure, TokenEntity>> call(LoginParams params) {
    return repository.login(params.phone, params.password);
  }
}
