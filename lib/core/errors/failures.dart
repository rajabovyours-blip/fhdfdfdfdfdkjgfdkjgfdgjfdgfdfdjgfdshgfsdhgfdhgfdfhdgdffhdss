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
  if (errorData == null) return "Xatolik yuz berdi. Iltimos qayta urinib ko'ring.";
  
  if (errorData is String) {
    if (errorData.contains('DioException') || errorData.contains('SocketException') || errorData.contains('XMLHttpRequest')) {
      return 'Internet aloqasi mavjud emas yoki server bilan ulanishda xatolik yuz berdi.';
    }
    if (errorData.contains('500') || errorData.contains('502') || errorData.contains('503') || errorData.contains('Internal Server Error')) {
      return "Serverda vaqtinchalik profilaktika. Birozdan so'ng urinib ko'ring.";
    }
    return errorData;
  }
  
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
  
  final errorStr = errorData.toString();
  if (errorStr.contains('DioException') || errorStr.contains('SocketException') || errorStr.contains('XMLHttpRequest')) {
    return 'Internet aloqasi mavjud emas yoki server bilan ulanishda xatolik yuz berdi.';
  }
  if (errorStr.contains('500') || errorStr.contains('502') || errorStr.contains('503') || errorStr.contains('Internal Server Error')) {
    return "Serverda vaqtinchalik profilaktika. Birozdan so'ng urinib ko'ring.";
  }

  return "Kutilmagan xatolik yuz berdi. Iltimos keyinroq qayta urinib ko'ring.";
}
