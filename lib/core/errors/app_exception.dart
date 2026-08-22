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
  ServerException([String msg = 'Server Error']) : super(_formatMessage(msg));

  static String _formatMessage(String msg) {
    if (msg.contains('DioException') || 
        msg.toLowerCase().contains('timeout') || 
        msg.contains('Network error') || 
        msg.toLowerCase().contains('connection')) {
      return 'Connection error. Please try again later.';
    }
    return msg;
  }
}

class CacheException extends AppException {
  CacheException([super.message = 'Cache Error']);
}
