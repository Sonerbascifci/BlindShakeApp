import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:blind_shake/src/features/chat/data/models/chat_message.dart';

/// Service for managing chat messages and match communication
class ChatService {
  final FirebaseFirestore _firestore;
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  ChatService({
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _functions = functions ?? FirebaseFunctions.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Get real-time stream of messages for a match
  Stream<List<ChatMessage>> getMessagesStream(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
    }).handleError((error) {
      debugPrint('Error streaming messages: $error');
      throw ChatException('Failed to load messages: $error');
    });
  }

  /// Send a text message to the match
  Future<void> sendMessage({
    required String matchId,
    required String content,
  }) async {
    try {
      // Validate input
      if (content.trim().isEmpty) {
        throw ChatException('Message cannot be empty');
      }

      if (content.length > 1000) {
        throw ChatException('Message too long (max 1000 characters)');
      }

      // Call Cloud Function to send message
      final callable = _functions.httpsCallable('sendMessage');
      await callable.call({
        'matchId': matchId,
        'content': content.trim(),
        'type': 'text',
      });
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Cloud Function error: ${e.code} - ${e.message}');
      throw ChatException(_parseFunctionError(e));
    } catch (e) {
      debugPrint('Error sending message: $e');
      throw ChatException('Failed to send message: $e');
    }
  }

  /// Request identity reveal (after anonymous phase ends)
  Future<void> requestReveal(String matchId) async {
    try {
      final callable = _functions.httpsCallable('requestReveal');
      await callable.call({'matchId': matchId});
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Cloud Function error: ${e.code} - ${e.message}');
      throw ChatException(_parseFunctionError(e));
    } catch (e) {
      debugPrint('Error requesting reveal: $e');
      throw ChatException('Failed to request reveal: $e');
    }
  }

  /// Decline identity reveal (ends the match)
  Future<void> declineReveal(String matchId) async {
    try {
      final callable = _functions.httpsCallable('declineReveal');
      await callable.call({'matchId': matchId});
    } on FirebaseFunctionsException catch (e) {
      debugPrint('Cloud Function error: ${e.code} - ${e.message}');
      throw ChatException(_parseFunctionError(e));
    } catch (e) {
      debugPrint('Error declining reveal: $e');
      throw ChatException('Failed to decline reveal: $e');
    }
  }

  /// Get match details
  Future<MatchInfo> getMatchInfo(String matchId) async {
    try {
      final doc = await _firestore.collection('matches').doc(matchId).get();

      if (!doc.exists) {
        throw ChatException('Match not found');
      }

      return MatchInfo.fromFirestore(doc);
    } catch (e) {
      debugPrint('Error getting match info: $e');
      throw ChatException('Failed to load match info: $e');
    }
  }

  /// Get stream of match info for real-time updates
  Stream<MatchInfo> getMatchInfoStream(String matchId) {
    return _firestore
        .collection('matches')
        .doc(matchId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        throw ChatException('Match not found');
      }
      return MatchInfo.fromFirestore(doc);
    }).handleError((error) {
      debugPrint('Error streaming match info: $error');
      throw ChatException('Failed to load match info: $error');
    });
  }

  /// Parse Firebase Functions error messages
  String _parseFunctionError(FirebaseFunctionsException e) {
    switch (e.code) {
      case 'unauthenticated':
        return 'Oturum açmanız gerekiyor';
      case 'permission-denied':
        return 'Bu işlem için yetkiniz yok';
      case 'not-found':
        return 'Eşleşme bulunamadı';
      case 'invalid-argument':
        return e.message ?? 'Geçersiz parametre';
      case 'failed-precondition':
        return e.message ?? 'İşlem şu anda yapılamıyor';
      default:
        return e.message ?? 'Bir hata oluştu';
    }
  }

  /// Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;
}

/// Match information
class MatchInfo {
  final String id;
  final List<String> participants;
  final String status; // "anonymous", "revealed", "archived"
  final DateTime anonymousPhaseEnds;
  final String? revealRequestedBy;
  final double? distance;
  final Map<String, dynamic>? revealedParticipants;

  const MatchInfo({
    required this.id,
    required this.participants,
    required this.status,
    required this.anonymousPhaseEnds,
    this.revealRequestedBy,
    this.distance,
    this.revealedParticipants,
  });

  /// Create from Firestore document
  factory MatchInfo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return MatchInfo(
      id: doc.id,
      participants: List<String>.from(data['participants'] as List),
      status: data['status'] as String,
      anonymousPhaseEnds: (data['anonymousPhaseEnds'] as Timestamp).toDate(),
      revealRequestedBy: data['revealRequestedBy'] as String?,
      distance: (data['distance'] as num?)?.toDouble(),
      revealedParticipants: data['revealedParticipants'] as Map<String, dynamic>?,
    );
  }

  /// Check if anonymous phase has ended
  bool get isAnonymousPhaseEnded => DateTime.now().isAfter(anonymousPhaseEnds);

  /// Get time remaining in anonymous phase
  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(anonymousPhaseEnds)) {
      return Duration.zero;
    }
    return anonymousPhaseEnds.difference(now);
  }

  /// Check if reveal has been requested
  bool get hasRevealRequest => revealRequestedBy != null;

  /// Check if match is revealed
  bool get isRevealed => status == 'revealed';

  /// Check if match is archived
  bool get isArchived => status == 'archived';

  /// Get other participant's revealed info
  Map<String, dynamic>? getOtherParticipantInfo(String currentUserId) {
    if (revealedParticipants == null) return null;

    final otherUserId = participants.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    if (otherUserId.isEmpty) return null;

    return revealedParticipants![otherUserId] as Map<String, dynamic>?;
  }
}

/// Chat service exception
class ChatException implements Exception {
  final String message;
  final Object? originalError;

  const ChatException(this.message, [this.originalError]);

  @override
  String toString() => 'ChatException: $message';
}
