import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/categories/presentation/providers/category_notifier.dart';
import 'package:milliy_metr/shared/components/category_card.dart';
import 'package:milliy_metr/features/categories/domain/entities/category_entity.dart';
class CategoriesScreen extends ConsumerWidget {
  final CategoryEntity? parentCategory;
  
  const CategoriesScreen({super.key, this.parentCategory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(parentCategory != null ? parentCategory!.name.get(Localizations.localeOf(context).languageCode) : context.l10n.categories),
        leading: Navigator.of(context).canPop()
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => context.pop(),
              )
            : null,
      ),
      body: parentCategory != null
          ? _buildCategoryList(context, parentCategory!.subcategories)
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(categoryNotifierProvider.notifier).loadCategories(),
              child: state.maybeWhen(
                loaded: (categories) {
                  if (categories.isEmpty) {
                    return Center(child: Text(context.l10n.noCategoriesAvailable));
                  }
                  
                  final featured = categories.where((c) => c.isFeatured).toList();
                  
                  return CustomScrollView(
                    slivers: [
                      if (featured.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Text(
                              "Ommabop kategoriyalar",
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: SizedBox(
                            height: 140,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: featured.length,
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  width: 120,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    child: InkWell(
                                      onTap: () => _onCategoryTap(context, featured[index]),
                                      child: CategoryCard(category: featured[index]),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                            child: Text(
                              "Barcha kategoriyalar",
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.8,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final category = categories[index];
                              return InkWell(
                                onTap: () => _onCategoryTap(context, category),
                                child: CategoryCard(category: category),
                              );
                            },
                            childCount: categories.length,
                          ),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $e'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => ref
                            .read(categoryNotifierProvider.notifier)
                            .loadCategories(),
                        child: Text(context.l10n.retry),
                      ),
                    ],
                  ),
                ),
                orElse: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
    );
  }

  void _onCategoryTap(BuildContext context, CategoryEntity category) {
    if (category.subcategories.isNotEmpty) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => CategoriesScreen(parentCategory: category),
      ));
    } else {
      context.push(
        AppRoutes.categoryProducts.replaceAll(':id', category.id),
      );
    }
  }

  Widget _buildCategoryList(BuildContext context, List<CategoryEntity> categories) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.8,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return InkWell(
          onTap: () => _onCategoryTap(context, category),
          child: CategoryCard(category: category),
        );
      },
    );
  }
}

