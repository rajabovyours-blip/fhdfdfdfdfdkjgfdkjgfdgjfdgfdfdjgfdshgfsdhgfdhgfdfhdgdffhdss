import 'package:flutter/material.dart';


import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/features/categories/domain/entities/category_entity.dart';
import 'package:milliy_metr/features/categories/utils/category_asset_helper.dart';

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
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: context.colors.surfaceVariant,
            shape: BoxShape.circle,
          ),
          child: Builder(
            builder: (context) {
              final assetPath = CategoryAssetHelper.getAssetPath(
                category.id,
                category.name.get('en'),
              );

              return Image.asset(
                assetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    CategoryCard.getSemanticIconWidget(category, context),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          category.name.get(Localizations.localeOf(context).languageCode),
          style: TextStyle(color: context.colors.textHigh, fontSize: 12),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  static Widget getSemanticIconWidget(CategoryEntity category, BuildContext context, {double size = 28}) {
    final name = category.name.get('en').toLowerCase();
    IconData iconData = Icons.category;

    if (name.contains('cement') || name.contains('mortar') || name.contains('beton') || name.contains('concrete')) {
      iconData = Icons.foundation;
    } else if (name.contains('brick') || name.contains('block') || name.contains("g'isht")) {
      iconData = Icons.view_module;
    } else if (name.contains('steel') || name.contains('metal') || name.contains('armatura') || name.contains('rebar')) {
      iconData = Icons.hardware;
    } else if (name.contains('sand') || name.contains('gravel') || name.contains('qum') || name.contains('aggregate')) {
      iconData = Icons.terrain;
    } else if (name.contains('roof')) {
      iconData = Icons.roofing;
    } else if (name.contains('wood') || name.contains('timber') || name.contains('board') || name.contains('lumber')) {
      iconData = Icons.carpenter;
    } else if (name.contains('plumb') || name.contains('pipe') || name.contains('tube')) {
      iconData = Icons.plumbing;
    } else if (name.contains('electric') || name.contains('wire') || name.contains('cable') || name.contains('lighting') || name.contains('lamp')) {
      iconData = Icons.electrical_services;
    } else if (name.contains('paint') || name.contains('finish') || name.contains("bo'yoq")) {
      iconData = Icons.format_paint;
    } else if (name.contains('tool') || name.contains('equipment') || name.contains('uskuna')) {
      iconData = Icons.handyman;
    } else if (name.contains('insulat')) {
      iconData = Icons.thermostat;
    } else if (name.contains('door') || name.contains('window')) {
      iconData = Icons.door_front_door;
    } else if (name.contains('floor') || name.contains('tile') || name.contains('laminate')) {
      iconData = Icons.grid_on;
    } else if (name.contains('glass')) {
      iconData = Icons.window;
    } else if (name.contains('fasten') || name.contains('nail') || name.contains('screw') || name.contains('bolt')) {
      iconData = Icons.build;
    } else if (name.contains('drywall') || name.contains('gypsum')) {
      iconData = Icons.web_asset;
    } else if (name.contains('sealant') || name.contains('adhesive') || name.contains('glue')) {
      iconData = Icons.water_drop;
    } else if (name.contains('waterproof')) {
      iconData = Icons.umbrella;
    } else if (name.contains('ventil') || name.contains('hvac') || name.contains('heating')) {
      iconData = Icons.air;
    } else if (name.contains('safet') || name.contains('protect')) {
      iconData = Icons.health_and_safety;
    } else if (name.contains('ladder') || name.contains('scaffold')) {
      iconData = Icons.stairs;
    } else if (name.contains('measur')) {
      iconData = Icons.straighten;
    } else if (name.contains('garden') || name.contains('landscape')) {
      iconData = Icons.park;
    } else if (name.contains('decor') || name.contains('wallpaper')) {
      iconData = Icons.wallpaper;
    }

    return Icon(
      iconData,
      color: context.colors.primary,
      size: size,
    );
  }
}
