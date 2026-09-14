import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:milliy_metr/features/home/domain/entities/home_entities.dart';
import 'package:milliy_metr/core/localization/localized_string.dart';

part 'banner_model.freezed.dart';
part 'banner_model.g.dart';

@freezed
class BannerModel with _$BannerModel {
  const factory BannerModel({
    required String id,
    required String imageUrl,
    required String linkUrl,
    required LocalizedString title,
    required LocalizedString subtitle,
    required LocalizedString cta,
    // "image" yoki "video". Backend har doim to'ldirib yuboradi (eski
    // bannerlar uchun ham "image" bo'lib qaytadi), shuning uchun bu yerda
    // null bo'lish ehtimoli yo'q.
    required String mediaType,
    // mediaType == "video" bo'lganda videoning server manzili. Aks holda
    // bo'sh satr — nullable qilib freezed'ning maxsus sentinel patternini
    // ishlatmaslik uchun ataylab shunday.
    required String videoUrl,
  }) = _BannerModel;

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);

  const BannerModel._();

  bool get isVideo => mediaType == 'video' && videoUrl.isNotEmpty;

  BannerEntity toEntity() {
    return BannerEntity(
      id: id,
      imageUrl: imageUrl,
      linkUrl: linkUrl,
      title: title,
      subtitle: subtitle,
      cta: cta,
      mediaType: mediaType,
      videoUrl: videoUrl,
    );
  }
}
