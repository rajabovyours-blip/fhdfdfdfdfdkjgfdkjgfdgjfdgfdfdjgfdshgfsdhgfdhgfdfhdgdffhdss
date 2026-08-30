// ignore_for_file: avoid_print
import 'package:dio/dio.dart';

void main() async {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://127.0.0.1:8000/api/v1',
    responseType: ResponseType.json,
  ),);

  // Enable logging
  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
    error: true,
  ),);

  try {
    print('--- TESTING CHECKOUT API ---');
    final payload = {
      'items': [
        {'product_id': '1234', 'quantity': 1},
      ],
      'delivery_address': 'Tashkent',
      'payment_method': 'Cash',
      'delivery_method': 'Delivery Service',
      'customer_notes': 'Call me',
    };
    final response = await dio.post('/checkout/order', data: payload);
    print('Checkout response: ${response.statusCode} ${response.data}');
  } on DioException catch (e, _) {
    print('Checkout DioError: ${e.response?.statusCode}');
    print('Checkout Error details: ${e.response?.data}');
  }

  try {
    print('\n--- TESTING PRODUCTS API WITH CAMEL CASE PARAMS ---');
    final response = await dio.get('/products', queryParameters: {
      'minPrice': 5000,
      'maxPrice': 10000,
    },);
    print('Products response: ${response.statusCode} ${response.data}');
  } on DioException catch (e, _) {
    print('Products DioError: ${e.response?.statusCode}');
    print('Products Error details: ${e.response?.data}');
  }
}
