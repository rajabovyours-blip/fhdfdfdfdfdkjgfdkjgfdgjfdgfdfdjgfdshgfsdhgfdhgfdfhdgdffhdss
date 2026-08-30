class AppConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://milliymetr-backend.onrender.com/api/v1',
  );
}
