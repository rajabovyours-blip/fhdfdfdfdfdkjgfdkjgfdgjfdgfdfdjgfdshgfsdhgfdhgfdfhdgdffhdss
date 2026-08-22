import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/shared/widgets/app_button.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';

class SellerStoreManagementScreen extends ConsumerStatefulWidget {
  const SellerStoreManagementScreen({super.key});

  @override
  ConsumerState<SellerStoreManagementScreen> createState() =>
      _SellerStoreManagementScreenState();
}

class _SellerStoreManagementScreenState
    extends ConsumerState<SellerStoreManagementScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _storeNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _workingHoursController = TextEditingController();
  final _deliveryInfoController = TextEditingController();
  final _returnPolicyController = TextEditingController();

  void _save() {
    if (_formKey.currentState!.validate()) {
      // backend endpoint documented: /seller/profile/update
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Store Profile Updated')));
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _workingHoursController.dispose();
    _deliveryInfoController.dispose();
    _returnPolicyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Store Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Store Branding',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.colors.outline),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.image,
                      size: 48,
                      color: context.colors.textMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload Cover Image',
                      style: TextStyle(color: context.colors.textMedium),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _storeNameController,
                decoration: const InputDecoration(labelText: 'Store Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              Text(
                'Contact & Location',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration:
                    const InputDecoration(labelText: 'Business Address'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              Text(
                'Policies',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _workingHoursController,
                decoration: const InputDecoration(
                  labelText: 'Working Hours (e.g., 09:00 - 18:00)',
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deliveryInfoController,
                decoration:
                    const InputDecoration(labelText: 'Delivery Information'),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _returnPolicyController,
                decoration: const InputDecoration(labelText: 'Return Policy'),
                maxLines: 2,
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Save Changes',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
