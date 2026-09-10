import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/core/state/feature_state.dart';
import 'package:milliy_metr/features/chat/data/datasources/chat_remote_datasource.dart';
import 'package:milliy_metr/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:milliy_metr/features/chat/domain/entities/chat_entity.dart';
import 'package:milliy_metr/features/chat/domain/repositories/chat_repository.dart';

final chatRemoteDataSourceProvider = Provider<ChatRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return ChatRemoteDataSourceImpl(dio: dio);
});

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final remoteDataSource = ref.watch(chatRemoteDataSourceProvider);
  return ChatRepositoryImpl(remoteDataSource: remoteDataSource);
});

final chatSessionProvider = StateNotifierProvider<ChatSessionNotifier, FeatureState<ChatSessionEntity?>>((ref) {
  return ChatSessionNotifier(ref);
});

class ChatSessionNotifier extends StateNotifier<FeatureState<ChatSessionEntity?>> {
  final Ref _ref;
  Timer? _pollingTimer;
  
  // Track messages here to easily update UI
  List<ChatMessageEntity> currentMessages = [];

  ChatSessionNotifier(this._ref) : super(const FeatureState.initial()) {
    _loadSavedSession();
  }

  Future<void> _loadSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('chat_session_id');
    final name = prefs.getString('chat_session_name');
    final phone = prefs.getString('chat_session_phone');

    if (sessionId != null && name != null && phone != null) {
      state = FeatureState.loaded(ChatSessionEntity(
        id: sessionId,
        name: name,
        phone: phone,
        isResolved: false,
      ));
      startPolling();
    } else {
      state = const FeatureState.loaded(null);
    }
  }

  Future<void> startSession(String name, String phone) async {
    state = const FeatureState.loading();
    final repository = _ref.read(chatRepositoryProvider);
    final result = await repository.startSession(name, phone);
    
    result.fold(
      (failure) => state = FeatureState.error(failure.message),
      (session) async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('chat_session_id', session.id);
        await prefs.setString('chat_session_name', session.name);
        await prefs.setString('chat_session_phone', session.phone);
        
        state = FeatureState.loaded(session);
        startPolling();
      },
    );
  }

  void startPolling() {
    if (_pollingTimer != null) return;
    
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      fetchMessages();
    });
    fetchMessages();
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> fetchMessages() async {
    final session = state.maybeWhen(
      loaded: (s) => s,
      orElse: () => null,
    );
    if (session == null) return;

    final repository = _ref.read(chatRepositoryProvider);
    final result = await repository.getMessages(session.id);
    
    result.fold(
      (failure) {}, // Silently ignore polling errors
      (messages) {
        currentMessages = messages;
        // Notify listeners without changing session state
        // Re-emit the same session to trigger UI rebuild
        state = FeatureState.loaded(session);
      },
    );
  }

  Future<void> sendMessage(String text) async {
    final session = state.maybeWhen(
      loaded: (s) => s,
      orElse: () => null,
    );
    if (session == null) return;

    // Optimistically add to UI
    final tempMsg = ChatMessageEntity(
      id: DateTime.now().toString(),
      sessionId: session.id,
      sender: 'user',
      text: text,
      createdAt: DateTime.now(),
    );
    currentMessages.add(tempMsg);
    state = FeatureState.loaded(session);

    final repository = _ref.read(chatRepositoryProvider);
    final result = await repository.sendMessage(session.id, text);
    
    result.fold(
      (failure) {
        // Remove optimistic message if failed
        currentMessages.remove(tempMsg);
        state = FeatureState.loaded(session);
      },
      (msg) {
        // Replace temp msg with real one
        currentMessages.remove(tempMsg);
        currentMessages.add(msg);
        state = FeatureState.loaded(session);
      }
    );
  }
  
  Future<void> clearSession() async {
    stopPolling();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('chat_session_id');
    await prefs.remove('chat_session_name');
    await prefs.remove('chat_session_phone');
    currentMessages = [];
    state = const FeatureState.loaded(null);
  }

  @override
  void dispose() {
    stopPolling();
    super.dispose();
  }
}
