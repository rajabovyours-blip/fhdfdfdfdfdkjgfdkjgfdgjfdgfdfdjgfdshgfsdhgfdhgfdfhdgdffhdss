import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/features/catalog/presentation/providers/catalog_notifier.dart';
import 'dart:async';
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
    setState(() {}); // update clear button visibility
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(catalogNotifierProvider.notifier).setSearchQuery(query);
    });
  }

  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(color: context.colors.textHigh, fontSize: 15),
          decoration: InputDecoration(
            hintText: context.l10n.searchPlaceholder,
            hintStyle:
                TextStyle(color: context.colors.textMedium, fontSize: 15),
            prefixIcon: Icon(Icons.search, color: context.colors.textMedium),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.close, color: context.colors.textMedium),
                    onPressed: () {
                      _controller.clear();
                      _onSearchChanged('');
                      setState(() {});
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }
}
