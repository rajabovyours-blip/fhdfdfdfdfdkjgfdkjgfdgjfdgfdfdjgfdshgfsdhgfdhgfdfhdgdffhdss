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
  }) = _BannerModel;

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);

  const BannerModel._();

  BannerEntity toEntity() {
    return BannerEntity(
      id: id,
      imageUrl: imageUrl,
      linkUrl: linkUrl,
      title: title,
      subtitle: subtitle,
      cta: cta,
    );
  }
}
