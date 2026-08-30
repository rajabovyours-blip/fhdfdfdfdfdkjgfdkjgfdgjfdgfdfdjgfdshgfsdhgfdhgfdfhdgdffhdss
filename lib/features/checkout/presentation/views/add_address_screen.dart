import 'package:flutter/material.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/core/constants/uzbekistan_regions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/shared/widgets/app_button.dart';
import 'package:milliy_metr/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:milliy_metr/shared/widgets/app_snackbar.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  String label = '';
  
  RegionItem? _selectedRegion;
  DistrictItem? _selectedDistrict;

  String street = '';
  String phone = '';

  bool _isSaving = false;

  void _submit() async {
    if (_isSaving) return;
    if (_formKey.currentState!.validate() && _selectedRegion != null && _selectedDistrict != null) {
      _formKey.currentState!.save();
      
      setState(() => _isSaving = true);
      
      final String regionName = _selectedRegion!.getName(context.l10n.localeName);
      final String districtName = _selectedDistrict!.getName(context.l10n.localeName);

      final success = await ref.read(checkoutProvider.notifier).addNewAddress(
        label, regionName, districtName, street,
      );
      setState(() => _isSaving = false);

      if (success) {
        if (mounted) {
          AppSnackBar.showSuccess(context, 'Manzil muvaffaqiyatli qo\'shildi');
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          AppSnackBar.showError(context, context.l10n.errorOccurred);
        }
      }
    } else {
      if (_selectedRegion == null || _selectedDistrict == null) {
         AppSnackBar.showError(context, context.l10n.pleaseSelectRegionDistrict);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.addAddress)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: context.l10n.addressLabel,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? context.l10n.fieldRequired : null,
                onSaved: (v) => label = v!,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<RegionItem>(
                decoration: InputDecoration(
                  labelText: context.l10n.region,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                initialValue: _selectedRegion,
                items: uzbekistanRegionsData.map((region) {
                  return DropdownMenuItem(
                    value: region,
                    child: Text(region.getName(context.l10n.localeName)),
                  );
                }).toList(),
                onChanged: (RegionItem? newRegion) {
                  setState(() {
                    _selectedRegion = newRegion;
                    _selectedDistrict = null; // reset district
                  });
                },
                validator: (v) => v == null ? context.l10n.fieldRequired : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<DistrictItem>(
                decoration: InputDecoration(
                  labelText: context.l10n.district,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                initialValue: _selectedDistrict,
                items: _selectedRegion?.districts.map((district) {
                  return DropdownMenuItem(
                    value: district,
                    child: Text(district.getName(context.l10n.localeName)),
                  );
                }).toList() ?? [],
                onChanged: _selectedRegion == null ? null : (DistrictItem? newDistrict) {
                  setState(() {
                    _selectedDistrict = newDistrict;
                  });
                },
                validator: (v) => v == null ? context.l10n.fieldRequired : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: context.l10n.streetBuilding,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) => v!.isEmpty ? context.l10n.fieldRequired : null,
                onSaved: (v) => street = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: context.l10n.phoneNumber,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? context.l10n.fieldRequired : null,
                onSaved: (v) => phone = v!,
              ),
              const SizedBox(height: 32),
              _isSaving
                  ? const Center(child: CircularProgressIndicator())
                  : AppButton(
                      text: context.l10n.saveAddress,
                      onPressed: _submit,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
