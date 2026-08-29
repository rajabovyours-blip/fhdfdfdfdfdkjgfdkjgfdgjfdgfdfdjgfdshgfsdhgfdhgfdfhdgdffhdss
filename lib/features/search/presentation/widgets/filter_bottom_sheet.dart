import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/search/domain/entities/search_filter_state.dart';
import 'package:milliy_metr/features/search/presentation/providers/search_notifier.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class FilterBottomSheet extends ConsumerStatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  ConsumerState<FilterBottomSheet> createState() => _FilterBottomSheetState();

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilterBottomSheet(),
    );
  }
}

class _FilterBottomSheetState extends ConsumerState<FilterBottomSheet> {
  late SearchFilterState _currentFilters;

  @override
  void initState() {
    super.initState();
    _currentFilters = ref.read(searchNotifierProvider).filters;
  }

  void _applyFilters() {
    ref.read(searchNotifierProvider.notifier).updateFilters(_currentFilters);
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _currentFilters = const SearchFilterState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSortSection(),
                const Divider(height: 32),
                _buildPriceSection(),
                const Divider(height: 32),
                _buildAvailabilitySection(),
                const Divider(height: 32),
                _buildSalesTypeSection(),
              ],
            ),
          ),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: context.colors.outline)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _clearFilters,
            child: Text(
              context.l10n.clear,
              style: TextStyle(color: context.colors.textMedium),
            ),
          ),
          Text(
            context.l10n.filter,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.sort,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: SortOption.values.map((option) {
            final isSelected = _currentFilters.sortOption == option;
            return ChoiceChip(
              label: Text(_getSortName(context, option)),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _currentFilters =
                        _currentFilters.copyWith(sortOption: option);
                  });
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getSortName(BuildContext context, SortOption option) {
    switch (option) {
      case SortOption.relevance:
        return context.l10n.sortRecommended;
      case SortOption.newest:
        return context.l10n.sortNewest;
      case SortOption.popularity:
        return context.l10n.sortRecommended;
      case SortOption.rating:
        return context.l10n.sortRating;
      case SortOption.priceLowToHigh:
        return context.l10n.sortPriceAsc;
      case SortOption.priceHighToLow:
        return context.l10n.sortPriceDesc;
    }
  }

  Widget _buildPriceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.priceRange,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            valueIndicatorTextStyle: TextStyle(
              color: context.colors.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            valueIndicatorColor: context.colors.primary,
          ),
          child: RangeSlider(
            values: RangeValues(_currentFilters.minPrice ?? 0, _currentFilters.maxPrice ?? 10000000),
            min: 0,
            max: 10000000,
            divisions: 100,
            activeColor: context.colors.primary,
            inactiveColor: context.colors.outline,
            labels: RangeLabels(
              '${((_currentFilters.minPrice ?? 0) / 1000).round()} k',
              '${((_currentFilters.maxPrice ?? 10000000) / 1000).round()} k',
            ),
            onChanged: (values) {
              setState(() {
                _currentFilters = _currentFilters.copyWith(
                  minPrice: values.start,
                  maxPrice: values.end,
                );
              });
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(_currentFilters.minPrice ?? 0).round()} ${context.l10n.currency}',
              style: TextStyle(color: context.colors.textMedium),
            ),
            Text(
              '${(_currentFilters.maxPrice ?? 10000000).round()} ${context.l10n.currency}',
              style: TextStyle(color: context.colors.textMedium),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.specialOffers,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: Text(context.l10n.inStockOnly),
          value: _currentFilters.inStock ?? false,
          onChanged: (val) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(inStock: val);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: Text(context.l10n.hasDiscount),
          value: _currentFilters.hasDiscount ?? false,
          onChanged: (val) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(hasDiscount: val);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildSalesTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.salesType,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        CheckboxListTile(
          title: Text(context.l10n.wholesale),
          value: _currentFilters.isWholesale ?? false,
          onChanged: (val) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(isWholesale: val);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: Text(context.l10n.retail),
          value: _currentFilters.isRetail ?? false,
          onChanged: (val) {
            setState(() {
              _currentFilters = _currentFilters.copyWith(isRetail: val);
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colors.surface,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _applyFilters,
          child: Text(context.l10n.applyFilters),
        ),
      ),
    );
  }
}
