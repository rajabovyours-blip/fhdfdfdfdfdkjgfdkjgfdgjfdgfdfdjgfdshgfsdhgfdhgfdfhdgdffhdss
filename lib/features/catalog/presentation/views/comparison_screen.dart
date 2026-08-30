import 'package:flutter/material.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class ComparisonScreen extends StatelessWidget {
  const ComparisonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.compareProducts)),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(label: Text(context.l10n.feature)),
            DataColumn(label: Text(context.l10n.productA)),
            DataColumn(label: Text(context.l10n.productB)),
          ],
          rows: [
            const DataRow(
              cells: [
                DataCell(
                  Text(context.l10n.price, style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
                DataCell(Text('52,000 UZS')),
                DataCell(Text('48,000 UZS')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text(context.l10n.weight)),
                const DataCell(Text('M400')),
                const DataCell(Text('M400')),
              ],
            ),
            DataRow(
              cells: [
                DataCell(Text(context.l10n.store)),
                const DataCell(Text('Qurilish Bazasi')),
                const DataCell(Text('Mega Stroy')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
