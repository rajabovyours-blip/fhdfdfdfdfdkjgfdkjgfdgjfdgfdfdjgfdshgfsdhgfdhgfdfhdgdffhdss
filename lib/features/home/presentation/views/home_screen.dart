import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/home/presentation/providers/home_notifier.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';

import 'package:milliy_metr/features/home/presentation/widgets/home_header.dart';
import 'package:milliy_metr/features/home/presentation/widgets/location_selector.dart';
import 'package:milliy_metr/features/home/presentation/widgets/promotional_banner.dart';
import 'package:milliy_metr/features/home/presentation/widgets/category_carousel.dart';
import 'package:milliy_metr/features/home/presentation/widgets/section_header.dart';


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
                          child: PromotionalBanner(banners: data.banners),
                        ),
                      SliverToBoxAdapter(
                        child: SectionHeader(
                          title: context.l10n.categories,
                          onViewAll: () {},
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: CategoryCarousel(),
                      ),



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
    );
  }
}
