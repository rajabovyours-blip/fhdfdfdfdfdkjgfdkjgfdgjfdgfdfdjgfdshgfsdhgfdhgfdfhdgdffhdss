class ApiConstants {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'https://milliy-metr-backend-hdol.onrender.com/api/v1');
  static const String wsUrl = String.fromEnvironment('WS_BASE_URL', defaultValue: 'wss://milliy-metr-backend-hdol.onrender.com/api/v1/ws');
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String productsEndpoint = '/products';
}
