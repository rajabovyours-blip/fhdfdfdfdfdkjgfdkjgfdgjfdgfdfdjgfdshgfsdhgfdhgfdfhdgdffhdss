import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  static const separator = ' '; // Space separator

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue,) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }
    
    final String newValueText = newValue.text.replaceAll(separator, '');
    if (newValueText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    int selectionIndex = newValue.selection.end;
    final int oldLength = newValue.text.length;

    // Parse the value
    final int? parsedValue = int.tryParse(newValueText);
    if (parsedValue == null) {
      return oldValue;
    }

    // Format the value
    final formatter = NumberFormat('#,###', 'en_US');
    final String newText = formatter.format(parsedValue).replaceAll(',', separator);

    // Adjust the selection
    if (newValue.selection.isValid) {
      selectionIndex += (newText.length - oldLength);
      if (selectionIndex > newText.length) {
        selectionIndex = newText.length;
      }
      if (selectionIndex < 0) {
        selectionIndex = 0;
      }
    } else {
      selectionIndex = newText.length;
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: selectionIndex),
    );
  }
}
