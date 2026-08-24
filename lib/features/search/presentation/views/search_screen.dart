import 'package:flutter/material.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/search/presentation/providers/search_notifier.dart';
import 'package:milliy_metr/shared/components/product_card.dart';
import 'package:milliy_metr/features/search/presentation/widgets/filter_bottom_sheet.dart';

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
              children: [
                if (state.recentSearches.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Recent Searches',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...state.recentSearches.map(
                    (query) => ListTile(
                      leading: const Icon(Icons.history),
                      title: Text(query),
                      onTap: () => notifier.updateQuery(query),
                    ),
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
                    childAspectRatio: 0.68,
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
