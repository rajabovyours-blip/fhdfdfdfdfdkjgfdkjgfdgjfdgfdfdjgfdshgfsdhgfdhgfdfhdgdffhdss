abstract class SellerInventoryRemoteDataSource {
  Future<List<dynamic>> getItems();
}

class SellerInventoryRemoteDataSourceImpl
    implements SellerInventoryRemoteDataSource {
  final dynamic dio;

  SellerInventoryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<dynamic>> getItems() async {
    return [];
  }
}
