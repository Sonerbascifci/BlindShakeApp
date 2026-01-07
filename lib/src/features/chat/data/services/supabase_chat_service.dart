/// BlindShake Supabase Chat Service
/// 
/// Handles chat operations with Supabase
/// - Real-time message streaming
/// - Message sending
/// - Reveal/decline operations via Edge Functions

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseChatService {
  final SupabaseClient _client;

  SupabaseChatService({required SupabaseClient client}) : _client = client;

  /// Send a message to a match
  /// Messages can be sent directly via Supabase (RLS handles authorization)
  Future<ChatMessage> sendMessage({
    required String matchId,
    required String content,
    String type = 'text',
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw ChatException('User must be authenticated');
    }

    if (content.trim().isEmpty) {
      throw ChatException('Message content cannot be empty');
    }

    if (content.length > 1000) {
      throw ChatException('Message too long (max 1000 characters)');
    }

    final response = await _client.from('messages').insert({
      'match_id': matchId,
      'sender_id': userId,
      'content': content.trim(),
      'type': type,
    }).select().single();

    return ChatMessage.fromJson(response);
  }

  /// Get messages for a match
  Future<List<ChatMessage>> getMessages(String matchId) async {
    final response = await _client
        .from('messages')
        .select()
        .eq('match_id', matchId)
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => ChatMessage.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Stream messages for real-time updates
  Stream<List<ChatMessage>> watchMessages(String matchId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('match_id', matchId)
        .order('created_at', ascending: true)
        .map((rows) => rows.map((json) => ChatMessage.fromJson(json)).toList());
  }

  /// Request to reveal identities (after anonymous phase)
  Future<RevealResult> requestReveal(String matchId) async {
    try {
      final response = await _client.functions.invoke(
        'request-reveal',
        body: {'matchId': matchId},
      );

      if (response.status != 200) {
        throw ChatException(
          response.data?['error'] as String? ?? 'Failed to request reveal',
        );
      }

      final data = response.data as Map<String, dynamic>;
      return RevealResult(
        success: data['success'] as bool? ?? false,
        revealed: data['revealed'] as bool? ?? false,
        waitingForOther: data['waitingForOther'] as bool? ?? false,
      );
    } on FunctionException catch (e) {
      throw ChatException('Edge function error: ${e.details}');
    }
  }

  /// Decline reveal request (archives the match)
  Future<void> declineReveal(String matchId) async {
    try {
      final response = await _client.functions.invoke(
        'decline-reveal',
        body: {'matchId': matchId},
      );

      if (response.status != 200) {
        throw ChatException(
          response.data?['error'] as String? ?? 'Failed to decline reveal',
        );
      }
    } on FunctionException catch (e) {
      throw ChatException('Edge function error: ${e.details}');
    }
  }

  /// Get match status for reveal UI
  Future<MatchStatus> getMatchStatus(String matchId) async {
    final response = await _client
        .from('matches')
        .select('status, anonymous_phase_ends, reveal_requested_by')
        .eq('id', matchId)
        .single();

    return MatchStatus(
      status: response['status'] as String,
      anonymousPhaseEnds: DateTime.parse(response['anonymous_phase_ends'] as String),
      revealRequestedBy: response['reveal_requested_by'] as String?,
    );
  }

  /// Stream match status for real-time updates
  Stream<MatchStatus> watchMatchStatus(String matchId) {
    return _client
        .from('matches')
        .stream(primaryKey: ['id'])
        .eq('id', matchId)
        .map((rows) {
          if (rows.isEmpty) {
            throw ChatException('Match not found');
          }
          final data = rows.first;
          return MatchStatus(
            status: data['status'] as String,
            anonymousPhaseEnds: DateTime.parse(data['anonymous_phase_ends'] as String),
            revealRequestedBy: data['reveal_requested_by'] as String?,
          );
        });
  }
}

/// Chat message model
class ChatMessage {
  final String id;
  final String matchId;
  final String senderId;
  final String content;
  final String type;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.matchId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      matchId: json['match_id'] as String,
      senderId: json['sender_id'] as String,
      content: json['content'] as String,
      type: json['type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool get isSystemMessage => type == 'system' || senderId == 'system';
  bool get isRevealRequest => type == 'reveal_request';

  /// Check if this message is from the given user
  bool isFromUser(String userId) => senderId == userId;
}

/// Result of a reveal request
class RevealResult {
  final bool success;
  final bool revealed;
  final bool waitingForOther;

  const RevealResult({
    required this.success,
    required this.revealed,
    required this.waitingForOther,
  });
}

/// Match status for reveal UI
class MatchStatus {
  final String status;
  final DateTime anonymousPhaseEnds;
  final String? revealRequestedBy;

  const MatchStatus({
    required this.status,
    required this.anonymousPhaseEnds,
    this.revealRequestedBy,
  });

  bool get isAnonymous => status == 'anonymous';
  bool get isRevealed => status == 'revealed';
  bool get isArchived => status == 'archived';
  bool get hasRevealRequest => revealRequestedBy != null;
  bool get anonymousPhaseHasEnded => DateTime.now().isAfter(anonymousPhaseEnds);

  /// Time remaining in anonymous phase
  Duration get timeRemaining {
    final remaining = anonymousPhaseEnds.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }
}

/// Exception for chat operations
class ChatException implements Exception {
  final String message;
  const ChatException(this.message);

  @override
  String toString() => 'ChatException: $message';
}
