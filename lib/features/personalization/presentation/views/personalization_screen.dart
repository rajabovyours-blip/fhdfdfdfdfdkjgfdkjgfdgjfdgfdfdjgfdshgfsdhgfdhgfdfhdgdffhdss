import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/shared/widgets/app_button.dart';
import 'package:milliy_metr/core/storage/preferences.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/features/categories/presentation/providers/category_notifier.dart';
import 'package:milliy_metr/features/categories/domain/entities/category_entity.dart';

class PersonalizationScreen extends ConsumerStatefulWidget {
  const PersonalizationScreen({super.key});

  @override
  ConsumerState<PersonalizationScreen> createState() =>
      _PersonalizationScreenState();
}

class _PersonalizationScreenState extends ConsumerState<PersonalizationScreen> {
  final Set<String> _selectedCategories = {};

  void _toggleCategory(String categoryId) {
    setState(() {
      if (_selectedCategories.contains(categoryId)) {
        _selectedCategories.remove(categoryId);
      } else {
        _selectedCategories.add(categoryId);
      }
    });
  }

  Future<void> _savePreferencesAndContinue() async {
    // Save to SharedPreferences or state management
    await PreferencesManager.setStringList(
      'preferred_categories',
      _selectedCategories.toList(),
    );

    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.personalizeYourFeed),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.whatMaterials,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.selectCategories,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: context.colors.textDisabled),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: categoriesState.maybeWhen(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (msg) => Center(child: Text(msg)),
                  loaded: (categories) {
                    if (categories.isEmpty) {
                      return Center(child: Text(context.l10n.noCategoriesAvailable));
                    }
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final category = categories[index];
                        final isSelected = _selectedCategories.contains(category.id);
                        return _buildCategoryCard(context, category, isSelected);
                      },
                    );
                  },
                  orElse: () => const Center(child: CircularProgressIndicator()),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                text: context.l10n.continueAction,
                onPressed: _selectedCategories.isNotEmpty
                    ? _savePreferencesAndContinue
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
      BuildContext context, CategoryEntity category, bool isSelected,) {

    final bgColor = isSelected
        ? context.colors.primary.withValues(alpha: 0.1)
        : context.colors.surfaceVariant;
    final borderColor =
        isSelected ? context.colors.primary : Colors.transparent;
    final textColor = isSelected
        ? context.colors.primary
        : context.colors.textHigh;
    final iconColor = isSelected
        ? context.colors.primary
        : context.colors.textHigh;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _toggleCategory(category.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (category.iconUrl != null && category.iconUrl!.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: category.iconUrl!.endsWith('.svg')
                        ? SvgPicture.asset(
                            category.iconUrl!,
                            colorFilter: ColorFilter.mode(
                              iconColor,
                              BlendMode.srcIn,
                            ),
                          )
                        : Image.network(
                            category.iconUrl!,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              Icons.category,
                              color: iconColor,
                              size: 40,
                            ),
                          ),
                  ),
                )
              else
                Expanded(
                  child: Icon(
                    Icons.category,
                    color: iconColor,
                    size: 40,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                category.name.get(Localizations.localeOf(context).languageCode),
                style: TextStyle(
                  color: textColor,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
