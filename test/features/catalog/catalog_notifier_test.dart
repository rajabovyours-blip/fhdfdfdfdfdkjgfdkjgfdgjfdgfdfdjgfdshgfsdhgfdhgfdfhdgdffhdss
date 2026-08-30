import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:milliy_metr/features/catalog/presentation/providers/catalog_notifier.dart';
import 'package:milliy_metr/features/products/data/repositories/product_repository_impl.dart';
import 'package:milliy_metr/features/products/presentation/providers/product_providers.dart';
import 'package:fpdart/fpdart.dart';
import 'package:milliy_metr/core/errors/failures.dart';
import 'package:milliy_metr/features/products/domain/entities/product_entity.dart';

class MockProductRepository implements ProductRepository {
  Map<String, dynamic>? lastFilters;

  @override
  Future<Either<Failure, List<ProductEntity>>> getProducts({
    int page = 1,
    int limit = 20,
    String? categoryId,
    String? searchQuery,
    Map<String, dynamic>? filters,
  }) async {
    lastFilters = filters;
    return const Right([]);
  }

  @override
  Future<Either<Failure, ProductEntity>> getProductById(String id) async {
    return Left(ServerFailure('Not implemented'));
  }
}

void main() {
  test('CatalogNotifier serializes minPrice and maxPrice to snake_case integers', () async {
    final mockRepo = MockProductRepository();
    final container = ProviderContainer(
      overrides: [
        productRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );

    final notifier = container.read(catalogNotifierProvider.notifier);

    // Set filters
    notifier.setFilters(minPrice: 5000.5, maxPrice: 10000.9);
    await Future.delayed(Duration.zero); // wait for loadProducts to hit repository

    // verify the state
    final state = container.read(catalogNotifierProvider);
    final data = state.maybeWhen(
      loaded: (d) => d,
      orElse: () => null,
    );
    expect(data, isNotNull);
    expect(data!.minPrice, 5000.5);
    expect(data.maxPrice, 10000.9);

    // check what was sent to the repository
    expect(mockRepo.lastFilters, isNotNull);
    expect(mockRepo.lastFilters!['min_price'], 5000);
    expect(mockRepo.lastFilters!['max_price'], 10000);
  });
}
