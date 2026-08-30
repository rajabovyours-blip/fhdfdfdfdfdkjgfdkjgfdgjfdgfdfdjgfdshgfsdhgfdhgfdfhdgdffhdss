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
        // MUHIM: ref.watch emas, ref.read. Bu ref chaqiruvchi (tashqi)
        // widgetdan olingan va showModalBottomSheet'ning builder'i o'sha
        // widgetning o'z build() metodi emas - shu sababli watch bu yerda
        // Riverpod tomonidan noto'g'ri ishlatish deb hisoblanadi va
        // runtime'da xatolik berishi yoki umuman reaktiv ishlamasligi
        // mumkin. Qiymat faqat ochilish vaqtida bir marta kerak - read
        // yetarli va xavfsiz.
        final state = ref.read(catalogNotifierProvider);
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
                // Bu yerda fon "surface", "primary" emas - shuning uchun
                // onPrimary emas, primary rangdagi matn to'g'ri (onPrimary
                // faqat primary fon ustida ishlatiladi, aks holda matn
                // deyarli ko'rinmay qolishi mumkin edi).
                color: isSelected
                    ? context.colors.primary
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
  static const double _kMinPriceBound = 0;
  static const double _kMaxPriceBound = 50000000;

  double _minPrice = _kMinPriceBound;
  double _maxPrice = _kMaxPriceBound;
  late String _selectedLocation;

  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Avval locale'ga mos "Barchasi" qiymatini standart qilib beramiz -
    // qattiq yozilgan o'zbekcha matn o'rniga (aks holda rus/ingliz tilida
    // ilova default holatda hech qaysi region tanlangandek ko'rinmasdi).
    _selectedLocation = context.l10n.all;

    final state = ref.read(catalogNotifierProvider);
    state.maybeWhen(
      loaded: (data) {
        _minPrice = data.minPrice ?? _kMinPriceBound;
        _maxPrice = data.maxPrice ?? _kMaxPriceBound;
        _selectedLocation = data.selectedLocation ?? _selectedLocation;
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
    if (cleanVal.isEmpty) {
      // Maydon bo'shatilsa, ichki holat ham eski qiymatda "osilib"
      // qolmasin - aks holda foydalanuvchi bo'sh maydon ko'radi, lekin
      // "Ko'rsatish" bosilganda eski min narx qo'llanib ketardi.
      setState(() => _minPrice = _kMinPriceBound);
      return;
    }
    final double? parsed = double.tryParse(cleanVal);
    if (parsed != null) {
      setState(() {
        _minPrice = parsed;
        if (_minPrice > _maxPrice) {
          _maxPrice = _minPrice;
          _maxPriceController.text =
              AppFormatters.formatNumber(_maxPrice.round());
        }
      });
    }
  }

  void _onMaxPriceChanged(String value) {
    final String cleanVal = value.replaceAll(' ', '');
    if (cleanVal.isEmpty) {
      setState(() => _maxPrice = _kMaxPriceBound);
      return;
    }
    final double? parsed = double.tryParse(cleanVal);
    if (parsed != null) {
      setState(() {
        _maxPrice = parsed;
        if (_maxPrice < _minPrice) {
          _minPrice = _maxPrice;
          _minPriceController.text =
              AppFormatters.formatNumber(_minPrice.round());
        }
      });
    }
  }

  InputDecoration _priceFieldDecoration(String label) {
    // Oldin bu TextField'lar hech qanday context.colors ishlatmasdi -
    // Flutter'ning default Material rangida chiqib, faylning qolgan
    // qismidan vizual farq qilardi.
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: context.colors.textMedium),
      filled: true,
      fillColor: context.colors.background,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.colors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.colors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: context.colors.primary, width: 1.5),
      ),
    );
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
                          style: TextStyle(color: context.colors.textHigh),
                          decoration:
                              _priceFieldDecoration(context.l10n.fromPrice),
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
                          style: TextStyle(color: context.colors.textHigh),
                          decoration:
                              _priceFieldDecoration(context.l10n.toPrice),
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
                        final double currentMin = _minPrice;
                        final double currentMax =
                            _maxPrice > _minPrice ? _maxPrice : _minPrice + 1;
                        // Eslatma: min/max doim 0..50 000 000 bo'lgani
                        // uchun bu ifoda amalda doim 10000ga tenglashadi
                        // (clamp shuni majburlaydi) - "dinamik" hisoblash
                        // hozircha shart emas, lekin kelajakda min/max
                        // backenddan dinamik kelsa, shu formula tayyor
                        // turadi.
                        final int divisions =
                            ((_kMaxPriceBound - _kMinPriceBound) / 1000)
                                .clamp(1, 10000)
                                .toInt();

                        return RangeSlider(
                          values: RangeValues(
                            currentMin.clamp(_kMinPriceBound, _kMaxPriceBound),
                            currentMax.clamp(_kMinPriceBound, _kMaxPriceBound),
                          ),
                          min: _kMinPriceBound,
                          max: _kMaxPriceBound,
                          divisions: divisions,
                          activeColor: context.colors.primary,
                          inactiveColor: context.colors.outline,
                          onChanged: (values) {
                            setState(() {
                              _minPrice = values.start;
                              _maxPrice = values.end;
                              _minPriceController.text =
                                  AppFormatters.formatNumber(_minPrice.round());
                              _maxPriceController.text =
                                  AppFormatters.formatNumber(_maxPrice.round());
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
                          if (selected) {
                            setState(() => _selectedLocation = loc);
                          }
                        },
                        backgroundColor: context.colors.background,
                        selectedColor: context.colors.primary,
                        labelStyle: TextStyle(
                          // Fon "primary" bo'lgani uchun matn ham shu fon
                          // uchun mo'ljallangan "onPrimary" bo'lishi kerak
                          // (textHigh emas) - xuddi shu xato quyidagi
                          // "Ko'rsatish natijalarni" tugmasida ham bor edi.
                          color: isSelected
                              ? context.colors.onPrimary
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
                          // Fon "primary", shuning uchun matn "onPrimary"
                          // bo'lishi kerak - textHigh emas (asl kodda shu
                          // yerda ham xuddi shu rang nomuvofiqligi bor edi).
                          color: context.colors.onPrimary,
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
