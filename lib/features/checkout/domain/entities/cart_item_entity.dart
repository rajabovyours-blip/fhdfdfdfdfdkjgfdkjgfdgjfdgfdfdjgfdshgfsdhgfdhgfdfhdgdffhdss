import 'package:milliy_metr/features/products/domain/entities/product_entity.dart';

class CartItemEntity {
  final String id;
  final ProductEntity product;
  final int quantity;
  final bool isSelected;
  final bool isSavedForLater;
  final int minimumOrderQuantity;
  final int maximumQuantity;

  final String warehouseName;
  final bool isWholesale;

  const CartItemEntity({
    required this.id,
    required this.product,
    required this.quantity,
    required this.isSelected,
    required this.isSavedForLater,
    required this.minimumOrderQuantity,
    required this.maximumQuantity,
    required this.warehouseName,
    required this.isWholesale,
  });

  factory CartItemEntity.fromJson(Map<String, dynamic> json) {
    return CartItemEntity(
      id: json['id'] as String? ?? '',
      product: ProductEntity.fromJson(
        json['product'] as Map<String, dynamic>? ?? {},
      ),
      quantity: json['quantity'] as int? ?? 1,
      isSelected: json['isSelected'] as bool? ?? true,
      isSavedForLater: json['isSavedForLater'] as bool? ?? false,
      minimumOrderQuantity: json['minimumOrderQuantity'] as int? ?? 1,
      maximumQuantity: json['maximumQuantity'] as int? ?? 100,
      warehouseName: json['warehouseName'] as String? ?? '',
      isWholesale: json['isWholesale'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'quantity': quantity,
      'isSelected': isSelected,
      'isSavedForLater': isSavedForLater,
      'minimumOrderQuantity': minimumOrderQuantity,
      'maximumQuantity': maximumQuantity,
      'warehouseName': warehouseName,
      'isWholesale': isWholesale,
    };
  }

  CartItemEntity copyWith({
    String? id,
    ProductEntity? product,
    int? quantity,
    bool? isSelected,
    bool? isSavedForLater,
    int? minimumOrderQuantity,
    int? maximumQuantity,
    String? warehouseName,
    bool? isWholesale,
  }) {
    return CartItemEntity(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      isSelected: isSelected ?? this.isSelected,
      isSavedForLater: isSavedForLater ?? this.isSavedForLater,
      minimumOrderQuantity: minimumOrderQuantity ?? this.minimumOrderQuantity,
      maximumQuantity: maximumQuantity ?? this.maximumQuantity,
      warehouseName: warehouseName ?? this.warehouseName,
      isWholesale: isWholesale ?? this.isWholesale,
    );
  }
}
