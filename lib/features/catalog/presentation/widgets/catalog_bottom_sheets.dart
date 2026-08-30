import 'package:milliy_metr/core/constants/uzbekistan_regions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:milliy_metr/core/utils/app_formatters.dart';
import 'package:milliy_metr/core/utils/thousands_separator_input_formatter.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/catalog/presentation/providers/catalog_notifier.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class CatalogBottomSheets {
  static void showSortSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final state = ref.watch(catalogNotifierProvider);
        final currentSort = state.maybeWhen(
          loaded: (data) => data.sortOption,
          orElse: () => null,
        );

        Widget buildSortOption(String label, String value) {
          final isSelected = currentSort == value;
          return ListTile(
            title: Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? context.colors.onPrimary
                    : context.colors.textHigh,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            trailing: isSelected
                ? Icon(Icons.check, color: context.colors.primary)
                : null,
            onTap: () {
              ref.read(catalogNotifierProvider.notifier).setSortOption(value);
              Navigator.pop(context);
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  context.l10n.sort,
                  style: TextStyle(
                    color: context.colors.textHigh,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Divider(color: context.colors.outline, height: 1),
              buildSortOption(context.l10n.sortRecommended, 'recommended'),
              buildSortOption(context.l10n.sortPriceAsc, 'price_asc'),
              buildSortOption(context.l10n.sortPriceDesc, 'price_desc'),
              buildSortOption(context.l10n.sortNewest, 'newest'),
              buildSortOption(context.l10n.sortRating, 'rating'),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  static void showFilterSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const _FilterSheetContent();
      },
    );
  }
}

class _FilterSheetContent extends ConsumerStatefulWidget {
  const _FilterSheetContent();

  @override
  ConsumerState<_FilterSheetContent> createState() =>
      _FilterSheetContentState();
}

class _FilterSheetContentState extends ConsumerState<_FilterSheetContent> {
  double _minPrice = 0;
  double _maxPrice = 50000000;
  String _selectedLocation = 'Barchasi';
  
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final state = ref.read(catalogNotifierProvider);
    state.maybeWhen(
      loaded: (data) {
        _minPrice = data.minPrice ?? 0;
        _maxPrice = data.maxPrice ?? 50000000;
        _selectedLocation = data.selectedLocation ?? 'Barchasi';
      },
      orElse: () {},
    );
    _minPriceController.text = AppFormatters.formatNumber(_minPrice.round());
    _maxPriceController.text = AppFormatters.formatNumber(_maxPrice.round());
  }

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  void _onMinPriceChanged(String value) {
    final String cleanVal = value.replaceAll(' ', '');
    final double? parsed = double.tryParse(cleanVal);
    if (parsed != null) {
      setState(() {
        _minPrice = parsed;
        if (_minPrice > _maxPrice) {
          _maxPrice = _minPrice;
          _maxPriceController.text = AppFormatters.formatNumber(_maxPrice.round());
        }
      });
    }
  }

  void _onMaxPriceChanged(String value) {
    final String cleanVal = value.replaceAll(' ', '');
    final double? parsed = double.tryParse(cleanVal);
    if (parsed != null) {
      setState(() {
        _maxPrice = parsed;
        if (_maxPrice < _minPrice) {
          _minPrice = _maxPrice;
          _minPriceController.text = AppFormatters.formatNumber(_minPrice.round());
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    
    final locations = [
      context.l10n.all,
      ...uzbekistanRegionsData.map((r) => r.getName(locale)),
    ];
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (_, controller) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    context.l10n.filter,
                    style: TextStyle(
                      color: context.colors.textHigh,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: context.colors.textHigh),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Divider(color: context.colors.outline, height: 1),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(20.0),
                children: [
                  Text(
                    context.l10n.priceRange,
                    style: TextStyle(
                      color: context.colors.textHigh,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            ThousandsSeparatorInputFormatter(),
                          ],
                          decoration: InputDecoration(
                            labelText: context.l10n.fromPrice,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onChanged: _onMinPriceChanged,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            ThousandsSeparatorInputFormatter(),
                          ],
                          decoration: InputDecoration(
                            labelText: context.l10n.toPrice,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onChanged: _onMaxPriceChanged,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      minThumbSeparation: 100,
                      valueIndicatorTextStyle: TextStyle(
                        color: context.colors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                      valueIndicatorColor: context.colors.primary,
                    ),
                    child: Builder(
                      builder: (context) {
                        const double minVal = 0;
                        const double maxVal = 50000000;
                        final double currentMin = _minPrice;
                        final double currentMax = _maxPrice > _minPrice ? _maxPrice : _minPrice + 1;
                        int divisions = ((maxVal - minVal) / 1000).clamp(1, 10000).toInt();
                        if (divisions < 1) divisions = 1;

                        return RangeSlider(
                          values: RangeValues(currentMin.clamp(minVal, maxVal), currentMax.clamp(minVal, maxVal)),
                          min: minVal,
                          max: maxVal,
                          divisions: divisions,
                          activeColor: context.colors.primary,
                          inactiveColor: context.colors.outline,
                          onChanged: (values) {
                            setState(() {
                              _minPrice = values.start;
                              _maxPrice = values.end;
                              _minPriceController.text = AppFormatters.formatNumber(_minPrice.round());
                              _maxPriceController.text = AppFormatters.formatNumber(_maxPrice.round());
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    context.l10n.region,
                    style: TextStyle(
                      color: context.colors.textHigh,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: locations.map((loc) {
                      final isSelected = _selectedLocation == loc;
                      return ChoiceChip(
                        label: Text(loc),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedLocation = loc);
                        },
                        backgroundColor: context.colors.background,
                        selectedColor: context.colors.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? context.colors.textHigh
                              : context.colors.textMedium,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? context.colors.primary
                              : context.colors.outline,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.colors.surface,
                border: Border(top: BorderSide(color: context.colors.outline)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref
                            .read(catalogNotifierProvider.notifier)
                            .clearFilters();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: context.colors.outline),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        context.l10n.clear,
                        style: TextStyle(color: context.colors.textHigh),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(catalogNotifierProvider.notifier).setFilters(
                              minPrice: _minPrice,
                              maxPrice: _maxPrice,
                              location: _selectedLocation,
                            );
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        context.l10n.showResults,
                        style: TextStyle(
                          color: context.colors.textHigh,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
