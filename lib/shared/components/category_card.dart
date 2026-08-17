import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/features/categories/domain/entities/category_entity.dart';

class CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  const CategoryCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: context.colors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: category.iconUrl != null && category.iconUrl!.isNotEmpty
              ? (category.iconUrl!.endsWith('.svg')
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SvgPicture.asset(
                        category.iconUrl!,
                        colorFilter: ColorFilter.mode(
                          context.colors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                    )
                  : Image.network(
                      category.iconUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.category,
                        color: context.colors.textMedium,
                      ),
                    ))
                  : _getSemanticIcon(category, context),
        ),
        const SizedBox(height: 8),
        Text(
          category.name.get(Localizations.localeOf(context).languageCode),
          style: TextStyle(color: context.colors.textHigh, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _getSemanticIcon(CategoryEntity category, BuildContext context) {
    final name = category.name.get('en').toLowerCase();
    IconData iconData = Icons.category;

    if (name.contains('cement') || name.contains('mortar') || name.contains('beton') || name.contains('concrete')) {
      iconData = Icons.foundation;
    } else if (name.contains('brick') || name.contains('block') || name.contains("g'isht")) {
      iconData = Icons.view_module;
    } else if (name.contains('steel') || name.contains('metal') || name.contains('armatura')) {
      iconData = Icons.hardware;
    } else if (name.contains('sand') || name.contains('gravel') || name.contains('qum')) {
      iconData = Icons.terrain;
    } else if (name.contains('roof')) {
      iconData = Icons.roofing;
    } else if (name.contains('wood') || name.contains('timber') || name.contains('board')) {
      iconData = Icons.carpenter;
    } else if (name.contains('plumb') || name.contains('pipe') || name.contains('tube')) {
      iconData = Icons.plumbing;
    } else if (name.contains('electric') || name.contains('wire') || name.contains('cable')) {
      iconData = Icons.electrical_services;
    } else if (name.contains('paint') || name.contains('finish') || name.contains("bo'yoq")) {
      iconData = Icons.format_paint;
    } else if (name.contains('tool') || name.contains('equipment') || name.contains('uskuna')) {
      iconData = Icons.handyman;
    } else if (name.contains('insulat')) {
      iconData = Icons.thermostat;
    } else if (name.contains('door') || name.contains('window')) {
      iconData = Icons.door_front_door;
    } else if (name.contains('floor') || name.contains('tile')) {
      iconData = Icons.grid_on;
    } else if (name.contains('glass')) {
      iconData = Icons.window;
    } else if (name.contains('fasten') || name.contains('nail') || name.contains('screw')) {
      iconData = Icons.build;
    }

    return Icon(
      iconData,
      color: context.colors.primary,
      size: 28,
    );
  }
}
