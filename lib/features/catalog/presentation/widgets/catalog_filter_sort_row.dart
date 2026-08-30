import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/features/catalog/presentation/providers/catalog_notifier.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class CatalogFilterSortRow extends ConsumerWidget {
  final VoidCallback onFilterTap;
  final VoidCallback onSortTap;

  const CatalogFilterSortRow({
    super.key,
    required this.onFilterTap,
    required this.onSortTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(catalogNotifierProvider.select(
      (s) => s.maybeWhen(loading: () => true, orElse: () => false),
    ));
    // Eslatma: agar notifierda alohida "error" holati bo'lsa, shu yerga
    // shu holat uchun ham alohida tekshiruv qo'shish tavsiya etiladi -
    // hozircha xatolik holati "0 ta mahsulot" bilan bir xil ko'rinmoqda.
    final count = ref.watch(catalogNotifierProvider.select(
      (s) =>
          s.maybeWhen(loaded: (data) => data.products.length, orElse: () => 0),
    ));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _FilterSortChip(
                icon: Icons.tune,
                label: context.l10n.filter,
                onTap: onFilterTap,
              ),
              const SizedBox(width: 8),
              _FilterSortChip(
                icon: Icons.swap_vert,
                label: context.l10n.sort,
                onTap: onSortTap,
              ),
            ],
          ),
          if (isLoading)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colors.primary,
              ),
            )
          else
            Text(
              context.l10n.productCount(count),
              style: TextStyle(
                color: context.colors.textMedium,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}

/// Filter/Sort qatoridagi ikkala tugma uchun umumiy chip.
/// Ikkalasi shu yerdan boshqarilgani uchun kelajakda faqat bittasi
/// "eskicha" qolib ketish xavfi yo'q.
class _FilterSortChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _FilterSortChip({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isActive ? context.colors.primary : context.colors.outline;
    final contentColor =
        isActive ? context.colors.primary : context.colors.textHigh;

    return Material(
      color: context.colors.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: contentColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(color: contentColor, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
