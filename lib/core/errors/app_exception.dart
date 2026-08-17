class AppException implements Exception {
  final String message;
  final String? prefix;

  AppException([this.message = '', this.prefix]);

  @override
  String toString() {
    return '$prefix$message';
  }
}

class ServerException extends AppException {
  ServerException([super.message = 'Server Error']);
}

class CacheException extends AppException {
  CacheException([super.message = 'Cache Error']);
}
