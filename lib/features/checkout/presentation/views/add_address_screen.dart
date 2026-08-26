import 'package:flutter/material.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/shared/widgets/app_button.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  const AddAddressScreen({super.key});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  String label = '';
  String region = '';
  String district = '';
  String street = '';
  String phone = '';

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add address backend integration missing (POST /addresses required)',
          ),
        ),
      );
      Navigator.of(context).pop();
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
                ),
                validator: (v) => v!.isEmpty ? context.l10n.fieldRequired : null,
                onSaved: (v) => label = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: context.l10n.region),
                validator: (v) => v!.isEmpty ? context.l10n.fieldRequired : null,
                onSaved: (v) => region = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: context.l10n.district),
                validator: (v) => v!.isEmpty ? context.l10n.fieldRequired : null,
                onSaved: (v) => district = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: context.l10n.streetBuilding),
                validator: (v) => v!.isEmpty ? context.l10n.fieldRequired : null,
                onSaved: (v) => street = v!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: context.l10n.phoneNumber),
                keyboardType: TextInputType.phone,
                validator: (v) => v!.isEmpty ? context.l10n.fieldRequired : null,
                onSaved: (v) => phone = v!,
              ),
              const SizedBox(height: 32),
              AppButton(
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
