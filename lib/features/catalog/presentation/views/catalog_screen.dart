import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/features/catalog/presentation/widgets/catalog_search_bar.dart';
import 'package:milliy_metr/features/categories/presentation/providers/category_notifier.dart';
import 'package:milliy_metr/shared/components/category_card.dart';
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
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              
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
                        ElevatedButton(
                          onPressed: () => ref.read(categoryNotifierProvider.notifier).loadCategories(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: context.colors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            context.l10n.retry,
                            style: TextStyle(
                              color: context.colors.textHigh,
                              fontWeight: FontWeight.w600,
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
                  
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 24.0,
                        childAspectRatio: 0.7,
                      ),
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
                            child: CategoryCard(category: category),
                          );
                        },
                        childCount: categories.length,
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
