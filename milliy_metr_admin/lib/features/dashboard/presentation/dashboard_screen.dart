import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text('dashboard'.tr()),
        actions: [
          DropdownButton<Locale>(
            value: context.locale,
            icon: const Icon(Icons.language),
            underline: const SizedBox(),
            onChanged: (Locale? newLocale) {
              if (newLocale != null) {
                context.setLocale(newLocale);
              }
            },
            items: const [
              DropdownMenuItem(
                value: Locale('uz'),
                child: Text('O\'zbek'),
              ),
              DropdownMenuItem(
                value: Locale('ru'),
                child: Text('Русский'),
              ),
            ],
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          _buildCard(context, 'users'.tr(), Icons.people, '/users'),
          _buildCard(context, 'products'.tr(), Icons.inventory, '/products'),
          _buildCard(context, 'categories'.tr(), Icons.category, '/categories'),
          _buildCard(context, 'banners'.tr(), Icons.image, '/banners'),
          _buildCard(context, 'reviews'.tr(), Icons.star_rate, '/reviews'),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, String route) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
