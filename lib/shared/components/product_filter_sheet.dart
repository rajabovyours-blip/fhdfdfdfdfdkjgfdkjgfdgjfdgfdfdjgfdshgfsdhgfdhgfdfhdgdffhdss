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
        Row(
          children: [
            Expanded(
              child: TextFormField(
                initialValue: _currentFilters.minPrice?.round().toString() ?? '',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.priceFrom,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.colors.outline),
                  ),
                  suffixText: context.l10n.currency,
                ),
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  setState(() {
                    _currentFilters = _currentFilters.copyWith(minPrice: parsed);
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                initialValue: _currentFilters.maxPrice?.round().toString() ?? '',
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: context.l10n.priceTo,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: context.colors.outline),
                  ),
                  suffixText: context.l10n.currency,
                ),
                onChanged: (val) {
                  final parsed = double.tryParse(val);
                  setState(() {
                    _currentFilters = _currentFilters.copyWith(maxPrice: parsed);
                  });
                },
              ),
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
          context.l10n.filterSpecialOffers,
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
          title: Text(context.l10n.filterHasDiscount),
          value: _currentFilters.hasDiscount ?? false,
          onChanged: (val) => setState(() => _currentFilters = _currentFilters.copyWith(hasDiscount: val ? true : null)),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: Text(context.l10n.filterSmallWholesale),
          value: (_currentFilters.maxMoq != null && _currentFilters.maxMoq == 1),
          onChanged: (val) => setState(() => _currentFilters = _currentFilters.copyWith(maxMoq: val ? 1 : null)),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: Text(context.l10n.filterCertified),
          value: _currentFilters.hasCertificate ?? false,
          onChanged: (val) => setState(() => _currentFilters = _currentFilters.copyWith(hasCertificate: val ? true : null)),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: Text(context.l10n.filterHasDelivery),
          value: _currentFilters.hasDelivery ?? false,
          onChanged: (val) => setState(() => _currentFilters = _currentFilters.copyWith(hasDelivery: val ? true : null)),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildUnitSection() {
    final unitMap = {
      'dona': context.l10n.unitDona,
      'kg': context.l10n.unitKg,
      'metr': context.l10n.unitMetr,
      'kv.m': context.l10n.unitKvm,
      'litr': context.l10n.unitLitr,
      'komplekt': context.l10n.unitKomplekt,
      'm3': context.l10n.unitM3,
      'tonna': context.l10n.unitTonna,
      'rulon': context.l10n.unitRulon,
      'qop': context.l10n.unitQop,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.filterUnitLabel,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _units.map((u) {
            final isSelected = _currentFilters.unit == u;
            return ChoiceChip(
              label: Text(unitMap[u] ?? u),
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
        Text(
          context.l10n.filterRatingLabel,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [4.0, 3.0].map((r) {
            final isSelected = _currentFilters.minRating == r;
            return ChoiceChip(
              label: Text('$r+ ⭐'),
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
