import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/failures.dart';

abstract class BaseUseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

class NoParams {}
