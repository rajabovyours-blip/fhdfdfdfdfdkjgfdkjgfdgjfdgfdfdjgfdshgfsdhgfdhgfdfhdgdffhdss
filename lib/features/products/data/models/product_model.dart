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
    @Default([]) List<String> images,
    @Default([]) List<String> videos,
    String? brand,
    required String categoryId,
    String? subcategoryId,
    required double price,
    double? oldPrice,
    required String currency,
    required String unit,
    required int moq,
    required int stock,
    required String stockStatus,
    required double rating,
    required int reviewCount,
    double? discount,
    Map<String, String>? specifications,
    List<String>? certificates,
    String? deliveryInformation,
    required String location,
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
      images: images,
      videos: videos,
      brand: brand,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      price: price,
      oldPrice: oldPrice,
      currency: currency,
      unit: unit,
      moq: moq,
      stock: stock,
      stockStatus: stockStatus,
      rating: rating,
      reviewCount: reviewCount,
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
