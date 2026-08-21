import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/features/catalog/presentation/widgets/catalog_search_bar.dart';
import 'package:milliy_metr/features/categories/presentation/providers/category_notifier.dart';

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
                  
                  // Clean vertical list — one row per category
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = categories[index];
                        return InkWell(
                          key: Key('category_card_${category.id}'),
                          onTap: () {
                            context.push(
                              AppRoutes.categoryProducts.replaceAll(':id', category.id),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: context.colors.outline.withValues(alpha: 0.3),
                                  width: 0.5,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Category Image
                                Container(
                                  width: 48,
                                  height: 48,
                                  clipBehavior: Clip.hardEdge,
                                  decoration: BoxDecoration(
                                    color: context.colors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: category.iconUrl != null
                                      ? Image.asset(
                                          category.iconUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) =>
                                              Icon(Icons.category, color: context.colors.primary),
                                        )
                                      : Icon(Icons.category, color: context.colors.primary),
                                ),
                                const SizedBox(width: 14),
                                // Category name
                                Expanded(
                                  child: Text(
                                    category.name.get(
                                      Localizations.localeOf(context).languageCode,
                                    ),
                                    style: TextStyle(
                                      color: context.colors.textHigh,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Chevron
                                Icon(
                                  Icons.chevron_right,
                                  color: context.colors.textDisabled,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: categories.length,
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: true,
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
