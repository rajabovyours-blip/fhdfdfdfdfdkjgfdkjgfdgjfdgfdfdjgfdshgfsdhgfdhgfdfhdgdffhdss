import 'package:flutter/material.dart';

import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class StoreProductsTab extends StatelessWidget {
  final String storeId;

  const StoreProductsTab({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: context.colors.textMedium,
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noProductsInStore,
            style: TextStyle(color: context.colors.textHigh, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
