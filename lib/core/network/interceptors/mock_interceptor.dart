import 'package:dio/dio.dart';
import 'package:milliy_metr/config/app_config.dart';
import 'package:milliy_metr/core/mock/demo_data.dart';

class MockInterceptor extends Interceptor {
  // Static state for the session
  static final Set<String> _wishlist = {};
  static final List<Map<String, dynamic>> _cart = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!AppConfig.useMockBackend) {
      return super.onRequest(options, handler);
    }

    // Give it a tiny delay to simulate network
    await Future.delayed(const Duration(milliseconds: 300));

    final path = options.path;
    final method = options.method;

    try {
      // ---------------------------------------------------------
      // CATEGORIES
      // ---------------------------------------------------------
      if (path.contains('/categories') && !path.contains('/home/')) {
        return handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {'data': DemoData.categories},
          ),
        );
      }

      // ---------------------------------------------------------
      // HOME PAGE ENDPOINTS
      // ---------------------------------------------------------
      if (path.contains('/home/banners')) {
        return handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {
              'data': [
                {
                  'id': 'banner-1',
                  'imageUrl': 'assets/images/products/tools.jpg',
                  'image_url': 'assets/images/products/tools.jpg',
                  'linkUrl': 'category/cat-1',
                  'title': {'uz': 'Aksiya', 'ru': 'Акция', 'en': 'Sale'},
                  'subtitle': {'uz': 'Barcha asboblar uchun 20% chegirma', 'ru': 'Скидка 20% на все инструменты', 'en': '20% off all tools'},
                  'cta': {'uz': 'Xarid qilish', 'ru': 'Купить', 'en': 'Shop Now'},
                },
              ],
            },
          ),
        );
      }

      if (path.contains('/home/popular-categories')) {
        return handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {'data': DemoData.categories.take(8).toList()},
          ),
        );
      }

      if (path.contains('/home/featured-products')) {
        return handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {'data': DemoData.products.take(10).toList()},
          ),
        );
      }

      // ---------------------------------------------------------
      // REVIEWS
      // ---------------------------------------------------------
      if (path.contains('/reviews')) {
        // Example: /products/prod-1/reviews
        final segments = Uri.parse(path).pathSegments;
        if (segments.length >= 2 && segments[0] == 'products') {
          final productId = segments[1];
          final productReviews = DemoData.reviews.where((r) => r['product_id'] == productId).toList();
          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'data': productReviews},
            ),
          );
        }
      }

      // Helper to map demo product to match ProductModel requirements
      Map<String, dynamic> _mapProduct(Map<String, dynamic> map) {
        return {
          ...map,
          'price': (map['price'] ?? 0).toDouble(),
          'oldPrice': map['old_price'] != null ? (map['old_price'] as num).toDouble() : null,
          'currency': 'UZS',
          'unit': map['unit'] ?? 'dona',
          'moq': 1,
          'stock': map['stockCount'] ?? 100,
          'stockStatus': 'in_stock',
          'rating': (map['rating'] ?? 0).toDouble(),
          'reviewCount': map['reviewCount'] ?? 0,
          'location': 'Tashkent',
        };
      }

      // ---------------------------------------------------------
      // PRODUCTS
      // ---------------------------------------------------------
      if (path.contains('/products')) {
        final segments = Uri.parse(path).pathSegments;

        // GET Single Product (e.g., /products/prod-1)
        if (segments.length == 2 && segments[0] == 'products') {
          final productId = segments[1];
          final product = DemoData.products.firstWhere(
            (p) => p['id'] == productId,
            orElse: () => throw Exception('Not found'),
          );
          
          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'data': _mapProduct(product)},
            ),
          );
        }

        // GET Products List (with filters)
        var filteredProducts = List<Map<String, dynamic>>.from(DemoData.products);
        
        final categoryId = options.queryParameters['category_id'];
        if (categoryId != null && categoryId.toString().isNotEmpty) {
          filteredProducts = filteredProducts.where((p) => p['categoryId'] == categoryId).toList();
        }

        final searchQuery = options.queryParameters['search'];
        if (searchQuery != null && searchQuery.toString().isNotEmpty) {
          final query = searchQuery.toString().toLowerCase();
          filteredProducts = filteredProducts.where((p) {
            final nameUz = (p['name']['uz'] ?? '').toString().toLowerCase();
            final nameRu = (p['name']['ru'] ?? '').toString().toLowerCase();
            final nameEn = (p['name']['en'] ?? '').toString().toLowerCase();
            return nameUz.contains(query) || nameRu.contains(query) || nameEn.contains(query);
          }).toList();
        }

        final minPrice = options.queryParameters['min_price'];
        if (minPrice != null) {
          final min = double.tryParse(minPrice.toString()) ?? 0.0;
          filteredProducts = filteredProducts.where((p) {
            final price = p['price'] ?? 0.0;
            return price >= min;
          }).toList();
        }

        final maxPrice = options.queryParameters['max_price'];
        if (maxPrice != null) {
          final max = double.tryParse(maxPrice.toString()) ?? double.infinity;
          filteredProducts = filteredProducts.where((p) {
            final price = p['price'] ?? 0.0;
            return price <= max;
          }).toList();
        }

        final minRating = options.queryParameters['min_rating'];
        if (minRating != null) {
          final min = double.tryParse(minRating.toString()) ?? 0.0;
          filteredProducts = filteredProducts.where((p) => (p['rating'] as num) >= min).toList();
        }

        final sortBy = options.queryParameters['sort_by'];
        if (sortBy == 'price_asc') {
          filteredProducts.sort((a, b) => (a['price'] ?? 0.0).compareTo(b['price'] ?? 0.0));
        } else if (sortBy == 'price_desc') {
          filteredProducts.sort((a, b) => (b['price'] ?? 0.0).compareTo(a['price'] ?? 0.0));
        } else if (sortBy == 'rating_desc') {
          filteredProducts.sort((a, b) => (b['rating'] as num).compareTo(a['rating'] as num));
        }

        return handler.resolve(
          Response(
            requestOptions: options,
            statusCode: 200,
            data: {'data': filteredProducts.map((p) => _mapProduct(p)).toList()},
          ),
        );
      }

      // ---------------------------------------------------------
      // WISHLIST
      // ---------------------------------------------------------
      if (path.contains('/wishlist')) {
        if (method == 'GET') {
          // Join with products
          final wishlistProducts = _wishlist.map((id) {
            return DemoData.products.firstWhere((p) => p['id'] == id, orElse: () => <String, dynamic>{});
          }).where((p) => p.isNotEmpty).toList();

          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'data': wishlistProducts},
            ),
          );
        } else if (method == 'POST') {
          final data = options.data;
          if (data is Map && data.containsKey('product_id')) {
            _wishlist.add(data['product_id']);
          }
          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'success': true},
            ),
          );
        } else if (method == 'DELETE') {
          final segments = Uri.parse(path).pathSegments;
          if (segments.length == 2 && segments[0] == 'wishlist') {
            final productId = segments[1];
            _wishlist.remove(productId);
          }
          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'success': true},
            ),
          );
        }
      }

      // ---------------------------------------------------------
      // CART
      // ---------------------------------------------------------
      if (path.contains('/cart')) {
        if (method == 'GET') {
          return handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {'data': _cart},
            ),
          );
        } else if (path.contains('/cart/add') && method == 'POST') {
          final data = options.data;
          final productId = data['product_id'];
          final quantity = data['quantity'];

          final product = DemoData.products.firstWhere((p) => p['id'] == productId);
          
          // Check if already in cart
          final existingIndex = _cart.indexWhere((item) => item['product']['id'] == productId);
          if (existingIndex >= 0) {
            _cart[existingIndex]['quantity'] += quantity;
          } else {
            _cart.add({
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'product': product,
              'quantity': quantity,
            });
          }
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        } else if (path.contains('/cart/update') && method == 'POST') {
          final data = options.data;
          final cartItemId = data['cart_item_id'];
          final quantity = data['quantity'];

          final existingIndex = _cart.indexWhere((item) => item['id'] == cartItemId);
          if (existingIndex >= 0) {
            _cart[existingIndex]['quantity'] = quantity;
          }
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        } else if (path.contains('/cart/remove') && method == 'DELETE') {
          final data = options.data;
          final cartItemId = data['cart_item_id'];
          _cart.removeWhere((item) => item['id'] == cartItemId);
          return handler.resolve(Response(requestOptions: options, statusCode: 200));
        }
      }

    } catch (e) {
      // Ignore mock failures, fallback below
    }

    // Default fallback to real network if not mocked
    return super.onRequest(options, handler);
  }
}
