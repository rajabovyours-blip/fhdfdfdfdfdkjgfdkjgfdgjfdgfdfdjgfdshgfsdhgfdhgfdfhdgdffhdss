import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/categories/presentation/providers/category_notifier.dart';
import 'package:milliy_metr/shared/components/category_card.dart';
class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(categoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.categories),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(categoryNotifierProvider.notifier).loadCategories(),
        child: state.maybeWhen(
          loaded: (categories) {
            if (categories.isEmpty) {
              return Center(child: Text(context.l10n.noCategoriesAvailable));
            }
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
                  onTap: () {
                    context.push(
                      AppRoutes.categoryProducts.replaceAll(':id', category.id),
                    );
                  },
                  child: CategoryCard(category: category),
                );
              },
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
}
