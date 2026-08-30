import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/features/home/presentation/widgets/category_item.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/categories/presentation/providers/category_notifier.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';

class CategoryCarousel extends ConsumerWidget {
  const CategoryCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoryNotifierProvider);
    // Categories specified by user
    return categoriesState.maybeWhen(
      loaded: (categories) {
        if (categories.isEmpty) return const SizedBox.shrink();
        
        // Take up to 10 categories for the home carousel
        final displayCategories = categories.take(10).toList();
        
        return SizedBox(
          height: 120,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: displayCategories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final cat = displayCategories[index];
              final String assetPath = cat.iconUrl ?? cat.imageUrl ?? '';
              
              return CategoryItem(
                title: cat.name.get(Localizations.localeOf(context).languageCode),
                iconAsset: assetPath,
                onTap: () {
                  context.go('${AppRoutes.catalog}?category_id=${cat.id}');
                },
              );
            },
          ),
        );
      },
      error: (e) => SizedBox(
        height: 96, 
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: context.colors.textMedium),
              const SizedBox(height: 4),
              Text(
                'Failed to load categories',
                style: TextStyle(color: context.colors.textMedium, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
      loading: () => const SizedBox(height: 96, child: Center(child: CircularProgressIndicator())),
      orElse: () => const SizedBox.shrink(),
    );
  }
}
