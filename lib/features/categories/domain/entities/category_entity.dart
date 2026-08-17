import 'package:equatable/equatable.dart';
import 'package:milliy_metr/core/localization/localized_string.dart';

class CategoryEntity extends Equatable {
  final String id;
  final LocalizedString name;
  final LocalizedString? description;
  final String? iconUrl;
  final String? imageUrl;
  final String? parentId;
  final int? productCount;
  final bool isFeatured;
  final List<CategoryEntity> subcategories;

  const CategoryEntity({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    this.imageUrl,
    this.parentId,
    this.productCount,
    this.isFeatured = false,
    this.subcategories = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconUrl,
        imageUrl,
        parentId,
        productCount,
        isFeatured,
        subcategories,
      ];
}
