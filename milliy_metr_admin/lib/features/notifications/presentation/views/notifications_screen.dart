import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import '../../../core/api/api_client.dart';

final dioProvider = Provider<Dio>((ref) {
  return ApiClient.dio;
});

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _imageController = TextEditingController();
  String _target = 'all'; // all, users, admins
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(type: FileType.image);
    if (result != null && result.files.single.bytes != null) {
      try {
        final dio = ref.read(dioProvider);
        final formData = FormData.fromMap({
          'file': MultipartFile.fromBytes(
            result.files.single.bytes!,
            filename: result.files.single.name,
          ),
        });
        final response = await dio.post('/upload/image', data: formData);
        if (response.data['data'] != null && response.data['data']['url'] != null) {
          setState(() {
            _imageController.text = response.data['data']['url'];
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
        }
      }
    }
  }

  Future<void> _sendBroadcast() async {
    if (_titleController.text.trim().isEmpty || _bodyController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sarlavha va matn kiritilishi shart!')));
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final dio = ref.read(dioProvider);
      final data = {
        "title": _titleController.text.trim(),
        "body": _bodyController.text.trim(),
        "image_url": _imageController.text.trim().isEmpty ? null : _imageController.text.trim(),
        "target": _target,
      };

      final response = await dio.post('/notifications/broadcast', data: data);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'Bildirishnoma muvaffaqiyatli yuborildi'),
            backgroundColor: Colors.green,
          )
        );
        _titleController.clear();
        _bodyController.clear();
        _imageController.clear();
        setState(() {
          _target = 'all';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xatolik: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Bildirishnomalar Yuborish'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Yangi Bildirishnoma (Push Notification)',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Bu yerdan barcha foydalanuvchilarga push bildirishnomalari yuborishingiz mumkin.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Sarlavha (Title)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 16),
              
              TextField(
                controller: _bodyController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Matn (Body)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                ),
              ),
              const SizedBox(height: 16),
              
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _imageController,
                      decoration: const InputDecoration(
                        labelText: 'Rasm URL (Ixtiyoriy)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.image),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Yuklash'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              const Text('Kimgar yuboriladi?', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'all', label: Text('Barchaga')),
                  ButtonSegment(value: 'users', label: Text('Foydalanuvchilarga')),
                  ButtonSegment(value: 'admins', label: Text('Adminlarga')),
                ],
                selected: {_target},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _target = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _sendBroadcast,
                  icon: _isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.send),
                  label: Text(_isLoading ? 'Yuborilmoqda...' : 'Bildirishnomani Yuborish', style: const TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7A00),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
