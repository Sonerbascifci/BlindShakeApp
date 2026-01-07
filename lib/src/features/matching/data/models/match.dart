import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'match.freezed.dart';
part 'match.g.dart';

@freezed
class Match with _$Match {
  const factory Match({
    required String id,
    required List<String> participants,
    required MatchStatus status,
    required DateTime createdAt,
    required DateTime anonymousPhaseEnds,
    String? revealRequestedBy,
    DateTime? revealedAt,
    DateTime? archivedAt,
    String? archivedReason,
    MatchLastMessage? lastMessage,
    DateTime? updatedAt,
    Map<String, ParticipantInfo>? participantInfo,
    Map<String, RevealedParticipantInfo>? revealedParticipantInfo,
  }) = _Match;

  factory Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);

  factory Match.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Match(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      status: MatchStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => MatchStatus.anonymous,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      anonymousPhaseEnds: (data['anonymousPhaseEnds'] as Timestamp).toDate(),
      revealRequestedBy: data['revealRequestedBy'] as String?,
      revealedAt: data['revealedAt'] != null
          ? (data['revealedAt'] as Timestamp).toDate()
          : null,
      archivedAt: data['archivedAt'] != null
          ? (data['archivedAt'] as Timestamp).toDate()
          : null,
      archivedReason: data['archivedReason'] as String?,
      lastMessage: data['lastMessage'] != null
          ? MatchLastMessage.fromJson(data['lastMessage'])
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      participantInfo: data['participantInfo'] != null
          ? Map<String, ParticipantInfo>.from(
              (data['participantInfo'] as Map).map(
                (key, value) => MapEntry(
                  key as String,
                  ParticipantInfo.fromJson(value as Map<String, dynamic>),
                ),
              ),
            )
          : null,
      revealedParticipantInfo: data['revealedParticipantInfo'] != null
          ? Map<String, RevealedParticipantInfo>.from(
              (data['revealedParticipantInfo'] as Map).map(
                (key, value) => MapEntry(
                  key as String,
                  RevealedParticipantInfo.fromJson(value as Map<String, dynamic>),
                ),
              ),
            )
          : null,
    );
  }
}

@freezed
class MatchLastMessage with _$MatchLastMessage {
  const factory MatchLastMessage({
    required String content,
    required DateTime timestamp,
    required String senderId,
  }) = _MatchLastMessage;

  factory MatchLastMessage.fromJson(Map<String, dynamic> json) => _$MatchLastMessageFromJson(json);

  factory MatchLastMessage.fromFirestore(Map<String, dynamic> data) {
    return MatchLastMessage(
      content: data['content'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      senderId: data['senderId'] as String,
    );
  }
}

@freezed
class ParticipantInfo with _$ParticipantInfo {
  const factory ParticipantInfo({
    required LocationInfo location,
    required DateTime joinedAt,
  }) = _ParticipantInfo;

  factory ParticipantInfo.fromJson(Map<String, dynamic> json) => _$ParticipantInfoFromJson(json);

  factory ParticipantInfo.fromFirestore(Map<String, dynamic> data) {
    return ParticipantInfo(
      location: LocationInfo.fromJson(data['location'] as Map<String, dynamic>),
      joinedAt: (data['joinedAt'] as Timestamp).toDate(),
    );
  }
}

@freezed
class RevealedParticipantInfo with _$RevealedParticipantInfo {
  const factory RevealedParticipantInfo({
    required String displayName,
    String? photoURL,
    String? email,
  }) = _RevealedParticipantInfo;

  factory RevealedParticipantInfo.fromJson(Map<String, dynamic> json) => _$RevealedParticipantInfoFromJson(json);
}

@freezed
class LocationInfo with _$LocationInfo {
  const factory LocationInfo({
    required double latitude,
    required double longitude,
  }) = _LocationInfo;

  factory LocationInfo.fromJson(Map<String, dynamic> json) => _$LocationInfoFromJson(json);
}

enum MatchStatus {
  anonymous,
  revealed,
  archived,
}