class ApiConstants {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://10.0.2.2:8000/api/v1');
  static const String wsUrl = String.fromEnvironment('WS_BASE_URL', defaultValue: 'ws://10.0.2.2:8000/api/v1/ws');
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String productsEndpoint = '/products';
}
