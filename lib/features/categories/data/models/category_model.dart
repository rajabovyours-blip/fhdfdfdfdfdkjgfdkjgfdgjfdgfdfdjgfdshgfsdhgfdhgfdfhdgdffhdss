import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:milliy_metr/features/categories/domain/entities/category_entity.dart';
import 'package:milliy_metr/core/localization/localized_string.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
class CategoryModel with _$CategoryModel {
  const factory CategoryModel({
    required String id,
    required LocalizedString name,
    LocalizedString? description,
    String? iconUrl,
    String? imageUrl,
    String? parentId,
    int? productCount,
    @Default(false) bool isFeatured,
    @Default([]) List<CategoryModel> subcategories,
  }) = _CategoryModel;

  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryModelFromJson(json);

  const CategoryModel._();

  CategoryEntity toEntity() {
    // Intelligently map to one of the manually uploaded 61 category images based on name
    String getAssetPath(String name) {
      final hash = name.hashCode.abs();
      final index = (hash % 61) + 1; // Maps to cat-1.webp ... cat-61.webp
      return 'assets/images/categories/cat-$index.webp';
    }

    return CategoryEntity(
      id: id,
      name: name,
      description: description,
      iconUrl: (iconUrl == null || iconUrl!.isEmpty || iconUrl == 'null') 
          ? getAssetPath(name.get('en')) 
          : iconUrl,
      imageUrl: imageUrl,
      parentId: parentId,
      productCount: productCount,
      isFeatured: isFeatured,
      subcategories: subcategories.map((e) => e.toEntity()).toList(),
    );
  }
}
