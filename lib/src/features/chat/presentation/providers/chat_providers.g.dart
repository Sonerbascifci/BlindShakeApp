// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$chatServiceHash() => r'b9998fa2d42956e2e80a1f29370868db8f5e1c22';

/// Provider for chat service instance
///
/// Copied from [chatService].
@ProviderFor(chatService)
final chatServiceProvider = AutoDisposeProvider<ChatService>.internal(
  chatService,
  name: r'chatServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$chatServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ChatServiceRef = AutoDisposeProviderRef<ChatService>;
String _$messagesStreamHash() => r'6331f7bbdfb4b1e4f5940f1a3a34e4aa1707a539';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// Provider for messages stream for a specific match
///
/// Copied from [messagesStream].
@ProviderFor(messagesStream)
const messagesStreamProvider = MessagesStreamFamily();

/// Provider for messages stream for a specific match
///
/// Copied from [messagesStream].
class MessagesStreamFamily extends Family<AsyncValue<List<ChatMessage>>> {
  /// Provider for messages stream for a specific match
  ///
  /// Copied from [messagesStream].
  const MessagesStreamFamily();

  /// Provider for messages stream for a specific match
  ///
  /// Copied from [messagesStream].
  MessagesStreamProvider call(String matchId) {
    return MessagesStreamProvider(matchId);
  }

  @override
  MessagesStreamProvider getProviderOverride(
    covariant MessagesStreamProvider provider,
  ) {
    return call(provider.matchId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'messagesStreamProvider';
}

/// Provider for messages stream for a specific match
///
/// Copied from [messagesStream].
class MessagesStreamProvider
    extends AutoDisposeStreamProvider<List<ChatMessage>> {
  /// Provider for messages stream for a specific match
  ///
  /// Copied from [messagesStream].
  MessagesStreamProvider(String matchId)
    : this._internal(
        (ref) => messagesStream(ref as MessagesStreamRef, matchId),
        from: messagesStreamProvider,
        name: r'messagesStreamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$messagesStreamHash,
        dependencies: MessagesStreamFamily._dependencies,
        allTransitiveDependencies:
            MessagesStreamFamily._allTransitiveDependencies,
        matchId: matchId,
      );

  MessagesStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.matchId,
  }) : super.internal();

  final String matchId;

  @override
  Override overrideWith(
    Stream<List<ChatMessage>> Function(MessagesStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MessagesStreamProvider._internal(
        (ref) => create(ref as MessagesStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        matchId: matchId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<List<ChatMessage>> createElement() {
    return _MessagesStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MessagesStreamProvider && other.matchId == matchId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, matchId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MessagesStreamRef on AutoDisposeStreamProviderRef<List<ChatMessage>> {
  /// The parameter `matchId` of this provider.
  String get matchId;
}

class _MessagesStreamProviderElement
    extends AutoDisposeStreamProviderElement<List<ChatMessage>>
    with MessagesStreamRef {
  _MessagesStreamProviderElement(super.provider);

  @override
  String get matchId => (origin as MessagesStreamProvider).matchId;
}

String _$matchInfoStreamHash() => r'b548d94e5428b4a7ace94b44c45ede75c92504a2';

/// Provider for match info stream
///
/// Copied from [matchInfoStream].
@ProviderFor(matchInfoStream)
const matchInfoStreamProvider = MatchInfoStreamFamily();

/// Provider for match info stream
///
/// Copied from [matchInfoStream].
class MatchInfoStreamFamily extends Family<AsyncValue<MatchInfo>> {
  /// Provider for match info stream
  ///
  /// Copied from [matchInfoStream].
  const MatchInfoStreamFamily();

  /// Provider for match info stream
  ///
  /// Copied from [matchInfoStream].
  MatchInfoStreamProvider call(String matchId) {
    return MatchInfoStreamProvider(matchId);
  }

  @override
  MatchInfoStreamProvider getProviderOverride(
    covariant MatchInfoStreamProvider provider,
  ) {
    return call(provider.matchId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'matchInfoStreamProvider';
}

/// Provider for match info stream
///
/// Copied from [matchInfoStream].
class MatchInfoStreamProvider extends AutoDisposeStreamProvider<MatchInfo> {
  /// Provider for match info stream
  ///
  /// Copied from [matchInfoStream].
  MatchInfoStreamProvider(String matchId)
    : this._internal(
        (ref) => matchInfoStream(ref as MatchInfoStreamRef, matchId),
        from: matchInfoStreamProvider,
        name: r'matchInfoStreamProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$matchInfoStreamHash,
        dependencies: MatchInfoStreamFamily._dependencies,
        allTransitiveDependencies:
            MatchInfoStreamFamily._allTransitiveDependencies,
        matchId: matchId,
      );

  MatchInfoStreamProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.matchId,
  }) : super.internal();

  final String matchId;

  @override
  Override overrideWith(
    Stream<MatchInfo> Function(MatchInfoStreamRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: MatchInfoStreamProvider._internal(
        (ref) => create(ref as MatchInfoStreamRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        matchId: matchId,
      ),
    );
  }

  @override
  AutoDisposeStreamProviderElement<MatchInfo> createElement() {
    return _MatchInfoStreamProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MatchInfoStreamProvider && other.matchId == matchId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, matchId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MatchInfoStreamRef on AutoDisposeStreamProviderRef<MatchInfo> {
  /// The parameter `matchId` of this provider.
  String get matchId;
}

class _MatchInfoStreamProviderElement
    extends AutoDisposeStreamProviderElement<MatchInfo>
    with MatchInfoStreamRef {
  _MatchInfoStreamProviderElement(super.provider);

  @override
  String get matchId => (origin as MatchInfoStreamProvider).matchId;
}

String _$chatMessagesNotifierHash() =>
    r'909353eb526b8320f1d66f81b755e5b77fffef8e';

/// Provider for current chat messages state
///
/// Copied from [ChatMessagesNotifier].
@ProviderFor(ChatMessagesNotifier)
final chatMessagesNotifierProvider =
    AutoDisposeNotifierProvider<
      ChatMessagesNotifier,
      List<ChatMessage>
    >.internal(
      ChatMessagesNotifier.new,
      name: r'chatMessagesNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatMessagesNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatMessagesNotifier = AutoDisposeNotifier<List<ChatMessage>>;
String _$chatErrorNotifierHash() => r'1c92ee30e15cafe667b6a9ea7530436a57274a43';

/// Provider for chat error state
///
/// Copied from [ChatErrorNotifier].
@ProviderFor(ChatErrorNotifier)
final chatErrorNotifierProvider =
    AutoDisposeNotifierProvider<ChatErrorNotifier, String?>.internal(
      ChatErrorNotifier.new,
      name: r'chatErrorNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatErrorNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatErrorNotifier = AutoDisposeNotifier<String?>;
String _$sendingMessageNotifierHash() =>
    r'23ff2df32103a9d9abb763f7b8efdbd90e7ec6b8';

/// Provider for sending message loading state
///
/// Copied from [SendingMessageNotifier].
@ProviderFor(SendingMessageNotifier)
final sendingMessageNotifierProvider =
    AutoDisposeNotifierProvider<SendingMessageNotifier, bool>.internal(
      SendingMessageNotifier.new,
      name: r'sendingMessageNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$sendingMessageNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$SendingMessageNotifier = AutoDisposeNotifier<bool>;
String _$matchInfoNotifierHash() => r'c039ab9633e38358d924229549de99ca2ddfaf13';

/// Provider for match info state
///
/// Copied from [MatchInfoNotifier].
@ProviderFor(MatchInfoNotifier)
final matchInfoNotifierProvider =
    AutoDisposeNotifierProvider<MatchInfoNotifier, MatchInfo?>.internal(
      MatchInfoNotifier.new,
      name: r'matchInfoNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$matchInfoNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$MatchInfoNotifier = AutoDisposeNotifier<MatchInfo?>;
String _$chatControllerNotifierHash() =>
    r'e1e118e063913cf033beb933ac1b51c2435f6c1a';

/// Provider for unified chat controller
///
/// Copied from [ChatControllerNotifier].
@ProviderFor(ChatControllerNotifier)
final chatControllerNotifierProvider =
    AutoDisposeAsyncNotifierProvider<ChatControllerNotifier, void>.internal(
      ChatControllerNotifier.new,
      name: r'chatControllerNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$chatControllerNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ChatControllerNotifier = AutoDisposeAsyncNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
