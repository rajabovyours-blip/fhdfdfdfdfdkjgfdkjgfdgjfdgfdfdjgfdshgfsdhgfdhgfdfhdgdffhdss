import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/base/base_usecase.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/authentication/domain/repositories/auth_repository.dart';
import 'package:milliy_metr/features/authentication/domain/entities/token_entity.dart';

class SocialLoginParams {
  final String provider;
  final String token;
  SocialLoginParams({required this.provider, required this.token});
}

class SocialLoginUseCase
    implements BaseUseCase<TokenEntity, SocialLoginParams> {
  final AuthRepository repository;
  SocialLoginUseCase(this.repository);

  @override
  Future<Either<Failure, TokenEntity>> call(SocialLoginParams params) {
    return repository.socialLogin(params.provider, params.token);
  }
}
