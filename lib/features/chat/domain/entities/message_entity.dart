class MessageEntity {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;

  const MessageEntity({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'MessageEntity(id: $id, senderId: $senderId, text: $text)';
}
