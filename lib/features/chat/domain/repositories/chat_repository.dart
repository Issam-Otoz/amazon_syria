import 'package:amazon_syria/features/chat/domain/entities/chat_room_entity.dart';
import 'package:amazon_syria/features/chat/domain/entities/message_entity.dart';

abstract class ChatRepository {
  Stream<List<ChatRoomEntity>> getChatRooms(String userId);

  Stream<List<MessageEntity>> getMessages(String chatRoomId);

  Future<void> sendMessage(MessageEntity message);

  Future<String> createOrGetChatRoom(
    String currentUserId,
    String currentUserName,
    String otherUserId,
    String otherUserName,
  );
}
