import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:blind_shake/src/features/chat/data/models/chat_message.dart';
import 'package:blind_shake/src/features/chat/data/services/chat_service.dart';

part 'chat_providers.g.dart';

/// Provider for chat service instance
@riverpod
ChatService chatService(Ref ref) {
  return ChatService();
}

/// Provider for messages stream for a specific match
@riverpod
Stream<List<ChatMessage>> messagesStream(
  Ref ref,
  String matchId,
) {
  final service = ref.watch(chatServiceProvider);
  return service.getMessagesStream(matchId);
}

/// Provider for match info stream
@riverpod
Stream<MatchInfo> matchInfoStream(
  Ref ref,
  String matchId,
) {
  final service = ref.watch(chatServiceProvider);
  return service.getMatchInfoStream(matchId);
}

/// Provider for current chat messages state
@riverpod
class ChatMessagesNotifier extends _$ChatMessagesNotifier {
  @override
  List<ChatMessage> build() {
    return [];
  }

  /// Set messages from stream
  void setMessages(List<ChatMessage> messages) {
    state = messages;
  }

  /// Add a message optimistically (for UI responsiveness)
  void addMessageOptimistically(ChatMessage message) {
    state = [...state, message];
  }

  /// Clear messages
  void clear() {
    state = [];
  }
}

/// Provider for chat error state
@riverpod
class ChatErrorNotifier extends _$ChatErrorNotifier {
  @override
  String? build() {
    return null;
  }

  /// Set error message
  void setError(String? error) {
    state = error;
  }

  /// Clear error
  void clearError() {
    state = null;
  }
}

/// Provider for sending message loading state
@riverpod
class SendingMessageNotifier extends _$SendingMessageNotifier {
  @override
  bool build() {
    return false;
  }

  /// Set loading state
  void setLoading(bool loading) {
    state = loading;
  }
}

/// Provider for match info state
@riverpod
class MatchInfoNotifier extends _$MatchInfoNotifier {
  @override
  MatchInfo? build() {
    return null;
  }

  /// Set match info
  void setMatchInfo(MatchInfo? info) {
    state = info;
  }
}

/// Provider for unified chat controller
@riverpod
class ChatControllerNotifier extends _$ChatControllerNotifier {
  @override
  Future<void> build() async {
    // Initialize listeners
  }

  /// Send a message
  Future<bool> sendMessage({
    required String matchId,
    required String content,
  }) async {
    try {
      // Clear previous errors
      ref.read(chatErrorNotifierProvider.notifier).clearError();

      // Set loading state
      ref.read(sendingMessageNotifierProvider.notifier).setLoading(true);

      // Send message via service
      final service = ref.read(chatServiceProvider);
      await service.sendMessage(matchId: matchId, content: content);

      // Clear loading state
      ref.read(sendingMessageNotifierProvider.notifier).setLoading(false);

      return true;
    } on ChatException catch (e) {
      ref.read(chatErrorNotifierProvider.notifier).setError(e.message);
      ref.read(sendingMessageNotifierProvider.notifier).setLoading(false);
      return false;
    } catch (e) {
      ref.read(chatErrorNotifierProvider.notifier).setError('Mesaj gönderilemedi: $e');
      ref.read(sendingMessageNotifierProvider.notifier).setLoading(false);
      return false;
    }
  }

  /// Request identity reveal
  Future<bool> requestReveal(String matchId) async {
    try {
      ref.read(chatErrorNotifierProvider.notifier).clearError();

      final service = ref.read(chatServiceProvider);
      await service.requestReveal(matchId);

      return true;
    } on ChatException catch (e) {
      ref.read(chatErrorNotifierProvider.notifier).setError(e.message);
      return false;
    } catch (e) {
      ref.read(chatErrorNotifierProvider.notifier).setError('Kimlik açığa çıkarılamadı: $e');
      return false;
    }
  }

  /// Decline identity reveal
  Future<bool> declineReveal(String matchId) async {
    try {
      ref.read(chatErrorNotifierProvider.notifier).clearError();

      final service = ref.read(chatServiceProvider);
      await service.declineReveal(matchId);

      return true;
    } on ChatException catch (e) {
      ref.read(chatErrorNotifierProvider.notifier).setError(e.message);
      return false;
    } catch (e) {
      ref.read(chatErrorNotifierProvider.notifier).setError('İşlem başarısız: $e');
      return false;
    }
  }

  /// Get current user ID
  String? getCurrentUserId() {
    final service = ref.read(chatServiceProvider);
    return service.currentUserId;
  }
}
