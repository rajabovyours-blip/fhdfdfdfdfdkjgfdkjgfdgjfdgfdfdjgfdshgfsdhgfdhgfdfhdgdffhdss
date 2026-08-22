import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/store/presentation/providers/store_profile_notifier.dart';
import 'package:milliy_metr/features/seller/presentation/widgets/store_products_tab.dart';
import 'package:milliy_metr/features/seller/presentation/widgets/store_reviews_tab.dart';

class StoreProfileScreen extends ConsumerWidget {
  final String storeId;

  const StoreProfileScreen({super.key, required this.storeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(storeProfileNotifierProvider(storeId));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: state.maybeWhen(
          data: (store) {
            return NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverAppBar(
                    expandedHeight: 200,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                      background: store.bannerUrl != null
                          ? Image.network(store.bannerUrl!, fit: BoxFit.cover)
                          : Container(
                              color: context.colors.surfaceVariant,
                              child: Icon(
                                Icons.store,
                                size: 80,
                                color: context.colors.textHigh,
                              ),
                            ),
                      title: Text(store.name),
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        labelColor: context.colors.primary,
                        unselectedLabelColor: context.colors.textMedium,
                        tabs: const [
                          Tab(text: 'Products'),
                          Tab(text: 'About'),
                          Tab(text: 'Reviews'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                children: [
                  StoreProductsTab(storeId: storeId),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'About Store',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(store.description),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: context.colors.textMedium,
                              ),
                              const SizedBox(width: 8),
                              Text(store.location),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 8),
                              Text(
                                '${store.rating} (${store.reviewCount} reviews)',
                              ),
                            ],
                          ),
                          if (store.isVerified) ...[
                            const SizedBox(height: 8),
                            const Row(
                              children: [
                                Icon(Icons.verified, color: Colors.blue),
                                SizedBox(width: 8),
                                Text(
                                  'Verified Store',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  StoreReviewsTab(storeId: storeId),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          orElse: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);
  final TabBar _tabBar;
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) =>
      Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: _tabBar,
      );
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
