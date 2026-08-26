import 'package:flutter/material.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:milliy_metr/features/checkout/presentation/providers/checkout_provider.dart';

class AddressListScreen extends ConsumerStatefulWidget {
  const AddressListScreen({super.key});

  @override
  ConsumerState<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends ConsumerState<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(checkoutProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(checkoutProvider);
    final notifier = ref.read(checkoutProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.myAddresses)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.addresses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final address = state.addresses[index];
                return Card(
                  child: ListTile(
                    leading: Icon(
                      address.addressType == 'Home'
                          ? Icons.home
                          : address.addressType == 'Office'
                              ? Icons.work
                              : address.addressType == 'Construction Site'
                                  ? Icons.construction
                                  : Icons.location_on,
                    ),
                    title: Text(
                      '${address.label} ${address.isDefault ? '(Default)' : ''}',
                    ),
                    subtitle: Text(
                      '${address.region}, ${address.district}, ${address.street}, ${address.building}, ${address.apartment}',
                    ),
                    trailing: address.id == state.selectedAddress?.id
                        ? Icon(Icons.check_circle, color: context.colors.primary)
                        : null,
                    onTap: () {
                      notifier.setAddress(address);
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFFF7A00),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () {
          context.push('/add-address');
        },
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}
