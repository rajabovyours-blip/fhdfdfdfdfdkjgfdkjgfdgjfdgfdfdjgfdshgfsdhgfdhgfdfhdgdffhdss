import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../../core/providers/admin_providers.dart';
import '../../../core/api/api_client.dart';

class ImportExcelScreen extends ConsumerStatefulWidget {
  const ImportExcelScreen({super.key});

  @override
  ConsumerState<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends ConsumerState<ImportExcelScreen> {
  bool _isLoading = false;

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'csv'],
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
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Import Successful! ${data['imported']} imported, ${data['failed']} failed.'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh the products list
          ref.invalidate(productsProvider);
          Navigator.of(context).pop();
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        final errorMsg = e.response?.data?['detail'] ?? e.message;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $errorMsg'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
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
      appBar: AppBar(
        title: const Text('Excel/CSV orqali yuklash'),
      ),
      body: Center(
        child: _isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 24),
                  Text('Fayl yuklanmoqda va tahlil qilinmoqda...'.tr()),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.table_view, size: 80, color: Colors.grey),
                  const SizedBox(height: 24),
                  const Text(
                    'Mahsulotlarni ommaviy yuklash uchun Excel (.xlsx) yoki CSV faylni tanlang.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _pickAndUploadFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Faylni tanlash'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
