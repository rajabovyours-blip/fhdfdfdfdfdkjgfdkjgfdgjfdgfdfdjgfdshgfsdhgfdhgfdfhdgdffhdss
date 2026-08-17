import 'package:milliy_metr/core/localization/localized_string.dart';

class BannerEntity {
  final String id;
  final String imageUrl;
  final String linkUrl;
  final LocalizedString title;
  final LocalizedString subtitle;
  final LocalizedString cta;

  BannerEntity({
    required this.id,
    required this.imageUrl,
    required this.linkUrl,
    required this.title,
    required this.subtitle,
    required this.cta,
  });
}
