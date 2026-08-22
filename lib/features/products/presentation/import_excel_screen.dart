import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/import_preview_table.dart';

class ImportExcelScreen extends ConsumerStatefulWidget {
  const ImportExcelScreen({super.key});

  @override
  ConsumerState<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends ConsumerState<ImportExcelScreen> {
  bool _isLoading = false;
  Map<String, dynamic>? _previewData;

  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      final fileBytes = result.files.first.bytes;
      if (fileBytes != null) {
        await _uploadForPreview(fileBytes, result.files.first.name);
      }
    }
  }

  Future<void> _uploadForPreview(List<int> fileBytes, String fileName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000'));
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
      });

      final response = await dio.post(
        '/admin/products/import/preview',
        data: formData,
        // In a real app, you'd add the auth token here
        options: Options(
          headers: {'Authorization': 'Bearer YOUR_TOKEN'},
        )
      );

      if (response.statusCode == 200) {
        setState(() {
          _previewData = response.data['data'];
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _submitImport() async {
    if (_previewData == null) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final dio = Dio(BaseOptions(baseUrl: 'http://localhost:8000'));
      final response = await dio.post(
        '/admin/products/import',
        data: _previewData!['rows'],
        options: Options(
          headers: {'Authorization': 'Bearer YOUR_TOKEN'},
        )
      );

      if (response.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import Successful! ${response.data['data']['imported']} imported, ${response.data['data']['failed']} failed.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Products from Excel'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _previewData == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.table_view, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Upload an Excel (.xlsx) file to import products.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _pickAndUploadFile,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Select Excel File'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Found ${_previewData!['stats']['total']} products. '
                            'Valid: ${_previewData!['stats']['valid']} | '
                            'Errors: ${_previewData!['stats']['invalid']} | '
                            'Duplicates: ${_previewData!['stats']['duplicates']}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              OutlinedButton(
                                onPressed: () {
                                  setState(() {
                                    _previewData = null;
                                  });
                                },
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: _submitImport,
                                child: const Text('Confirm Import'),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: ImportPreviewTable(rows: _previewData!['rows']),
                    ),
                  ],
                ),
    );
  }
}
