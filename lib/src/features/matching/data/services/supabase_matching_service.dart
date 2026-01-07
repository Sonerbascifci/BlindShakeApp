/// BlindShake Supabase Matching Service
/// 
/// Handles matching operations via Supabase Edge Functions
/// Replaces Firebase Cloud Functions matching calls

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseMatchingService {
  final SupabaseClient _client;

  SupabaseMatchingService({required SupabaseClient client}) : _client = client;

  /// Start shaking and enter matching pool
  /// Returns match data if a match is found immediately
  Future<MatchResult> startShaking({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'start-shaking',
        body: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.status != 200) {
        throw MatchingException(
          response.data?['error'] as String? ?? 'Failed to start shaking',
        );
      }

      final data = response.data as Map<String, dynamic>;
      
      if (data['match'] != null) {
        final matchData = data['match'] as Map<String, dynamic>;
        return MatchResult(
          success: true,
          geohash: data['geohash'] as String?,
          matchId: matchData['matchId'] as String,
          otherUserId: (matchData['otherUser'] as Map<String, dynamic>)['id'] as String,
          anonymousPhaseEnds: DateTime.parse(matchData['anonymousPhaseEnds'] as String),
        );
      }

      return MatchResult(
        success: true,
        geohash: data['geohash'] as String?,
        message: data['message'] as String?,
      );
    } on FunctionException catch (e) {
      throw MatchingException('Edge function error: ${e.details}');
    } catch (e) {
      throw MatchingException('Failed to start shaking: $e');
    }
  }

  /// Stop shaking and remove from matching pool
  Future<void> stopShaking() async {
    try {
      final response = await _client.functions.invoke('stop-shaking');
      
      if (response.status != 200) {
        throw MatchingException(
          response.data?['error'] as String? ?? 'Failed to stop shaking',
        );
      }
    } on FunctionException catch (e) {
      throw MatchingException('Edge function error: ${e.details}');
    }
  }

  /// Get current match for user
  Future<Match?> getCurrentMatch() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('matches')
        .select()
        .contains('participants', [userId])
        .neq('status', 'archived')
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (response == null) return null;
    return Match.fromJson(response);
  }

  /// Get match by ID
  Future<Match?> getMatch(String matchId) async {
    final response = await _client
        .from('matches')
        .select()
        .eq('id', matchId)
        .maybeSingle();

    if (response == null) return null;
    return Match.fromJson(response);
  }

  /// Stream of match updates for real-time UI
  Stream<Match?> watchMatch(String matchId) {
    return _client
        .from('matches')
        .stream(primaryKey: ['id'])
        .eq('id', matchId)
        .map((rows) => rows.isEmpty ? null : Match.fromJson(rows.first));
  }
}

/// Result of a shaking operation
class MatchResult {
  final bool success;
  final String? geohash;
  final String? matchId;
  final String? otherUserId;
  final DateTime? anonymousPhaseEnds;
  final String? message;

  const MatchResult({
    required this.success,
    this.geohash,
    this.matchId,
    this.otherUserId,
    this.anonymousPhaseEnds,
    this.message,
  });

  bool get hasMatch => matchId != null;
}

/// Match data model
class Match {
  final String id;
  final List<String> participants;
  final String status;
  final DateTime anonymousPhaseEnds;
  final String? revealRequestedBy;
  final DateTime? revealedAt;
  final DateTime? archivedAt;
  final String? archivedReason;
  final Map<String, dynamic>? participantInfo;
  final Map<String, dynamic>? revealedParticipantInfo;
  final Map<String, dynamic>? lastMessage;
  final DateTime createdAt;

  const Match({
    required this.id,
    required this.participants,
    required this.status,
    required this.anonymousPhaseEnds,
    this.revealRequestedBy,
    this.revealedAt,
    this.archivedAt,
    this.archivedReason,
    this.participantInfo,
    this.revealedParticipantInfo,
    this.lastMessage,
    required this.createdAt,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as String,
      participants: (json['participants'] as List).cast<String>(),
      status: json['status'] as String,
      anonymousPhaseEnds: DateTime.parse(json['anonymous_phase_ends'] as String),
      revealRequestedBy: json['reveal_requested_by'] as String?,
      revealedAt: json['revealed_at'] != null
          ? DateTime.parse(json['revealed_at'] as String)
          : null,
      archivedAt: json['archived_at'] != null
          ? DateTime.parse(json['archived_at'] as String)
          : null,
      archivedReason: json['archived_reason'] as String?,
      participantInfo: json['participant_info'] as Map<String, dynamic>?,
      revealedParticipantInfo:
          json['revealed_participant_info'] as Map<String, dynamic>?,
      lastMessage: json['last_message'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  bool get isAnonymous => status == 'anonymous';
  bool get isRevealed => status == 'revealed';
  bool get isArchived => status == 'archived';
  bool get hasRevealRequest => revealRequestedBy != null;

  /// Check if anonymous phase has ended
  bool get anonymousPhaseHasEnded => DateTime.now().isAfter(anonymousPhaseEnds);

  /// Get other participant ID
  String? getOtherParticipant(String currentUserId) {
    return participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => participants.first,
    );
  }
}

/// Exception for matching operations
class MatchingException implements Exception {
  final String message;
  const MatchingException(this.message);

  @override
  String toString() => 'MatchingException: $message';
}
