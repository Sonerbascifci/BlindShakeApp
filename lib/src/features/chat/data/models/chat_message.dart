import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

/// Represents a chat message in a match
@freezed
class ChatMessage with _$ChatMessage {
  const ChatMessage._();

  const factory ChatMessage({
    required String id,
    required String senderId,
    required String content,
    required DateTime timestamp,
    @Default(MessageType.text) MessageType type,
  }) = _ChatMessage;

  /// Create from Firestore document
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['senderId'] as String,
      content: data['content'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      type: MessageType.fromString(data['type'] as String? ?? 'text'),
    );
  }

  /// Create from JSON
  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type.value,
    };
  }
}

/// Message type enum
enum MessageType {
  text('text'),
  system('system'),
  revealRequest('reveal_request');

  final String value;
  const MessageType(this.value);

  static MessageType fromString(String value) {
    return MessageType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => MessageType.text,
    );
  }
}
