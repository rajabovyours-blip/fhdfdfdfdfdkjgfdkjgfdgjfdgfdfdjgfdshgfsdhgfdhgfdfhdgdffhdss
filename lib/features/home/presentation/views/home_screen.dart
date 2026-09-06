import 'package:milliy_metr/core/utils/responsive_grid.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/features/home/presentation/providers/home_notifier.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';

import 'package:milliy_metr/features/home/presentation/widgets/home_header.dart';
import 'package:milliy_metr/features/home/presentation/widgets/location_selector.dart';
import 'package:milliy_metr/features/home/presentation/widgets/promotional_banner.dart';
import 'package:milliy_metr/features/home/presentation/widgets/category_carousel.dart';
import 'package:milliy_metr/features/home/presentation/widgets/section_header.dart';
import 'package:milliy_metr/shared/components/product_card.dart';

import 'package:milliy_metr/features/home/presentation/widgets/home_skeleton.dart';
import 'package:milliy_metr/features/home/presentation/widgets/home_error_state.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(homeNotifierProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: context.colors.primary,
          backgroundColor: context.colors.surface,
          onRefresh: () =>
              ref.read(homeNotifierProvider.notifier).loadHomeData(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: CustomScrollView(
                slivers: [
                  const SliverToBoxAdapter(child: HomeHeader()),
                  const SliverToBoxAdapter(child: LocationSelector()),
                  state.maybeWhen(
                    loading: () => const HomeSkeleton(),
                    error: (e) => HomeErrorState(
                      error: e,
                      onRetry: () =>
                          ref.read(homeNotifierProvider.notifier).loadHomeData(),
                    ),
                    loaded: (data) {
                      return SliverMainAxisGroup(
                        slivers: [
                          if (data.banners.isNotEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: PromotionalBanner(banners: data.banners),
                              ),
                            ),
                          SliverToBoxAdapter(
                            child: SectionHeader(
                              title: context.l10n.categories,
                              onViewAll: () {
                                context.push(AppRoutes.categories);
                              },
                            ),
                          ),
                          const SliverToBoxAdapter(
                            child: CategoryCarousel(),
                          ),
                          
                          if (data.featuredProducts.isEmpty)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 64.0),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.inventory_2_outlined, size: 64, color: context.colors.textMedium),
                                      const SizedBox(height: 16),
                                      Text(
                                        context.l10n.noProductsInStore,
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          color: context.colors.textMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          else ...[
                            SliverToBoxAdapter(
                              child: SectionHeader(
                                title: context.l10n.popularProductsSection,
                                onViewAll: () {
                                  context.push('${AppRoutes.catalog}?category_id=Barchasi');
                                },
                              ),
                            ),
                            SliverPadding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              sliver: SliverGrid(
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: responsiveCrossAxisCount(context, mobileColumns: 2),
                                  childAspectRatio: 0.63,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 16,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final product = data.featuredProducts[index];
                                    return ProductCard(
                                      product: product,
                                      showCartAction: true,
                                      onTap: () => context.push(
                                        AppRoutes.productDetails.replaceAll(':id', product.id),
                                      ),
                                    );
                                  },
                                  childCount: data.featuredProducts.length,
                                ),
                              ),
                            ),
                          ],
                          
                          // Bottom padding
                          const SliverToBoxAdapter(child: SizedBox(height: 32)),
                        ],
                      );
                    },
                    orElse: () => const HomeSkeleton(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
