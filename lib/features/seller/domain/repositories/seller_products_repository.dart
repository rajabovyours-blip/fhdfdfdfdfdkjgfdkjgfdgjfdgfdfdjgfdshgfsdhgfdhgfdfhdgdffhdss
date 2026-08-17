import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/failures.dart';

abstract class SellerProductsRepository {
  Future<Either<Failure, List<dynamic>>> getItems();
}
