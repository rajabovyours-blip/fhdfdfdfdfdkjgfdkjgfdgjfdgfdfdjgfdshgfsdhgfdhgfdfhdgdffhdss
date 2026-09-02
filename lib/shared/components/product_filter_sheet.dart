import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/features/search/domain/entities/search_filter_state.dart';

class ProductFilterResult {
  final double? minPrice;
  final double? maxPrice;
  final String? brand;
  final String? unit;
  final double? minRating;
  final int? maxMoq;
  final bool? hasCertificate;
  final bool? hasDelivery;
  final bool? inStock;
  final bool? hasDiscount;
  final SortOption sortOption;

  ProductFilterResult({
    this.minPrice,
    this.maxPrice,
    this.brand,
    this.unit,
    this.minRating,
    this.maxMoq,
    this.hasCertificate,
    this.hasDelivery,
    this.inStock,
    this.hasDiscount,
    this.sortOption = SortOption.relevance,
  });

  ProductFilterResult copyWith({
    double? minPrice,
    double? maxPrice,
    String? brand,
    String? unit,
    double? minRating,
    int? maxMoq,
    bool? hasCertificate,
    bool? hasDelivery,
    bool? inStock,
    bool? hasDiscount,
    SortOption? sortOption,
  }) {
    return ProductFilterResult(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      brand: brand ?? this.brand,
      unit: unit ?? this.unit,
      minRating: minRating ?? this.minRating,
      maxMoq: maxMoq ?? this.maxMoq,
      hasCertificate: hasCertificate ?? this.hasCertificate,
      hasDelivery: hasDelivery ?? this.hasDelivery,
      inStock: inStock ?? this.inStock,
      hasDiscount: hasDiscount ?? this.hasDiscount,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

class ProductFilterSheet extends StatefulWidget {
  final ProductFilterResult initialFilters;
  final bool showSort;

  const ProductFilterSheet({
    super.key,
    required this.initialFilters,
    this.showSort = true,
  });

  static Future<ProductFilterResult?> show(BuildContext context, {required ProductFilterResult initialFilters, bool showSort = true}) {
    return showModalBottomSheet<ProductFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductFilterSheet(initialFilters: initialFilters, showSort: showSort),
    );
  }

  @override
  State<ProductFilterSheet> createState() => _ProductFilterSheetState();
}

class _ProductFilterSheetState extends State<ProductFilterSheet> {
  late ProductFilterResult _currentFilters;
  final List<String> _units = ['dona', 'kg', 'metr', 'kv.m', 'litr', 'komplekt', 'm3', 'tonna', 'rulon', 'qop'];

  @override
  void initState() {
    super.initState();
    _currentFilters = widget.initialFilters;
  }

  void _applyFilters() {
    Navigator.pop(context, _currentFilters);
  }

  void _clearFilters() {
    setState(() {
      _currentFilters = ProductFilterResult();
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
                if (widget.showSort) ...[
                  _buildSortSection(),
                  const Divider(height: 32),
                ],
                _buildPriceSection(),
                const Divider(height: 32),
                _buildAvailabilitySection(),
                const Divider(height: 32),
                _buildUnitSection(),
                const Divider(height: 32),
                _buildRatingSection(),
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
                    _currentFilters = _currentFilters.copyWith(sortOption: option);
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
            values: RangeValues(_currentFilters.minPrice ?? 0, _currentFilters.maxPrice ?? 50000000),
            min: 0,
            max: 50000000,
            divisions: 100,
            activeColor: context.colors.primary,
            inactiveColor: context.colors.outline,
            labels: RangeLabels(
              '${((_currentFilters.minPrice ?? 0) / 1000).round()} k',
              '${((_currentFilters.maxPrice ?? 50000000) / 1000).round()} k',
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
              '${(_currentFilters.maxPrice ?? 50000000).round()} ${context.l10n.currency}',
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
          "Maxsus takliflar",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: Text(context.l10n.inStockOnly),
          value: _currentFilters.inStock ?? false,
          onChanged: (val) => setState(() => _currentFilters = _currentFilters.copyWith(inStock: val ? true : null)),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: Text("Chegirma mavjud"),
          value: _currentFilters.hasDiscount ?? false,
          onChanged: (val) => setState(() => _currentFilters = _currentFilters.copyWith(hasDiscount: val ? true : null)),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: Text("Kichik miqdorda sotib olish mumkin"),
          value: (_currentFilters.maxMoq != null && _currentFilters.maxMoq == 1),
          onChanged: (val) => setState(() => _currentFilters = _currentFilters.copyWith(maxMoq: val ? 1 : null)),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: Text("Sertifikatlangan"),
          value: _currentFilters.hasCertificate ?? false,
          onChanged: (val) => setState(() => _currentFilters = _currentFilters.copyWith(hasCertificate: val ? true : null)),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: Text("Yetkazib berish mavjud"),
          value: _currentFilters.hasDelivery ?? false,
          onChanged: (val) => setState(() => _currentFilters = _currentFilters.copyWith(hasDelivery: val ? true : null)),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildUnitSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "O'lchov birligi",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _units.map((u) {
            final isSelected = _currentFilters.unit == u;
            return ChoiceChip(
              label: Text(u),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _currentFilters = _currentFilters.copyWith(unit: selected ? u : null);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Reyting",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [4.0, 3.0].map((r) {
            final isSelected = _currentFilters.minRating == r;
            return ChoiceChip(
              label: Text("$r+ ⭐"),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _currentFilters = _currentFilters.copyWith(minRating: selected ? r : null);
                });
              },
            );
          }).toList(),
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _applyFilters,
            child: Text(context.l10n.applyFilters),
          ),
        ),
      ),
    );
  }
}
