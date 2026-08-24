abstract class Failure {
  final String message;
  Failure(this.message);
}

class ServerFailure extends Failure {
  ServerFailure(super.message);
}

class NetworkFailure extends Failure {
  NetworkFailure(super.message);
}

class CacheFailure extends Failure {
  CacheFailure(super.message);
}

String extractErrorMessage(dynamic errorData) {
  if (errorData == null) return 'Xatolik yuz berdi';
  if (errorData is String) return errorData;
  if (errorData is Map<String, dynamic>) {
    final detail = errorData['detail'] ?? errorData['message'];
    if (detail is String) return detail;
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map && first.containsKey('msg')) {
        return first['msg'].toString();
      }
      return detail.first.toString();
    }
  }
  return errorData.toString();
}
