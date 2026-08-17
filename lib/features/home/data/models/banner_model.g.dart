// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'banner_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BannerModelImpl _$$BannerModelImplFromJson(Map<String, dynamic> json) =>
    _$BannerModelImpl(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      linkUrl: json['linkUrl'] as String,
      title: LocalizedString.fromJson(json['title']),
      subtitle: LocalizedString.fromJson(json['subtitle']),
      cta: LocalizedString.fromJson(json['cta']),
    );

Map<String, dynamic> _$$BannerModelImplToJson(_$BannerModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'imageUrl': instance.imageUrl,
      'linkUrl': instance.linkUrl,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'cta': instance.cta,
    };
