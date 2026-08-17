// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: json['id'] as String,
      name: Map<String, String>.from(json['name'] as Map),
      description: Map<String, String>.from(json['description'] as Map),
      basePrice: (json['basePrice'] as num).toDouble(),
      stock: (json['stock'] as num).toInt(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'basePrice': instance.basePrice,
      'stock': instance.stock,
      'status': instance.status,
    };
