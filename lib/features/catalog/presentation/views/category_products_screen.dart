import 'package:milliy_metr/core/utils/responsive_grid.dart';
import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/shared/components/product_card.dart';
import 'package:milliy_metr/features/catalog/presentation/providers/catalog_notifier.dart';
import 'package:milliy_metr/features/catalog/presentation/widgets/catalog_search_bar.dart';
import 'package:milliy_metr/features/catalog/presentation/widgets/catalog_filter_sort_row.dart';
import 'package:milliy_metr/features/catalog/presentation/widgets/catalog_bottom_sheets.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class CategoryProductsScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String? filterOption;

  const CategoryProductsScreen({
    super.key, 
    required this.categoryId,
    this.filterOption,
  });

  @override
  ConsumerState<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends ConsumerState<CategoryProductsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(catalogNotifierProvider.notifier);
      notifier.clearFilters();
      
      if (widget.filterOption != null) {
        if (widget.filterOption == 'popular') {
          notifier.setSortOption('popular');
        } else if (widget.filterOption == 'discount') {
          // Just as an example, this triggers fetch
          notifier.setSortOption('discount'); 
        }
      }
      notifier.setCategory(widget.categoryId);
    });
    
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(catalogNotifierProvider.notifier).loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogNotifierProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.colors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: context.colors.textHigh,
          ),
          onPressed: () {
            ref.read(catalogNotifierProvider.notifier).clearFilters();
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.catalog);
            }
          },
        ),
        title: Text(
          context.l10n.catalog,
          style: TextStyle(
            color: context.colors.textHigh,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.tune, color: context.colors.textHigh),
            onPressed: () => CatalogBottomSheets.showFilterSheet(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: context.colors.primary,
          backgroundColor: context.colors.surface,
          onRefresh: () => ref
              .read(catalogNotifierProvider.notifier)
              .loadProducts(refresh: true),
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              const SliverToBoxAdapter(child: CatalogSearchBar()),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),

              SliverToBoxAdapter(
                child: CatalogFilterSortRow(
                  onFilterTap: () =>
                      CatalogBottomSheets.showFilterSheet(context, ref),
                  onSortTap: () =>
                      CatalogBottomSheets.showSortSheet(context, ref),
                ),
              ),

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
                          context.l10n.errorLoadingProducts,
                          style: TextStyle(
                            color: context.colors.textHigh,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref
                              .read(catalogNotifierProvider.notifier)
                              .loadProducts(refresh: true),
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
                loaded: (data) {
                  if (data.products.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.inventory_2_outlined,
                              size: 56,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              context.l10n.noSuchProductFound,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(catalogNotifierProvider.notifier).clearFilters();
                                if (Navigator.of(context).canPop()) {
                                  Navigator.pop(context);
                                } else {
                                  context.go(AppRoutes.catalog);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.colors.primary,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                context.l10n.catalog,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverMainAxisGroup(
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        sliver: SliverLayoutBuilder(
                          builder: (context, constraints) {
                            return SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: responsiveCrossAxisCount(context, mobileColumns: 2),
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.63,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final product = data.products[index];
                                  return ProductCard(
                                    key: Key('product_card_${product.id}'),
                                    product: product,
                                    onTap: () {
                                      context.push(
                                        AppRoutes.productDetails
                                            .replaceAll(':id', product.id),
                                      );
                                    },
                                  );
                                },
                                childCount: data.products.length,
                              ),
                            );
                          },
                        ),
                      ),
                      if (!data.hasReachedMax)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: context.colors.primary,
                              ),
                            ),
                          ),
                        ),
                    ],
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
              ), // Bottom nav padding
            ],
          ),
        ),
      ),
    );
  }
}
