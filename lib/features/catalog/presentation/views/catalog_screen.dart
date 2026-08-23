import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/features/catalog/presentation/widgets/catalog_search_bar.dart';
import 'package:milliy_metr/features/categories/presentation/providers/category_notifier.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryNotifierProvider.notifier).loadCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryNotifierProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        title: Text(
          context.l10n.catalog,
          style: TextStyle(
            color: context.colors.textHigh,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: context.colors.primary,
          backgroundColor: context.colors.surface,
          onRefresh: () => ref.read(categoryNotifierProvider.notifier).loadCategories(),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: CatalogSearchBar()),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              
              state.maybeWhen(
                loading: () => SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  ),
                ),
                error: (e) => SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: context.colors.danger,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.errorOccurred,
                          style: TextStyle(
                            color: context.colors.textHigh,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 44,
                          child: ElevatedButton(
                            onPressed: () => ref.read(categoryNotifierProvider.notifier).loadCategories(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.colors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              context.l10n.retry,
                              style: TextStyle(
                                color: context.colors.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                loaded: (categories) {
                  if (categories.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          context.l10n.categoriesNotFound,
                          style: TextStyle(color: context.colors.textHigh),
                        ),
                      ),
                    );
                  }
                  
                  // 3-column grid layout
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.75, // Adjust for image and 2 lines of text
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final category = categories[index];
                          return InkWell(
                            key: Key('category_card_${category.id}'),
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              context.push(
                                AppRoutes.categoryProducts.replaceAll(':id', category.id),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Category Image
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    clipBehavior: Clip.hardEdge,
                                    decoration: BoxDecoration(
                                      color: context.colors.surfaceVariant,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: context.colors.outline.withValues(alpha: 0.1),
                                        width: 1,
                                      ),
                                    ),
                                    child: category.iconUrl != null && category.iconUrl!.isNotEmpty
                                        ? (category.iconUrl!.startsWith('assets/')
                                            ? Image.asset(
                                                category.iconUrl!,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) =>
                                                    Icon(Icons.category, color: context.colors.primary, size: 28),
                                              )
                                            : CachedNetworkImage(
                                                imageUrl: category.iconUrl!,
                                                fit: BoxFit.cover,
                                                memCacheWidth: 150,
                                                memCacheHeight: 150,
                                                errorWidget: (_, __, ___) =>
                                                    Icon(Icons.category, color: context.colors.primary, size: 28),
                                              ))
                                        : Icon(Icons.category, color: context.colors.primary, size: 28),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Category name
                                Text(
                                  category.name.get(
                                    Localizations.localeOf(context).languageCode,
                                  ),
                                  style: TextStyle(
                                    color: context.colors.textHigh,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    height: 1.2,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          );
                        },
                        childCount: categories.length,
                        addAutomaticKeepAlives: false,
                        addRepaintBoundaries: true,
                      ),
                    ),
                  );
                },
                orElse: () => SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
