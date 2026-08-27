import 'package:flutter/material.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/search/presentation/providers/search_notifier.dart';
import 'package:milliy_metr/shared/components/product_card.dart';
import 'package:milliy_metr/features/search/presentation/widgets/filter_bottom_sheet.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchNotifierProvider);
    final notifier = ref.read(searchNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
          ),
          onChanged: notifier.updateQuery,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              FilterBottomSheet.show(context);
            },
          ),
        ],
      ),
      body: state.query.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state.recentSearches.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "So'nggi qidiruvlar",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: context.colors.textHigh,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          notifier.clearRecentSearches();
                        },
                        child: Text(
                          "Tozalash",
                          style: TextStyle(color: context.colors.primary),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: state.recentSearches.map((query) {
                      return ActionChip(
                        label: Text(query),
                        backgroundColor: context.colors.surfaceVariant,
                        labelStyle: TextStyle(color: context.colors.textHigh),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: context.colors.outline),
                        ),
                        onPressed: () => notifier.updateQuery(query),
                      );
                    }).toList(),
                  ),
                ],
              ],
            )
          : state.results.maybeWhen(
              loaded: (products) {
                if (products.isEmpty) {
                  return Center(child: Text(context.l10n.noSuchProductFound));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.63,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) =>
                      ProductCard(
                        product: products[index],
                        onTap: () {
                          context.push(AppRoutes.productDetails
                              .replaceFirst(':id', products[index].id),);
                        },
                      ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e) => Center(child: Text(e.toString())),
              orElse: () =>
                  Center(child: Text(context.l10n.startTypingToSearch)),
            ),
    );
  }
}
