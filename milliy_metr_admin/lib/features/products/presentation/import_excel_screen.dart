import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:excel/excel.dart';
import 'package:universal_html/html.dart' as html;

import '../../../core/providers/admin_providers.dart';
import '../../../core/api/api_client.dart';

class ImportExcelScreen extends ConsumerStatefulWidget {
  const ImportExcelScreen({super.key});

  @override
  ConsumerState<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends ConsumerState<ImportExcelScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _importResult;

  void _downloadTemplate() {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];
    excel.setDefaultSheet('Sheet1');
    
    // Headers
    List<String> headers = [
      "Nomi (O'zbekcha)",
      "Nomi (Ruscha)",
      "Nomi (Inglizcha)",
      "Kategoriya",
      "Narxi",
      "O'lchov birligi",
      "Tavsif"
    ];
    sheetObject.appendRow(headers.map((h) => TextCellValue(h)).toList());
    
    // Example Row
    List<String> exampleRow = [
      "Sement M400",
      "Цемент М400",
      "Cement M400",
      "Qurilish materiallari",
      "45000",
      "qop",
      "Yuqori sifatli sement"
    ];
    sheetObject.appendRow(exampleRow.map((h) => TextCellValue(h)).toList());
    
    var fileBytes = excel.save();
    if (fileBytes != null) {
      if (kIsWeb) {
        final blob = html.Blob([fileBytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'milliy_metr_andoza.xlsx')
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        // Not implemented for mobile here, since this is primarily an admin web panel.
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fayl yuklab olindi (Faqat Web uchun qo\'llab-quvvatlanadi)')));
      }
    }
  }

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final fileBytes = result.files.first.bytes;
      if (fileBytes != null) {
        await _uploadBulkData(fileBytes, result.files.first.name);
      }
    }
  }

  Future<void> _uploadBulkData(List<int> fileBytes, String fileName) async {
    setState(() {
      _isLoading = true;
      _importResult = null;
    });

    try {
      final dio = ref.read(dioProvider);
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
      });

      final response = await dio.post(
        '/products/bulk-upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        setState(() {
          _importResult = data;
        });
        ref.invalidate(productsProvider);
      }
    } on DioException catch (e) {
      if (mounted) {
        final errorMsg = e.response?.data?['detail'] ?? e.message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik (Error): $errorMsg'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Let shell background show
      appBar: AppBar(
        title: const Text('Excel orqali ommaviy yuklash', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 800),
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Theme.of(context).colorScheme.outline),
            ),
            child: _isLoading
                ? _buildLoadingState()
                : _importResult != null
                    ? _buildResultState()
                    : _buildUploadState(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 64, height: 64, child: CircularProgressIndicator()),
        const SizedBox(height: 32),
        Text(
          'Fayl yuklanmoqda va tahlil qilinmoqda...\nIltimos kuting.',
          style: Theme.of(context).textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUploadState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.table_view, size: 80, color: Colors.green),
        const SizedBox(height: 24),
        const Text(
          'Minglab mahsulotlarni bir marta yuklash uchun Excel (.xlsx) faylni tanlang.',
          style: TextStyle(fontSize: 16),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade200),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Diqqat: Rasmlarni Excel orqali yuklab bo\'lmaydi. Mahsulotlar yasalganidan so\'ng, rasmlarni tahrirlash bo\'limidan birma-bir qo\'shib chiqing.',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton.icon(
              onPressed: _downloadTemplate,
              icon: const Icon(Icons.download),
              label: const Text('Andoza yuklab olish (Template)'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: _pickAndUploadFile,
              icon: const Icon(Icons.upload_file),
              label: const Text('Excel tanlash va Yuklash'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildResultState() {
    final int total = _importResult?['total_rows'] ?? 0;
    final int success = _importResult?['success_count'] ?? 0;
    final List failedRows = _importResult?['failed_rows'] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.check_circle, size: 80, color: Colors.green),
        const SizedBox(height: 16),
        Text(
          'Ommaviy yuklash yakunlandi',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatCard('Jami qatorlar', total.toString(), Colors.blue),
            _buildStatCard('Muvaffaqiyatli', success.toString(), Colors.green),
            _buildStatCard('Xatolar', failedRows.length.toString(), Colors.red),
          ],
        ),
        const SizedBox(height: 32),
        if (failedRows.isNotEmpty) ...[
          const Text('Xato bo\'lgan qatorlar:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            height: 250,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.shade200),
              borderRadius: BorderRadius.circular(8),
              color: Colors.red.shade50,
            ),
            child: ListView.separated(
              padding: const EdgeInsets.all(8),
              itemCount: failedRows.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final error = failedRows[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.shade100,
                    child: Text('${error['row']}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(error['reason'] ?? 'Noma\'lum xato'),
                );
              },
            ),
          ),
        ],
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text('Ortga qaytish'),
        )
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 14, color: color)),
        ],
      ),
    );
  }
}
