import 'dart:convert';
import 'dart:io';
import 'package:milliy_metr/features/products/data/models/product_model.dart';

void main() async {
  final file = File('test_products_output.json');
  final jsonString = await file.readAsString();
  final jsonMap = jsonDecode(jsonString);
  try {
    final model = ProductModel.fromJson(jsonMap);
    print('Success: ${model.id}');
  } catch (e, st) {
    print('Error: $e');
    print(st);
  }
}
