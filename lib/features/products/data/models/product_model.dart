import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:milliy_metr/features/products/domain/entities/product_entity.dart';
import 'package:milliy_metr/core/localization/localized_string.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
class ProductModel with _$ProductModel {
  const factory ProductModel({
    required String id,
    String? sku,
    required LocalizedString name,
    required LocalizedString description,
    List<String>? images,
    List<String>? videos,
    String? brand,
    required String categoryId,
    String? subcategoryId,
    required double price,
    double? oldPrice,
    required String currency,
    required String unit,
    int? moq,
    int? stock,
    String? stockStatus,
    double? rating,
    int? reviewCount,
    double? discount,
    Map<String, String>? specifications,
    List<String>? certificates,
    bool? hasDelivery,
    String? deliveryInformation,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  const ProductModel._();

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      sku: sku,
      name: name,
      description: description,
      images: images ?? [],
      videos: videos ?? [],
      brand: brand,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      price: price,
      oldPrice: oldPrice,
      currency: currency,
      unit: unit,
      moq: moq ?? 1,
      stock: stock ?? 0,
      stockStatus: stockStatus ?? 'in_stock',
      hasDelivery: hasDelivery ?? true,
      rating: rating ?? 0.0,
      reviewCount: reviewCount ?? 0,
      discount: discount,
      specifications: specifications,
      certificates: certificates,
      deliveryInformation: deliveryInformation,
      location: location,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
