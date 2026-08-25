import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';

class HomeActionChips extends StatelessWidget {
  const HomeActionChips({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      {'icon': Icons.local_offer_outlined, 'label': 'Aksiyalar'},
      {'icon': Icons.local_shipping_outlined, 'label': 'Tezkor yetkazish'},
      {'icon': Icons.factory_outlined, 'label': 'To\'g\'ridan-to\'g\'ri zavoddan'},
      {'icon': Icons.star_outline_rounded, 'label': 'Ommabop'},
      {'icon': Icons.handyman_outlined, 'label': 'Usta xizmati'},
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
          return ActionChip(
            avatar: Icon(
              action['icon'] as IconData,
              size: 16,
              color: context.colors.primary,
            ),
            label: Text(
              action['label'] as String,
              style: TextStyle(
                color: context.colors.textHigh,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            backgroundColor: context.colors.surface,
            side: BorderSide(color: context.colors.outline, width: 1),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onPressed: () {},
          );
        },
      ),
    );
  }
}
