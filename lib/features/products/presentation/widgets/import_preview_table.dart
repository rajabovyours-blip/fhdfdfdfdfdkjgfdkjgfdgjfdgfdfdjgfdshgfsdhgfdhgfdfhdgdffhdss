import 'package:flutter/material.dart';

class ImportPreviewTable extends StatelessWidget {
  final List<dynamic> rows;

  const ImportPreviewTable({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const Center(child: Text('No data to preview.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Confidence')),
            DataColumn(label: Text('Price')),
            DataColumn(label: Text('Stock')),
            DataColumn(label: Text('Errors')),
          ],
          rows: rows.map((row) {
            Color? rowColor;
            if (row['status'] == 'Error') {
              rowColor = Colors.red.withValues(alpha: 0.1);
            } else if (row['status'] == 'Needs Review') {
              rowColor = Colors.orange.withValues(alpha: 0.1);
            } else if (row['status'] == 'Duplicate') {
              rowColor = Colors.blue.withValues(alpha: 0.1);
            }

            return DataRow(
              color: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                return rowColor;
              }),
              cells: [
                DataCell(
                  Row(
                    children: [
                      Icon(
                        row['status'] == 'Error'
                            ? Icons.error
                            : row['status'] == 'Needs Review'
                                ? Icons.warning
                                : row['status'] == 'Duplicate'
                                    ? Icons.copy
                                    : Icons.check_circle,
                        color: row['status'] == 'Error'
                            ? Colors.red
                            : row['status'] == 'Needs Review'
                                ? Colors.orange
                                : row['status'] == 'Duplicate'
                                    ? Colors.blue
                                    : Colors.green,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(row['status']),
                    ],
                  ),
                ),
                DataCell(Text(row['name'] ?? '')),
                DataCell(Text(row['detected_category'] ?? '')),
                DataCell(Text(row['confidence'] ?? '')),
                DataCell(Text(row['price']?.toString() ?? '')),
                DataCell(Text(row['stock']?.toString() ?? '')),
                DataCell(
                  Text(
                    (row['errors'] as List<dynamic>).join(', '),
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
