import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../core/providers/admin_providers.dart';

class BannersScreen extends ConsumerWidget {
  const BannersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bannersAsyncValue = ref.watch(bannersProvider);

    return Scaffold(
      appBar: AppBar(title: Text('banners'.tr())),
      body: bannersAsyncValue.when(
        data: (banners) {
          if (banners.isEmpty) {
            return Center(child: Text('no_data'.tr()));
          }
          return ListView.builder(
            itemCount: banners.length,
            itemBuilder: (context, index) {
              final banner = banners[index];
              return ListTile(
                leading: banner['image_url'] != null
                    ? Image.network(banner['image_url'], width: 80, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image))
                    : const Icon(Icons.image),
                title: Text(banner['title'] ?? 'Banner'),
                subtitle: Text(banner['link'] ?? 'No link'),
              );
            },
          );
        },
        loading: () => Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('loading'.tr()),
          ],
        )),
        error: (error, stack) => Center(child: Text('${'error'.tr()}: $error')),
      ),
    );
  }
}
