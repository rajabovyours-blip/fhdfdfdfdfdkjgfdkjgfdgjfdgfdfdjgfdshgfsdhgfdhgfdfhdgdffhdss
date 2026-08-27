import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class HomeActionChips extends StatefulWidget {
  const HomeActionChips({super.key});

  @override
  State<HomeActionChips> createState() => _HomeActionChipsState();
}

class _HomeActionChipsState extends State<HomeActionChips> {
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Icons.local_offer_outlined, 'label': context.l10n.discountsChip},
      {'icon': Icons.local_shipping_outlined, 'label': context.l10n.expressDeliveryChip},
      {'icon': Icons.factory_outlined, 'label': context.l10n.directFactoryChip},
      {'icon': Icons.star_outline_rounded, 'label': context.l10n.popularChip},
      {'icon': Icons.handyman_outlined, 'label': context.l10n.servicesChip},
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final action = actions[index];
          final isSelected = _selectedIndex == index;

          return ActionChip(
            avatar: Icon(
              action['icon'] as IconData,
              size: 16,
              color: isSelected ? context.colors.background : context.colors.primary,
            ),
            label: Text(
              action['label'] as String,
              style: TextStyle(
                color: isSelected ? context.colors.background : context.colors.textHigh,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: isSelected ? context.colors.primary : context.colors.surface,
            side: BorderSide(color: isSelected ? context.colors.primary : context.colors.outline, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () {
              setState(() {
                if (_selectedIndex == index) {
                  _selectedIndex = -1;
                } else {
                  _selectedIndex = index;
                }
              });
            },
          );
        },
      ),
    );
  }
}
