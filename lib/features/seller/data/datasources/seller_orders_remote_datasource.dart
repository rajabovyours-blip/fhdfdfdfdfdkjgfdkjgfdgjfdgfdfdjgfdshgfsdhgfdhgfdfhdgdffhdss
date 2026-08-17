abstract class SellerOrdersRemoteDataSource {
  Future<List<dynamic>> getItems();
}

class SellerOrdersRemoteDataSourceImpl implements SellerOrdersRemoteDataSource {
  final dynamic dio;

  SellerOrdersRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> getItems() async {
    return [];
  }
}
