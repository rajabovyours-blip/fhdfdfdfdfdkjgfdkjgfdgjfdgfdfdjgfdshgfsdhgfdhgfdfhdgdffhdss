import 'package:equatable/equatable.dart';
import 'package:milliy_metr/core/localization/localized_string.dart';

class ProductEntity extends Equatable {
  final String id;
  final String? sku;
  final LocalizedString name;
  final LocalizedString description;
  final List<String> images;
  final List<String> videos;
  final String? brand;
  final String categoryId;
  final String? subcategoryId;
  final double price;
  final double? oldPrice;
  final String currency;
  final String unit;
  final int moq;
  final int stock;
  final String stockStatus;
  final double rating;
  final int reviewCount;
  final double? discount;
  final Map<String, String>? specifications;
  final List<String>? certificates;
  final String? deliveryInformation;
  final String? location;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  const ProductEntity({
    required this.id,
    this.sku,
    required this.name,
    required this.description,
    required this.images,
    this.videos = const [],
    this.brand,
    required this.categoryId,
    this.subcategoryId,
    required this.price,
    this.oldPrice,
    required this.currency,
    required this.unit,
    required this.moq,
    required this.stock,
    required this.stockStatus,
    required this.rating,
    required this.reviewCount,
    this.discount,
    this.specifications,
    this.certificates,
    this.deliveryInformation,
    this.location,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductEntity.fromJson(Map<String, dynamic> json) {
    return ProductEntity(
      id: json['id'] as String? ?? '',
      sku: json['sku'] as String?,
      name: LocalizedString.fromJson(json['name']),
      description: LocalizedString.fromJson(json['description']),
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      videos: (json['videos'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      brand: json['brand'] as String?,
      categoryId: json['categoryId'] as String? ?? '',
      subcategoryId: json['subcategoryId'] as String?,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      oldPrice: (json['oldPrice'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'UZS',
      unit: json['unit'] as String? ?? 'pcs',
      moq: json['moq'] as int? ?? 1,
      stock: json['stock'] as int? ?? 0,
      stockStatus: json['stockStatus'] as String? ?? 'in_stock',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      discount: (json['discount'] as num?)?.toDouble(),
      specifications: (json['specifications'] as Map<String, dynamic>?)
          ?.map((k, v) => MapEntry(k, v.toString())),
      certificates: (json['certificates'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      deliveryInformation: json['deliveryInformation'] as String?,
      location: json['location'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sku': sku,
      'name': name.toJson(),
      'description': description.toJson(),
      'images': images,
      'videos': videos,
      'brand': brand,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'price': price,
      'oldPrice': oldPrice,
      'currency': currency,
      'unit': unit,
      'moq': moq,
      'stock': stock,
      'stockStatus': stockStatus,
      'rating': rating,
      'reviewCount': reviewCount,
      'discount': discount,
      'specifications': specifications,
      'certificates': certificates,
      'deliveryInformation': deliveryInformation,
      'location': location,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        sku,
        name,
        description,
        images,
        videos,
        brand,
        categoryId,
        subcategoryId,
        price,
        oldPrice,
        currency,
        unit,
        moq,
        stock,
        stockStatus,
        rating,
        reviewCount,
        discount,
        specifications,
        certificates,
        deliveryInformation,
        location,
        createdAt,
        updatedAt,
      ];
}
