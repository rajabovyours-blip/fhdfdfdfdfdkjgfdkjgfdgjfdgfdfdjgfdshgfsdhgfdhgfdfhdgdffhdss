import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/shared/components/category_card.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/features/catalog/presentation/widgets/catalog_search_bar.dart';
import 'package:milliy_metr/features/catalog/presentation/providers/catalog_notifier.dart';
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
              SliverToBoxAdapter(child: CatalogSearchBar()),
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
                  final catalogState = ref.watch(catalogNotifierProvider);
                  final searchQuery = catalogState.maybeWhen(
                    loaded: (data) => data.searchQuery,
                    orElse: () => '',
                  );

                  var displayCategories = categories;
                  if (searchQuery.isNotEmpty) {
                    final locale = Localizations.localeOf(context).languageCode;
                    final queryLower = searchQuery.toLowerCase();
                    displayCategories = categories.where((c) {
                      final nameStr = c.name.get(locale).toLowerCase();
                      return nameStr.contains(queryLower);
                    }).toList();
                  }

                  if (displayCategories.isEmpty) {
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
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.74,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final category = displayCategories[index];
                          return InkWell(
                            key: Key('category_card_${category.id}'),
                            borderRadius: BorderRadius.circular(12),
                            onTap: () {
                              context.push(
                                AppRoutes.categoryProducts.replaceAll(':id', category.id),
                              );
                            },
                            child: CategoryCard(category: category),
                          );
                        },
                        childCount: displayCategories.length,
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
