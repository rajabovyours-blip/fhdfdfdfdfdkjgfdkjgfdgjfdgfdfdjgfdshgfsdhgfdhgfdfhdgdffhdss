import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/location_provider.dart';
import 'package:milliy_metr/core/constants/uzbekistan_regions.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/features/search/presentation/widgets/filter_bottom_sheet.dart';

class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    'assets/images/milliy_metr_logo_transparent.png',
                    height: 32,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Milliy Metr',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: context.colors.textHigh,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.notifications_outlined,
                      color: context.colors.textHigh,
                    ),
                    onPressed: () {
                      context.push(AppRoutes.notifications);
                    },
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      context.go(AppRoutes.profile);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: context.colors.outline),
                      ),
                      child: Icon(
                        Icons.person,
                        size: 20,
                        color: context.colors.textDisabled,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Search Bar
          GestureDetector(
            onTap: () {
              context.push(AppRoutes.search);
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: context.colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.colors.outline),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.search, color: context.colors.textMedium),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      context.l10n.searchPlaceholder,
                      style: TextStyle(
                        color: context.colors.textMedium,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 24,
                    color: context.colors.outline,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  IconButton(
                    icon: Icon(Icons.tune, color: context.colors.textDisabled),
                    onPressed: () {
                      FilterBottomSheet.show(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
