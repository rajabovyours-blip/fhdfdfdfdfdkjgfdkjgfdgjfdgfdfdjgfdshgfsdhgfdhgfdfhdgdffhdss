import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/features/chat/presentation/providers/chat_providers.dart';
import 'package:milliy_metr/shared/widgets/app_button.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';

class ChatBottomSheet extends ConsumerStatefulWidget {
  const ChatBottomSheet({super.key});

  @override
  ConsumerState<ChatBottomSheet> createState() => _ChatBottomSheetState();
}

class _ChatBottomSheetState extends ConsumerState<ChatBottomSheet> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatSessionProvider);
    final notifier = ref.read(chatSessionProvider.notifier);

    // After rendering, if we have messages, scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: context.colors.outline)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.support_agent, color: context.colors.primary),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.l10n.chatSupport,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textHigh,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: context.colors.textHigh),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: chatState.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e) => Center(child: Text(e)),
              loaded: (session) {
                if (session == null) {
                  return _buildLoginForm(notifier);
                }
                return _buildChatInterface(session, notifier);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(ChatSessionNotifier notifier) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            context.l10n.welcome,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.colors.textHigh,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.chatWelcomeDesc,
            style: TextStyle(color: context.colors.textMedium),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            style: TextStyle(color: context.colors.textHigh),
            decoration: InputDecoration(
              labelText: context.l10n.chatName,
              labelStyle: TextStyle(color: context.colors.textMedium),
              filled: true,
              fillColor: context.colors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _phoneController,
            style: TextStyle(color: context.colors.textHigh),
            decoration: InputDecoration(
              labelText: context.l10n.chatPhone,
              labelStyle: TextStyle(color: context.colors.textMedium),
              filled: true,
              fillColor: context.colors.surfaceVariant,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          AppButton(
            text: context.l10n.chatStart,
            onPressed: () {
              if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
                notifier.startSession(_nameController.text, _phoneController.text);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatInterface(dynamic session, ChatSessionNotifier notifier) {
    final messages = notifier.currentMessages;

    return Column(
      children: [
        if (session.isResolved)
          Container(
            padding: const EdgeInsets.all(8),
            color: context.colors.surfaceVariant,
            width: double.infinity,
            child: Text(
              context.l10n.chatResolved,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: context.colors.textMedium),
            ),
          ),
        Expanded(
          child: messages.isEmpty
              ? Center(
                  child: Text(
                    context.l10n.chatTypeMessage,
                    style: TextStyle(color: context.colors.textMedium),
                  ),
                )
              : ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isUser = msg.sender == 'user';
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isUser ? context.colors.primary : context.colors.surfaceVariant,
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
                            bottomLeft: !isUser ? const Radius.circular(4) : const Radius.circular(16),
                          ),
                        ),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg.text,
                              style: TextStyle(
                                color: isUser ? Colors.white : context.colors.textHigh,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${msg.createdAt.toLocal().hour.toString().padLeft(2, '0')}:${msg.createdAt.toLocal().minute.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isUser ? Colors.white70 : context.colors.textMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Container(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: 12 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: context.colors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  // MUHIM: yozilayotgan matn rangi aniq ko'rsatilmagan edi,
                  // shuning uchun tungi rejimda standart (oq) rangni olib,
                  // xuddi shu tungi rejimda ham yorug' turadigan fon bilan
                  // qo'shilib, matn butunlay ko'rinmay qolardi. Endi matn
                  // ham, fon ham mavzuga (dark/light) moslashadi.
                  style: TextStyle(color: context.colors.textHigh),
                  decoration: InputDecoration(
                    hintText: context.l10n.chatTypeMessage,
                    hintStyle: TextStyle(color: context.colors.textMedium),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: context.colors.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onSubmitted: (val) {
                    if (val.trim().isNotEmpty) {
                      notifier.sendMessage(val.trim());
                      _messageController.clear();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: context.colors.primary,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  onPressed: () {
                    if (_messageController.text.trim().isNotEmpty) {
                      notifier.sendMessage(_messageController.text.trim());
                      _messageController.clear();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
