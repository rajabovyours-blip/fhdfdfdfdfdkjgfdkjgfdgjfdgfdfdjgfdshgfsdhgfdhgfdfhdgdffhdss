abstract class SellerProductsRemoteDataSource {
  Future<List<dynamic>> getItems();
}

class SellerProductsRemoteDataSourceImpl
    implements SellerProductsRemoteDataSource {
  final dynamic dio;

  SellerProductsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> getItems() async {
    return [];
  }
}
