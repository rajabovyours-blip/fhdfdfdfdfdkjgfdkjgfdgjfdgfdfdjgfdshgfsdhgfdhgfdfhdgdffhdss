import 'package:flutter/material.dart';

import 'package:milliy_metr/core/theme/app_colors_extension.dart';

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
        width: 72,
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: context.colors.surface,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  iconAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.category, color: context.colors.primary),
                ),
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
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
