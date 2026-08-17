// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CategoryModelImpl _$$CategoryModelImplFromJson(Map<String, dynamic> json) =>
    _$CategoryModelImpl(
      id: json['id'] as String,
      name: LocalizedString.fromJson(json['name']),
      description: json['description'] == null
          ? null
          : LocalizedString.fromJson(json['description']),
      iconUrl: json['iconUrl'] as String?,
      imageUrl: json['imageUrl'] as String?,
      parentId: json['parentId'] as String?,
      productCount: (json['productCount'] as num?)?.toInt(),
      isFeatured: json['isFeatured'] as bool? ?? false,
      subcategories: (json['subcategories'] as List<dynamic>?)
              ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CategoryModelImplToJson(_$CategoryModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'iconUrl': instance.iconUrl,
      'imageUrl': instance.imageUrl,
      'parentId': instance.parentId,
      'productCount': instance.productCount,
      'isFeatured': instance.isFeatured,
      'subcategories': instance.subcategories,
    };
