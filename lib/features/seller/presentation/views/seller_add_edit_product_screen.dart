import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/shared/widgets/app_button.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class SellerAddEditProductScreen extends ConsumerStatefulWidget {
  final String? productId; // If null, it's add mode
  const SellerAddEditProductScreen({super.key, this.productId});

  @override
  ConsumerState<SellerAddEditProductScreen> createState() =>
      _SellerAddEditProductScreenState();
}

class _SellerAddEditProductScreenState
    extends ConsumerState<SellerAddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _moqController = TextEditingController();
  final _unitController = TextEditingController(text: 'pcs');
  final _brandController = TextEditingController();

  String? _selectedCategory; // Needs fetching from API

  @override
  void initState() {
    super.initState();
    if (widget.productId != null) {
      /* fetch product details and populate */
    }
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      // backend endpoint documented: /seller/products/create or update
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.productSavedSuccessfully)),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _moqController.dispose();
    _unitController.dispose();
    _brandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.productId == null ? 'Add Product' : 'Edit Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: context.colors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: context.colors.outline,
                    style: BorderStyle.solid,
                  ),
                ),
                child:
                    Icon(Icons.add_a_photo, color: context.colors.textMedium),
              ),
              const SizedBox(height: 24),
              Text(
                'Basic Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name (e.g., Portland Cement 50kg)',
                ),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: ['Cement', 'Rebar', 'Brick', 'Sand']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 4,
              ),
              const SizedBox(height: 24),
              Text(
                'Pricing & Inventory',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText:
                            'Price (${context.l10n.priceRange.split('(').last.replaceAll(')', '')})',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _unitController,
                      decoration: const InputDecoration(
                        labelText: 'Unit (e.g., bag, ton, pcs)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      decoration:
                          const InputDecoration(labelText: 'Stock Quantity'),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _moqController,
                      decoration: const InputDecoration(
                        labelText: 'Min Order Qty (MOQ)',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _brandController,
                decoration:
                    const InputDecoration(labelText: 'Brand (Optional)'),
              ),
              const SizedBox(height: 32),
              AppButton(
                text: 'Save Product',
                onPressed: _save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
