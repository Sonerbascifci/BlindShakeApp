// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Match _$MatchFromJson(Map<String, dynamic> json) {
  return _Match.fromJson(json);
}

/// @nodoc
mixin _$Match {
  String get id => throw _privateConstructorUsedError;
  List<String> get participants => throw _privateConstructorUsedError;
  MatchStatus get status => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime get anonymousPhaseEnds => throw _privateConstructorUsedError;
  String? get revealRequestedBy => throw _privateConstructorUsedError;
  DateTime? get revealedAt => throw _privateConstructorUsedError;
  DateTime? get archivedAt => throw _privateConstructorUsedError;
  String? get archivedReason => throw _privateConstructorUsedError;
  MatchLastMessage? get lastMessage => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  Map<String, ParticipantInfo>? get participantInfo =>
      throw _privateConstructorUsedError;
  Map<String, RevealedParticipantInfo>? get revealedParticipantInfo =>
      throw _privateConstructorUsedError;

  /// Serializes this Match to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchCopyWith<Match> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchCopyWith<$Res> {
  factory $MatchCopyWith(Match value, $Res Function(Match) then) =
      _$MatchCopyWithImpl<$Res, Match>;
  @useResult
  $Res call({
    String id,
    List<String> participants,
    MatchStatus status,
    DateTime createdAt,
    DateTime anonymousPhaseEnds,
    String? revealRequestedBy,
    DateTime? revealedAt,
    DateTime? archivedAt,
    String? archivedReason,
    MatchLastMessage? lastMessage,
    DateTime? updatedAt,
    Map<String, ParticipantInfo>? participantInfo,
    Map<String, RevealedParticipantInfo>? revealedParticipantInfo,
  });

  $MatchLastMessageCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class _$MatchCopyWithImpl<$Res, $Val extends Match>
    implements $MatchCopyWith<$Res> {
  _$MatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? participants = null,
    Object? status = null,
    Object? createdAt = null,
    Object? anonymousPhaseEnds = null,
    Object? revealRequestedBy = freezed,
    Object? revealedAt = freezed,
    Object? archivedAt = freezed,
    Object? archivedReason = freezed,
    Object? lastMessage = freezed,
    Object? updatedAt = freezed,
    Object? participantInfo = freezed,
    Object? revealedParticipantInfo = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            participants: null == participants
                ? _value.participants
                : participants // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as MatchStatus,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            anonymousPhaseEnds: null == anonymousPhaseEnds
                ? _value.anonymousPhaseEnds
                : anonymousPhaseEnds // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            revealRequestedBy: freezed == revealRequestedBy
                ? _value.revealRequestedBy
                : revealRequestedBy // ignore: cast_nullable_to_non_nullable
                      as String?,
            revealedAt: freezed == revealedAt
                ? _value.revealedAt
                : revealedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            archivedAt: freezed == archivedAt
                ? _value.archivedAt
                : archivedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            archivedReason: freezed == archivedReason
                ? _value.archivedReason
                : archivedReason // ignore: cast_nullable_to_non_nullable
                      as String?,
            lastMessage: freezed == lastMessage
                ? _value.lastMessage
                : lastMessage // ignore: cast_nullable_to_non_nullable
                      as MatchLastMessage?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime?,
            participantInfo: freezed == participantInfo
                ? _value.participantInfo
                : participantInfo // ignore: cast_nullable_to_non_nullable
                      as Map<String, ParticipantInfo>?,
            revealedParticipantInfo: freezed == revealedParticipantInfo
                ? _value.revealedParticipantInfo
                : revealedParticipantInfo // ignore: cast_nullable_to_non_nullable
                      as Map<String, RevealedParticipantInfo>?,
          )
          as $Val,
    );
  }

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $MatchLastMessageCopyWith<$Res>? get lastMessage {
    if (_value.lastMessage == null) {
      return null;
    }

    return $MatchLastMessageCopyWith<$Res>(_value.lastMessage!, (value) {
      return _then(_value.copyWith(lastMessage: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$MatchImplCopyWith<$Res> implements $MatchCopyWith<$Res> {
  factory _$$MatchImplCopyWith(
    _$MatchImpl value,
    $Res Function(_$MatchImpl) then,
  ) = __$$MatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    List<String> participants,
    MatchStatus status,
    DateTime createdAt,
    DateTime anonymousPhaseEnds,
    String? revealRequestedBy,
    DateTime? revealedAt,
    DateTime? archivedAt,
    String? archivedReason,
    MatchLastMessage? lastMessage,
    DateTime? updatedAt,
    Map<String, ParticipantInfo>? participantInfo,
    Map<String, RevealedParticipantInfo>? revealedParticipantInfo,
  });

  @override
  $MatchLastMessageCopyWith<$Res>? get lastMessage;
}

/// @nodoc
class __$$MatchImplCopyWithImpl<$Res>
    extends _$MatchCopyWithImpl<$Res, _$MatchImpl>
    implements _$$MatchImplCopyWith<$Res> {
  __$$MatchImplCopyWithImpl(
    _$MatchImpl _value,
    $Res Function(_$MatchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? participants = null,
    Object? status = null,
    Object? createdAt = null,
    Object? anonymousPhaseEnds = null,
    Object? revealRequestedBy = freezed,
    Object? revealedAt = freezed,
    Object? archivedAt = freezed,
    Object? archivedReason = freezed,
    Object? lastMessage = freezed,
    Object? updatedAt = freezed,
    Object? participantInfo = freezed,
    Object? revealedParticipantInfo = freezed,
  }) {
    return _then(
      _$MatchImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        participants: null == participants
            ? _value._participants
            : participants // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as MatchStatus,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        anonymousPhaseEnds: null == anonymousPhaseEnds
            ? _value.anonymousPhaseEnds
            : anonymousPhaseEnds // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        revealRequestedBy: freezed == revealRequestedBy
            ? _value.revealRequestedBy
            : revealRequestedBy // ignore: cast_nullable_to_non_nullable
                  as String?,
        revealedAt: freezed == revealedAt
            ? _value.revealedAt
            : revealedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        archivedAt: freezed == archivedAt
            ? _value.archivedAt
            : archivedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        archivedReason: freezed == archivedReason
            ? _value.archivedReason
            : archivedReason // ignore: cast_nullable_to_non_nullable
                  as String?,
        lastMessage: freezed == lastMessage
            ? _value.lastMessage
            : lastMessage // ignore: cast_nullable_to_non_nullable
                  as MatchLastMessage?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime?,
        participantInfo: freezed == participantInfo
            ? _value._participantInfo
            : participantInfo // ignore: cast_nullable_to_non_nullable
                  as Map<String, ParticipantInfo>?,
        revealedParticipantInfo: freezed == revealedParticipantInfo
            ? _value._revealedParticipantInfo
            : revealedParticipantInfo // ignore: cast_nullable_to_non_nullable
                  as Map<String, RevealedParticipantInfo>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchImpl implements _Match {
  const _$MatchImpl({
    required this.id,
    required final List<String> participants,
    required this.status,
    required this.createdAt,
    required this.anonymousPhaseEnds,
    this.revealRequestedBy,
    this.revealedAt,
    this.archivedAt,
    this.archivedReason,
    this.lastMessage,
    this.updatedAt,
    final Map<String, ParticipantInfo>? participantInfo,
    final Map<String, RevealedParticipantInfo>? revealedParticipantInfo,
  }) : _participants = participants,
       _participantInfo = participantInfo,
       _revealedParticipantInfo = revealedParticipantInfo;

  factory _$MatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchImplFromJson(json);

  @override
  final String id;
  final List<String> _participants;
  @override
  List<String> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  final MatchStatus status;
  @override
  final DateTime createdAt;
  @override
  final DateTime anonymousPhaseEnds;
  @override
  final String? revealRequestedBy;
  @override
  final DateTime? revealedAt;
  @override
  final DateTime? archivedAt;
  @override
  final String? archivedReason;
  @override
  final MatchLastMessage? lastMessage;
  @override
  final DateTime? updatedAt;
  final Map<String, ParticipantInfo>? _participantInfo;
  @override
  Map<String, ParticipantInfo>? get participantInfo {
    final value = _participantInfo;
    if (value == null) return null;
    if (_participantInfo is EqualUnmodifiableMapView) return _participantInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  final Map<String, RevealedParticipantInfo>? _revealedParticipantInfo;
  @override
  Map<String, RevealedParticipantInfo>? get revealedParticipantInfo {
    final value = _revealedParticipantInfo;
    if (value == null) return null;
    if (_revealedParticipantInfo is EqualUnmodifiableMapView)
      return _revealedParticipantInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  String toString() {
    return 'Match(id: $id, participants: $participants, status: $status, createdAt: $createdAt, anonymousPhaseEnds: $anonymousPhaseEnds, revealRequestedBy: $revealRequestedBy, revealedAt: $revealedAt, archivedAt: $archivedAt, archivedReason: $archivedReason, lastMessage: $lastMessage, updatedAt: $updatedAt, participantInfo: $participantInfo, revealedParticipantInfo: $revealedParticipantInfo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchImpl &&
            (identical(other.id, id) || other.id == id) &&
            const DeepCollectionEquality().equals(
              other._participants,
              _participants,
            ) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.anonymousPhaseEnds, anonymousPhaseEnds) ||
                other.anonymousPhaseEnds == anonymousPhaseEnds) &&
            (identical(other.revealRequestedBy, revealRequestedBy) ||
                other.revealRequestedBy == revealRequestedBy) &&
            (identical(other.revealedAt, revealedAt) ||
                other.revealedAt == revealedAt) &&
            (identical(other.archivedAt, archivedAt) ||
                other.archivedAt == archivedAt) &&
            (identical(other.archivedReason, archivedReason) ||
                other.archivedReason == archivedReason) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(
              other._participantInfo,
              _participantInfo,
            ) &&
            const DeepCollectionEquality().equals(
              other._revealedParticipantInfo,
              _revealedParticipantInfo,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    const DeepCollectionEquality().hash(_participants),
    status,
    createdAt,
    anonymousPhaseEnds,
    revealRequestedBy,
    revealedAt,
    archivedAt,
    archivedReason,
    lastMessage,
    updatedAt,
    const DeepCollectionEquality().hash(_participantInfo),
    const DeepCollectionEquality().hash(_revealedParticipantInfo),
  );

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchImplCopyWith<_$MatchImpl> get copyWith =>
      __$$MatchImplCopyWithImpl<_$MatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchImplToJson(this);
  }
}

abstract class _Match implements Match {
  const factory _Match({
    required final String id,
    required final List<String> participants,
    required final MatchStatus status,
    required final DateTime createdAt,
    required final DateTime anonymousPhaseEnds,
    final String? revealRequestedBy,
    final DateTime? revealedAt,
    final DateTime? archivedAt,
    final String? archivedReason,
    final MatchLastMessage? lastMessage,
    final DateTime? updatedAt,
    final Map<String, ParticipantInfo>? participantInfo,
    final Map<String, RevealedParticipantInfo>? revealedParticipantInfo,
  }) = _$MatchImpl;

  factory _Match.fromJson(Map<String, dynamic> json) = _$MatchImpl.fromJson;

  @override
  String get id;
  @override
  List<String> get participants;
  @override
  MatchStatus get status;
  @override
  DateTime get createdAt;
  @override
  DateTime get anonymousPhaseEnds;
  @override
  String? get revealRequestedBy;
  @override
  DateTime? get revealedAt;
  @override
  DateTime? get archivedAt;
  @override
  String? get archivedReason;
  @override
  MatchLastMessage? get lastMessage;
  @override
  DateTime? get updatedAt;
  @override
  Map<String, ParticipantInfo>? get participantInfo;
  @override
  Map<String, RevealedParticipantInfo>? get revealedParticipantInfo;

  /// Create a copy of Match
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchImplCopyWith<_$MatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

MatchLastMessage _$MatchLastMessageFromJson(Map<String, dynamic> json) {
  return _MatchLastMessage.fromJson(json);
}

/// @nodoc
mixin _$MatchLastMessage {
  String get content => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String get senderId => throw _privateConstructorUsedError;

  /// Serializes this MatchLastMessage to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of MatchLastMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $MatchLastMessageCopyWith<MatchLastMessage> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MatchLastMessageCopyWith<$Res> {
  factory $MatchLastMessageCopyWith(
    MatchLastMessage value,
    $Res Function(MatchLastMessage) then,
  ) = _$MatchLastMessageCopyWithImpl<$Res, MatchLastMessage>;
  @useResult
  $Res call({String content, DateTime timestamp, String senderId});
}

/// @nodoc
class _$MatchLastMessageCopyWithImpl<$Res, $Val extends MatchLastMessage>
    implements $MatchLastMessageCopyWith<$Res> {
  _$MatchLastMessageCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of MatchLastMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? timestamp = null,
    Object? senderId = null,
  }) {
    return _then(
      _value.copyWith(
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            timestamp: null == timestamp
                ? _value.timestamp
                : timestamp // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            senderId: null == senderId
                ? _value.senderId
                : senderId // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$MatchLastMessageImplCopyWith<$Res>
    implements $MatchLastMessageCopyWith<$Res> {
  factory _$$MatchLastMessageImplCopyWith(
    _$MatchLastMessageImpl value,
    $Res Function(_$MatchLastMessageImpl) then,
  ) = __$$MatchLastMessageImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String content, DateTime timestamp, String senderId});
}

/// @nodoc
class __$$MatchLastMessageImplCopyWithImpl<$Res>
    extends _$MatchLastMessageCopyWithImpl<$Res, _$MatchLastMessageImpl>
    implements _$$MatchLastMessageImplCopyWith<$Res> {
  __$$MatchLastMessageImplCopyWithImpl(
    _$MatchLastMessageImpl _value,
    $Res Function(_$MatchLastMessageImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of MatchLastMessage
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? content = null,
    Object? timestamp = null,
    Object? senderId = null,
  }) {
    return _then(
      _$MatchLastMessageImpl(
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        timestamp: null == timestamp
            ? _value.timestamp
            : timestamp // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        senderId: null == senderId
            ? _value.senderId
            : senderId // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$MatchLastMessageImpl implements _MatchLastMessage {
  const _$MatchLastMessageImpl({
    required this.content,
    required this.timestamp,
    required this.senderId,
  });

  factory _$MatchLastMessageImpl.fromJson(Map<String, dynamic> json) =>
      _$$MatchLastMessageImplFromJson(json);

  @override
  final String content;
  @override
  final DateTime timestamp;
  @override
  final String senderId;

  @override
  String toString() {
    return 'MatchLastMessage(content: $content, timestamp: $timestamp, senderId: $senderId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MatchLastMessageImpl &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, content, timestamp, senderId);

  /// Create a copy of MatchLastMessage
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$MatchLastMessageImplCopyWith<_$MatchLastMessageImpl> get copyWith =>
      __$$MatchLastMessageImplCopyWithImpl<_$MatchLastMessageImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$MatchLastMessageImplToJson(this);
  }
}

abstract class _MatchLastMessage implements MatchLastMessage {
  const factory _MatchLastMessage({
    required final String content,
    required final DateTime timestamp,
    required final String senderId,
  }) = _$MatchLastMessageImpl;

  factory _MatchLastMessage.fromJson(Map<String, dynamic> json) =
      _$MatchLastMessageImpl.fromJson;

  @override
  String get content;
  @override
  DateTime get timestamp;
  @override
  String get senderId;

  /// Create a copy of MatchLastMessage
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$MatchLastMessageImplCopyWith<_$MatchLastMessageImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ParticipantInfo _$ParticipantInfoFromJson(Map<String, dynamic> json) {
  return _ParticipantInfo.fromJson(json);
}

/// @nodoc
mixin _$ParticipantInfo {
  LocationInfo get location => throw _privateConstructorUsedError;
  DateTime get joinedAt => throw _privateConstructorUsedError;

  /// Serializes this ParticipantInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParticipantInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParticipantInfoCopyWith<ParticipantInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParticipantInfoCopyWith<$Res> {
  factory $ParticipantInfoCopyWith(
    ParticipantInfo value,
    $Res Function(ParticipantInfo) then,
  ) = _$ParticipantInfoCopyWithImpl<$Res, ParticipantInfo>;
  @useResult
  $Res call({LocationInfo location, DateTime joinedAt});

  $LocationInfoCopyWith<$Res> get location;
}

/// @nodoc
class _$ParticipantInfoCopyWithImpl<$Res, $Val extends ParticipantInfo>
    implements $ParticipantInfoCopyWith<$Res> {
  _$ParticipantInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParticipantInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? location = null, Object? joinedAt = null}) {
    return _then(
      _value.copyWith(
            location: null == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as LocationInfo,
            joinedAt: null == joinedAt
                ? _value.joinedAt
                : joinedAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }

  /// Create a copy of ParticipantInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LocationInfoCopyWith<$Res> get location {
    return $LocationInfoCopyWith<$Res>(_value.location, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$ParticipantInfoImplCopyWith<$Res>
    implements $ParticipantInfoCopyWith<$Res> {
  factory _$$ParticipantInfoImplCopyWith(
    _$ParticipantInfoImpl value,
    $Res Function(_$ParticipantInfoImpl) then,
  ) = __$$ParticipantInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({LocationInfo location, DateTime joinedAt});

  @override
  $LocationInfoCopyWith<$Res> get location;
}

/// @nodoc
class __$$ParticipantInfoImplCopyWithImpl<$Res>
    extends _$ParticipantInfoCopyWithImpl<$Res, _$ParticipantInfoImpl>
    implements _$$ParticipantInfoImplCopyWith<$Res> {
  __$$ParticipantInfoImplCopyWithImpl(
    _$ParticipantInfoImpl _value,
    $Res Function(_$ParticipantInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParticipantInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? location = null, Object? joinedAt = null}) {
    return _then(
      _$ParticipantInfoImpl(
        location: null == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as LocationInfo,
        joinedAt: null == joinedAt
            ? _value.joinedAt
            : joinedAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ParticipantInfoImpl implements _ParticipantInfo {
  const _$ParticipantInfoImpl({required this.location, required this.joinedAt});

  factory _$ParticipantInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParticipantInfoImplFromJson(json);

  @override
  final LocationInfo location;
  @override
  final DateTime joinedAt;

  @override
  String toString() {
    return 'ParticipantInfo(location: $location, joinedAt: $joinedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParticipantInfoImpl &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.joinedAt, joinedAt) ||
                other.joinedAt == joinedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, location, joinedAt);

  /// Create a copy of ParticipantInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParticipantInfoImplCopyWith<_$ParticipantInfoImpl> get copyWith =>
      __$$ParticipantInfoImplCopyWithImpl<_$ParticipantInfoImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$ParticipantInfoImplToJson(this);
  }
}

abstract class _ParticipantInfo implements ParticipantInfo {
  const factory _ParticipantInfo({
    required final LocationInfo location,
    required final DateTime joinedAt,
  }) = _$ParticipantInfoImpl;

  factory _ParticipantInfo.fromJson(Map<String, dynamic> json) =
      _$ParticipantInfoImpl.fromJson;

  @override
  LocationInfo get location;
  @override
  DateTime get joinedAt;

  /// Create a copy of ParticipantInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParticipantInfoImplCopyWith<_$ParticipantInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RevealedParticipantInfo _$RevealedParticipantInfoFromJson(
  Map<String, dynamic> json,
) {
  return _RevealedParticipantInfo.fromJson(json);
}

/// @nodoc
mixin _$RevealedParticipantInfo {
  String get displayName => throw _privateConstructorUsedError;
  String? get photoURL => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;

  /// Serializes this RevealedParticipantInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RevealedParticipantInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RevealedParticipantInfoCopyWith<RevealedParticipantInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RevealedParticipantInfoCopyWith<$Res> {
  factory $RevealedParticipantInfoCopyWith(
    RevealedParticipantInfo value,
    $Res Function(RevealedParticipantInfo) then,
  ) = _$RevealedParticipantInfoCopyWithImpl<$Res, RevealedParticipantInfo>;
  @useResult
  $Res call({String displayName, String? photoURL, String? email});
}

/// @nodoc
class _$RevealedParticipantInfoCopyWithImpl<
  $Res,
  $Val extends RevealedParticipantInfo
>
    implements $RevealedParticipantInfoCopyWith<$Res> {
  _$RevealedParticipantInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RevealedParticipantInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayName = null,
    Object? photoURL = freezed,
    Object? email = freezed,
  }) {
    return _then(
      _value.copyWith(
            displayName: null == displayName
                ? _value.displayName
                : displayName // ignore: cast_nullable_to_non_nullable
                      as String,
            photoURL: freezed == photoURL
                ? _value.photoURL
                : photoURL // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RevealedParticipantInfoImplCopyWith<$Res>
    implements $RevealedParticipantInfoCopyWith<$Res> {
  factory _$$RevealedParticipantInfoImplCopyWith(
    _$RevealedParticipantInfoImpl value,
    $Res Function(_$RevealedParticipantInfoImpl) then,
  ) = __$$RevealedParticipantInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String displayName, String? photoURL, String? email});
}

/// @nodoc
class __$$RevealedParticipantInfoImplCopyWithImpl<$Res>
    extends
        _$RevealedParticipantInfoCopyWithImpl<
          $Res,
          _$RevealedParticipantInfoImpl
        >
    implements _$$RevealedParticipantInfoImplCopyWith<$Res> {
  __$$RevealedParticipantInfoImplCopyWithImpl(
    _$RevealedParticipantInfoImpl _value,
    $Res Function(_$RevealedParticipantInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RevealedParticipantInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? displayName = null,
    Object? photoURL = freezed,
    Object? email = freezed,
  }) {
    return _then(
      _$RevealedParticipantInfoImpl(
        displayName: null == displayName
            ? _value.displayName
            : displayName // ignore: cast_nullable_to_non_nullable
                  as String,
        photoURL: freezed == photoURL
            ? _value.photoURL
            : photoURL // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: freezed == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RevealedParticipantInfoImpl implements _RevealedParticipantInfo {
  const _$RevealedParticipantInfoImpl({
    required this.displayName,
    this.photoURL,
    this.email,
  });

  factory _$RevealedParticipantInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$RevealedParticipantInfoImplFromJson(json);

  @override
  final String displayName;
  @override
  final String? photoURL;
  @override
  final String? email;

  @override
  String toString() {
    return 'RevealedParticipantInfo(displayName: $displayName, photoURL: $photoURL, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RevealedParticipantInfoImpl &&
            (identical(other.displayName, displayName) ||
                other.displayName == displayName) &&
            (identical(other.photoURL, photoURL) ||
                other.photoURL == photoURL) &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, displayName, photoURL, email);

  /// Create a copy of RevealedParticipantInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RevealedParticipantInfoImplCopyWith<_$RevealedParticipantInfoImpl>
  get copyWith =>
      __$$RevealedParticipantInfoImplCopyWithImpl<
        _$RevealedParticipantInfoImpl
      >(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RevealedParticipantInfoImplToJson(this);
  }
}

abstract class _RevealedParticipantInfo implements RevealedParticipantInfo {
  const factory _RevealedParticipantInfo({
    required final String displayName,
    final String? photoURL,
    final String? email,
  }) = _$RevealedParticipantInfoImpl;

  factory _RevealedParticipantInfo.fromJson(Map<String, dynamic> json) =
      _$RevealedParticipantInfoImpl.fromJson;

  @override
  String get displayName;
  @override
  String? get photoURL;
  @override
  String? get email;

  /// Create a copy of RevealedParticipantInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RevealedParticipantInfoImplCopyWith<_$RevealedParticipantInfoImpl>
  get copyWith => throw _privateConstructorUsedError;
}

LocationInfo _$LocationInfoFromJson(Map<String, dynamic> json) {
  return _LocationInfo.fromJson(json);
}

/// @nodoc
mixin _$LocationInfo {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;

  /// Serializes this LocationInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of LocationInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LocationInfoCopyWith<LocationInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationInfoCopyWith<$Res> {
  factory $LocationInfoCopyWith(
    LocationInfo value,
    $Res Function(LocationInfo) then,
  ) = _$LocationInfoCopyWithImpl<$Res, LocationInfo>;
  @useResult
  $Res call({double latitude, double longitude});
}

/// @nodoc
class _$LocationInfoCopyWithImpl<$Res, $Val extends LocationInfo>
    implements $LocationInfoCopyWith<$Res> {
  _$LocationInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LocationInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? latitude = null, Object? longitude = null}) {
    return _then(
      _value.copyWith(
            latitude: null == latitude
                ? _value.latitude
                : latitude // ignore: cast_nullable_to_non_nullable
                      as double,
            longitude: null == longitude
                ? _value.longitude
                : longitude // ignore: cast_nullable_to_non_nullable
                      as double,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LocationInfoImplCopyWith<$Res>
    implements $LocationInfoCopyWith<$Res> {
  factory _$$LocationInfoImplCopyWith(
    _$LocationInfoImpl value,
    $Res Function(_$LocationInfoImpl) then,
  ) = __$$LocationInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double latitude, double longitude});
}

/// @nodoc
class __$$LocationInfoImplCopyWithImpl<$Res>
    extends _$LocationInfoCopyWithImpl<$Res, _$LocationInfoImpl>
    implements _$$LocationInfoImplCopyWith<$Res> {
  __$$LocationInfoImplCopyWithImpl(
    _$LocationInfoImpl _value,
    $Res Function(_$LocationInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LocationInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? latitude = null, Object? longitude = null}) {
    return _then(
      _$LocationInfoImpl(
        latitude: null == latitude
            ? _value.latitude
            : latitude // ignore: cast_nullable_to_non_nullable
                  as double,
        longitude: null == longitude
            ? _value.longitude
            : longitude // ignore: cast_nullable_to_non_nullable
                  as double,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationInfoImpl implements _LocationInfo {
  const _$LocationInfoImpl({required this.latitude, required this.longitude});

  factory _$LocationInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationInfoImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;

  @override
  String toString() {
    return 'LocationInfo(latitude: $latitude, longitude: $longitude)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationInfoImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, latitude, longitude);

  /// Create a copy of LocationInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationInfoImplCopyWith<_$LocationInfoImpl> get copyWith =>
      __$$LocationInfoImplCopyWithImpl<_$LocationInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationInfoImplToJson(this);
  }
}

abstract class _LocationInfo implements LocationInfo {
  const factory _LocationInfo({
    required final double latitude,
    required final double longitude,
  }) = _$LocationInfoImpl;

  factory _LocationInfo.fromJson(Map<String, dynamic> json) =
      _$LocationInfoImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;

  /// Create a copy of LocationInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LocationInfoImplCopyWith<_$LocationInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
