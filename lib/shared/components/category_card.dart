import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/features/categories/domain/entities/category_entity.dart';
import 'package:milliy_metr/features/categories/utils/category_asset_helper.dart';
import 'package:milliy_metr/shared/components/brand_image_loader.dart';

class CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF16181F) : Colors.white;
    final borderColor = isDark ? Colors.white.withOpacity(0.06) : const Color(0xFFE5E7EB);

    final assetPath = CategoryAssetHelper.getAssetPath(
      category.id,
      category.name.get('en'),
    );

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Top Image (Flex 65%)
          Expanded(
            flex: 65,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              child: BrandImageLoader(
                imageUrl: assetPath,
                fit: BoxFit.cover,
                borderRadius: 0,
              ),
            ),
          ),
          // 2. Bottom Title (Flex 35%)
          Expanded(
            flex: 35,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
              alignment: Alignment.center,
              child: Text(
                category.name.get(Localizations.localeOf(context).languageCode),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: context.colors.textHigh,
                  fontSize: 11.0,
                  fontWeight: FontWeight.w600,
                  height: 1.15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
