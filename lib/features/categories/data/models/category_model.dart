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
    String resolveCategoryImage(String id, String? rawUrl) {
      if (rawUrl != null && rawUrl.isNotEmpty && !rawUrl.contains('cat-1.webp')) {
        return rawUrl;
      }
      final numStr = id.replaceAll(RegExp(r'\D'), '');
      final index = int.tryParse(numStr) ?? 1;
      final clampedIndex = index.clamp(1, 61);
      return 'assets/images/categories/cat-$clampedIndex.webp';
    }

    return CategoryEntity(
      id: id,
      name: name,
      description: description,
      iconUrl: resolveCategoryImage(id, iconUrl),
      imageUrl: resolveCategoryImage(id, imageUrl),
      parentId: parentId,
      productCount: productCount,
      isFeatured: isFeatured,
      subcategories: subcategories.map((e) => e.toEntity()).toList(),
    );
  }
}
