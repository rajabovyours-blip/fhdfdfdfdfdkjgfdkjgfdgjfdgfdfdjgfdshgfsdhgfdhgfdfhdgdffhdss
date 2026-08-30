import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/features/catalog/presentation/providers/catalog_notifier.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class CatalogSearchBar extends ConsumerStatefulWidget {
  const CatalogSearchBar({super.key});

  @override
  ConsumerState<CatalogSearchBar> createState() => _CatalogSearchBarState();
}

class _CatalogSearchBarState extends ConsumerState<CatalogSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(catalogNotifierProvider);
      state.maybeWhen(
        loaded: (data) {
          if (data.searchQuery.isNotEmpty) {
            _controller.text = data.searchQuery;
          }
        },
        orElse: () {},
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(catalogNotifierProvider.notifier).setSearchQuery(query);
    });
  }

  void _submitSearch(String query) {
    _debounce?.cancel();
    ref.read(catalogNotifierProvider.notifier).setSearchQuery(query);
  }

  void _clearSearch() {
    _controller.clear();
    _submitSearch('');
  }

  @override
  Widget build(BuildContext context) {
    // Tashqi tomondan (masalan, "Filtrlarni tozalash" tugmasidan) o'zgargan
    // searchQuery qiymatini matn maydoniga sinxronlaydi.
    ref.listen(catalogNotifierProvider, (previous, next) {
      next.maybeWhen(
        loaded: (data) {
          if (data.searchQuery != _controller.text) {
            _controller.text = data.searchQuery;
          }
        },
        orElse: () {},
      );
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.colors.outline),
        ),
        child: TextField(
          controller: _controller,
          onChanged: _onSearchChanged,
          onSubmitted: _submitSearch,
          textInputAction: TextInputAction.search,
          style: TextStyle(color: context.colors.textHigh, fontSize: 15),
          decoration: InputDecoration(
            isDense: true,
            hintText: context.l10n.searchPlaceholder,
            hintStyle:
                TextStyle(color: context.colors.textMedium, fontSize: 15),
            prefixIcon: Icon(Icons.search, color: context.colors.textMedium),
            suffixIcon: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return IconButton(
                  icon: Icon(Icons.close, color: context.colors.textMedium),
                  onPressed: _clearSearch,
                );
              },
            ),
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }
}
