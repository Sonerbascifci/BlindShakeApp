// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MatchImpl _$$MatchImplFromJson(Map<String, dynamic> json) => _$MatchImpl(
  id: json['id'] as String,
  participants: (json['participants'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  status: $enumDecode(_$MatchStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  anonymousPhaseEnds: DateTime.parse(json['anonymousPhaseEnds'] as String),
  revealRequestedBy: json['revealRequestedBy'] as String?,
  revealedAt: json['revealedAt'] == null
      ? null
      : DateTime.parse(json['revealedAt'] as String),
  archivedAt: json['archivedAt'] == null
      ? null
      : DateTime.parse(json['archivedAt'] as String),
  archivedReason: json['archivedReason'] as String?,
  lastMessage: json['lastMessage'] == null
      ? null
      : MatchLastMessage.fromJson(json['lastMessage'] as Map<String, dynamic>),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
  participantInfo: (json['participantInfo'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, ParticipantInfo.fromJson(e as Map<String, dynamic>)),
  ),
  revealedParticipantInfo:
      (json['revealedParticipantInfo'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
          k,
          RevealedParticipantInfo.fromJson(e as Map<String, dynamic>),
        ),
      ),
);

Map<String, dynamic> _$$MatchImplToJson(_$MatchImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'participants': instance.participants,
      'status': _$MatchStatusEnumMap[instance.status]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'anonymousPhaseEnds': instance.anonymousPhaseEnds.toIso8601String(),
      'revealRequestedBy': instance.revealRequestedBy,
      'revealedAt': instance.revealedAt?.toIso8601String(),
      'archivedAt': instance.archivedAt?.toIso8601String(),
      'archivedReason': instance.archivedReason,
      'lastMessage': instance.lastMessage,
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'participantInfo': instance.participantInfo,
      'revealedParticipantInfo': instance.revealedParticipantInfo,
    };

const _$MatchStatusEnumMap = {
  MatchStatus.anonymous: 'anonymous',
  MatchStatus.revealed: 'revealed',
  MatchStatus.archived: 'archived',
};

_$MatchLastMessageImpl _$$MatchLastMessageImplFromJson(
  Map<String, dynamic> json,
) => _$MatchLastMessageImpl(
  content: json['content'] as String,
  timestamp: DateTime.parse(json['timestamp'] as String),
  senderId: json['senderId'] as String,
);

Map<String, dynamic> _$$MatchLastMessageImplToJson(
  _$MatchLastMessageImpl instance,
) => <String, dynamic>{
  'content': instance.content,
  'timestamp': instance.timestamp.toIso8601String(),
  'senderId': instance.senderId,
};

_$ParticipantInfoImpl _$$ParticipantInfoImplFromJson(
  Map<String, dynamic> json,
) => _$ParticipantInfoImpl(
  location: LocationInfo.fromJson(json['location'] as Map<String, dynamic>),
  joinedAt: DateTime.parse(json['joinedAt'] as String),
);

Map<String, dynamic> _$$ParticipantInfoImplToJson(
  _$ParticipantInfoImpl instance,
) => <String, dynamic>{
  'location': instance.location,
  'joinedAt': instance.joinedAt.toIso8601String(),
};

_$RevealedParticipantInfoImpl _$$RevealedParticipantInfoImplFromJson(
  Map<String, dynamic> json,
) => _$RevealedParticipantInfoImpl(
  displayName: json['displayName'] as String,
  photoURL: json['photoURL'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$$RevealedParticipantInfoImplToJson(
  _$RevealedParticipantInfoImpl instance,
) => <String, dynamic>{
  'displayName': instance.displayName,
  'photoURL': instance.photoURL,
  'email': instance.email,
};

_$LocationInfoImpl _$$LocationInfoImplFromJson(Map<String, dynamic> json) =>
    _$LocationInfoImpl(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$$LocationInfoImplToJson(_$LocationInfoImpl instance) =>
    <String, dynamic>{
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };
