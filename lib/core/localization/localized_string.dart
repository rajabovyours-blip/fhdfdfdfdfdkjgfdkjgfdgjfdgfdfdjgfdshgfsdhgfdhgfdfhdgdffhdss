import 'package:equatable/equatable.dart';

class LocalizedString extends Equatable {
  final String uz;
  final String ru;
  final String en;

  const LocalizedString({
    required this.uz,
    required this.ru,
    required this.en,
  });

  /// Get the localized string based on the provided locale code.
  /// Fallback strategy: User language -> Uzbek -> Russian -> English.
  String get(String locale) {
    if (locale == 'ru' && ru.isNotEmpty) return ru;
    if (locale == 'en' && en.isNotEmpty) return en;
    if (locale == 'uz' && uz.isNotEmpty) return uz;

    // Fallbacks if the preferred locale is empty
    if (uz.isNotEmpty) return uz;
    if (ru.isNotEmpty) return ru;
    return en;
  }

  /// Parses JSON into a LocalizedString.
  /// Handles both legacy single String values (defaults to `uz`)
  /// and multilingual maps `{"uz": "...", "ru": "...", "en": "..."}`.
  factory LocalizedString.fromJson(dynamic json) {
    if (json == null) {
      return const LocalizedString(uz: '', ru: '', en: '');
    }

    if (json is String) {
      return LocalizedString(uz: json, ru: '', en: '');
    } else if (json is Map) {
      return LocalizedString(
        uz: json['uz']?.toString() ?? '',
        ru: json['ru']?.toString() ?? '',
        en: json['en']?.toString() ?? '',
      );
    }

    return const LocalizedString(uz: '', ru: '', en: '');
  }

  Map<String, dynamic> toJson() {
    return {
      'uz': uz,
      'ru': ru,
      'en': en,
    };
  }

  @override
  List<Object?> get props => [uz, ru, en];
}
