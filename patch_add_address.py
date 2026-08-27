import re

file_path = r'c:\Users\rajab\OneDrive\Desktop\MilliyMetr\lib\features\checkout\presentation\views\add_address_screen.dart'
with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add import
if 'uzbekistan_regions.dart' not in content:
    content = content.replace("import 'package:milliy_metr/l10n/l10n_extension.dart';", "import 'package:milliy_metr/l10n/l10n_extension.dart';\nimport 'package:milliy_metr/core/constants/uzbekistan_regions.dart';")

state_replacement = '''class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  String label = '';
  
  RegionItem? _selectedRegion;
  DistrictItem? _selectedDistrict;

  String street = '';
  String phone = '';

  bool _isSaving = false;

  void _submit() async {
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
          AppSnackBar.showSuccess(context, 'Manzil muvaffaqiyatli qo\\'shildi');
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          AppSnackBar.showError(context, 'Xatolik yuz berdi');
        }
      }
    } else {
      if (_selectedRegion == null || _selectedDistrict == null) {
         AppSnackBar.showError(context, 'Iltimos, viloyat va tumanni tanlang');
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
                value: _selectedRegion,
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
                value: _selectedDistrict,
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
}'''

state_pattern = re.compile(r'class _AddAddressScreenState extends ConsumerState<AddAddressScreen> \{.*\}', re.DOTALL)
content = re.sub(state_pattern, state_replacement, content)

with open(file_path, 'w', encoding='utf-8') as f:
    f.write(content)
