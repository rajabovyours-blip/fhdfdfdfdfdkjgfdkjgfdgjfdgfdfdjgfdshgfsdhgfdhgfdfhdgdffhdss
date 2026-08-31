import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr_admin/core/api/api_client.dart';
import 'package:milliy_metr_admin/shared/widgets/admin_page_header.dart';
import 'package:easy_localization/easy_localization.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _titleUzController = TextEditingController();
  final _bodyUzController = TextEditingController();
  final _titleRuController = TextEditingController();
  final _bodyRuController = TextEditingController();
  final _titleEnController = TextEditingController();
  final _bodyEnController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleUzController.dispose();
    _bodyUzController.dispose();
    _titleRuController.dispose();
    _bodyRuController.dispose();
    _titleEnController.dispose();
    _bodyEnController.dispose();
    super.dispose();
  }

  Future<void> _sendBroadcast() async {
    final titleUz = _titleUzController.text.trim();
    final bodyUz = _bodyUzController.text.trim();
    final titleRu = _titleRuController.text.trim();
    final bodyRu = _bodyRuController.text.trim();
    final titleEn = _titleEnController.text.trim();
    final bodyEn = _bodyEnController.text.trim();

    if (titleUz.isEmpty || bodyUz.isEmpty || titleRu.isEmpty || bodyRu.isEmpty || titleEn.isEmpty || bodyEn.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('title_body_required'.tr()), 
          backgroundColor: Colors.red
        )
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      final dio = ref.read(dioProvider);
      final data = {
        "title": {
          "uz": titleUz,
          "ru": titleRu,
          "en": titleEn,
        },
        "body": {
          "uz": bodyUz,
          "ru": bodyRu,
          "en": bodyEn,
        },
        "target": "all",
      };

      final response = await dio.post('/notifications/broadcast', data: data);
      
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'Bildirishnoma muvaffaqiyatli yuborildi'),
            backgroundColor: Colors.green,
          )
        );
        _titleUzController.clear();
        _bodyUzController.clear();
        _titleRuController.clear();
        _bodyRuController.clear();
        _titleEnController.clear();
        _bodyEnController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${'error_prefix'.tr()}: $e'),
            backgroundColor: Colors.red
          )
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildTabContent(String langLabel, TextEditingController titleController, TextEditingController bodyController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text("${'notification_title'.tr()} ($langLabel)", style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: titleController,
          decoration: InputDecoration(
            hintText: "Xabar sarlavhasi ($langLabel)...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 24),
        
        Text("${'notification_body'.tr()} ($langLabel)", style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: bodyController,
          maxLines: 5,
          minLines: 4,
          decoration: InputDecoration(
            hintText: "Xabar matni ($langLabel)...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent, // Allow shell to handle background
      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminPageHeader(
                title: 'send_notifications'.tr(),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'notification_desc'.tr(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 32),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: Theme.of(context).colorScheme.primary,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Theme.of(context).colorScheme.primary,
                        tabs: const [
                          Tab(text: "O'zbek"),
                          Tab(text: "Русский"),
                          Tab(text: "English"),
                        ],
                      ),
                      SizedBox(
                        height: 340,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildTabContent("UZ", _titleUzController, _bodyUzController),
                            _buildTabContent("RU", _titleRuController, _bodyRuController),
                            _buildTabContent("EN", _titleEnController, _bodyEnController),
                          ],
                        ),
                      ),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _sendBroadcast,
                          icon: _isLoading 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                            : const Icon(Icons.send),
                          label: Text(_isLoading ? 'sending'.tr() : 'send_notification'.tr(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF7A00),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
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
