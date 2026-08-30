import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:milliy_metr/core/storage/preferences.dart';
import 'package:milliy_metr/l10n/app_localizations.dart';

class DioErrorMapper {
  static String extractErrorMessage(dynamic errorData) {
    if (errorData == null) return _getLocalizedFallbackError('generic');

    // Parse DioException wrapper
    if (errorData is DioException) {
      final responseData = errorData.response?.data;
      if (responseData != null) {
        if (responseData is Map<String, dynamic>) {
          final detail = responseData['detail'] ?? responseData['message'];
          if (detail is String) return detail;
          if (detail is List && detail.isNotEmpty) {
            final first = detail.first;
            if (first is Map && first.containsKey('msg')) {
              return first['msg'].toString();
            }
            return detail.first.toString();
          }
        }
        if (responseData is String) return responseData;
      }

      if (errorData.type == DioExceptionType.connectionTimeout ||
          errorData.type == DioExceptionType.receiveTimeout ||
          errorData.type == DioExceptionType.connectionError) {
        return _getLocalizedFallbackError('network');
      }

      if (errorData.response?.statusCode != null) {
        final code = errorData.response!.statusCode!;
        if (code >= 500) {
          return _getLocalizedFallbackError('server');
        }
        if (code == 422) {
          return "Ma'lumotlarni to'ldirishda xatolik yuz berdi. Iltimos tekshirib qaytadan urining.";
        }
      }
    }

    // Try to parse raw map directly just in case
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
    if (errorStr.contains('DioException') ||
        errorStr.contains('SocketException') ||
        errorStr.contains('XMLHttpRequest') ||
        errorStr.contains('TimeoutException')) {
      return _getLocalizedFallbackError('network');
    }
    
    if (errorStr.contains('500') ||
        errorStr.contains('502') ||
        errorStr.contains('503') ||
        errorStr.contains('Internal Server Error')) {
      return _getLocalizedFallbackError('server');
    }

    // If it's a long error string, don't show it to the user
    if (errorStr.length > 100) {
      return _getLocalizedFallbackError('generic');
    }

    // Default fallback
    return _getLocalizedFallbackError('generic');
  }

  static String _getLocalizedFallbackError(String key) {
    try {
      final lang = PreferencesManager.getString('language') ?? 'uz';
      final l10n = lookupAppLocalizations(Locale(lang));
      switch (key) {
        case 'network':
          return l10n.networkError;
        case 'server':
          return l10n.serverError;
        case 'generic':
        default:
          return l10n.errorOccurred;
      }
    } catch (_) {
      // Very safe fallback if l10n fails to initialize
      return 'Xatolik yuz berdi';
    }
  }
}
