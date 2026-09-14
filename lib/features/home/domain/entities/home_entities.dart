import 'package:milliy_metr/core/localization/localized_string.dart';

class BannerEntity {
  final String id;
  final String imageUrl;
  final String linkUrl;
  final LocalizedString title;
  final LocalizedString subtitle;
  final LocalizedString cta;
  // "image" yoki "video".
  final String mediaType;
  // mediaType == "video" bo'lganda videoning server manzili, aks holda bo'sh.
  final String videoUrl;

  BannerEntity({
    required this.id,
    required this.imageUrl,
    required this.linkUrl,
    required this.title,
    required this.subtitle,
    required this.cta,
    this.mediaType = 'image',
    this.videoUrl = '',
  });

  bool get isVideo => mediaType == 'video' && videoUrl.isNotEmpty;
}
