import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/shared/components/brand_image_loader.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final String iconAsset;
  final VoidCallback onTap;

  const CategoryItem({
    super.key,
    required this.title,
    required this.iconAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 82,
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.colors.outline.withValues(alpha: 0.5)),
              ),
              clipBehavior: Clip.hardEdge,
              child: BrandImageLoader(
                imageUrl: iconAsset,
                fit: BoxFit.cover,
                borderRadius: 0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: context.colors.textHigh,
                fontSize: 12,
                fontWeight: FontWeight.w500,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
