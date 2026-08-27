import re

file_path = r'c:\Users\rajab\OneDrive\Desktop\MilliyMetr\lib\features\catalog\presentation\widgets\catalog_bottom_sheets.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add imports
if 'package:flutter/services.dart' not in content:
    content = content.replace("import 'package:flutter/material.dart';", "import 'package:flutter/material.dart';\nimport 'package:flutter/services.dart';\nimport 'package:milliy_metr/core/utils/app_formatters.dart';\nimport 'package:milliy_metr/core/utils/thousands_separator_input_formatter.dart';")

# Replace _FilterSheetContentState
state_pattern = re.compile(r'class _FilterSheetContentState extends ConsumerState<_FilterSheetContent> \{.*?(?=\n                  const SizedBox\(height: 32\),)', re.DOTALL)

replacement = '''class _FilterSheetContentState extends ConsumerState<_FilterSheetContent> {
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
    String cleanVal = value.replaceAll(' ', '');
    double? parsed = double.tryParse(cleanVal);
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
    String cleanVal = value.replaceAll(' ', '');
    double? parsed = double.tryParse(cleanVal);
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
    final locations = [
      context.l10n.all,
      'Farg‘ona',
      'Toshkent',
      'Andijon',
      'Namangan',
      'Samarqand',
      'Buxoro',
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
                            labelText: "Dan (so'm)",
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
                            labelText: "Gacha (so'm)",
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
                  ),'''

content = re.sub(state_pattern, replacement, content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
