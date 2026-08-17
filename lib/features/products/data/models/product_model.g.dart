// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductModelImpl _$$ProductModelImplFromJson(Map<String, dynamic> json) =>
    _$ProductModelImpl(
      id: json['id'] as String,
      sku: json['sku'] as String?,
      name: LocalizedString.fromJson(json['name']),
      description: LocalizedString.fromJson(json['description']),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      videos: (json['videos'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      brand: json['brand'] as String?,
      categoryId: json['categoryId'] as String,
      subcategoryId: json['subcategoryId'] as String?,
      price: (json['price'] as num).toDouble(),
      oldPrice: (json['oldPrice'] as num?)?.toDouble(),
      currency: json['currency'] as String,
      unit: json['unit'] as String,
      moq: (json['moq'] as num).toInt(),
      stock: (json['stock'] as num).toInt(),
      stockStatus: json['stockStatus'] as String,
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      discount: (json['discount'] as num?)?.toDouble(),
      specifications: (json['specifications'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ),
      certificates: (json['certificates'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      deliveryInformation: json['deliveryInformation'] as String?,
      location: json['location'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ProductModelImplToJson(_$ProductModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sku': instance.sku,
      'name': instance.name,
      'description': instance.description,
      'images': instance.images,
      'videos': instance.videos,
      'brand': instance.brand,
      'categoryId': instance.categoryId,
      'subcategoryId': instance.subcategoryId,
      'price': instance.price,
      'oldPrice': instance.oldPrice,
      'currency': instance.currency,
      'unit': instance.unit,
      'moq': instance.moq,
      'stock': instance.stock,
      'stockStatus': instance.stockStatus,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'discount': instance.discount,
      'specifications': instance.specifications,
      'certificates': instance.certificates,
      'deliveryInformation': instance.deliveryInformation,
      'location': instance.location,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
