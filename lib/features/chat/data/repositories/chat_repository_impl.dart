import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:amazon_syria/features/chat/domain/entities/chat_room_entity.dart';
import 'package:amazon_syria/features/chat/domain/entities/message_entity.dart';
import 'package:amazon_syria/features/chat/domain/repositories/chat_repository.dart';
import 'package:amazon_syria/features/chat/data/models/chat_room_model.dart';
import 'package:amazon_syria/features/chat/data/models/message_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _chatRoomsRef => _firestore.collection('chat_rooms');

  @override
  Stream<List<ChatRoomEntity>> getChatRooms(String userId) {
    return _chatRoomsRef
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return ChatRoomModel.fromMap(
                doc.data() as Map<String, dynamic>,
                doc.id,
              );
            }).toList());
  }

  @override
  Stream<List<MessageEntity>> getMessages(String chatRoomId) {
    return _chatRoomsRef
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return MessageModel.fromMap(
                doc.data(),
                doc.id,
              );
            }).toList());
  }

  @override
  Future<void> sendMessage(MessageEntity message) async {
    final model = MessageModel.fromEntity(message);

    await _chatRoomsRef
        .doc(message.chatRoomId)
        .collection('messages')
        .add(model.toMap());

    await _chatRoomsRef.doc(message.chatRoomId).update({
      'lastMessage': message.text,
      'lastMessageTime': Timestamp.fromDate(message.createdAt),
    });
  }

  @override
  Future<String> createOrGetChatRoom(
    String currentUserId,
    String currentUserName,
    String otherUserId,
    String otherUserName,
  ) async {
    final query = await _chatRoomsRef
        .where('participantIds', arrayContains: currentUserId)
        .get();

    for (final doc in query.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final ids = List<String>.from(data['participantIds'] ?? []);
      if (ids.contains(otherUserId)) {
        return doc.id;
      }
    }

    final newRoom = await _chatRoomsRef.add({
      'participantIds': [currentUserId, otherUserId],
      'participantNames': {
        currentUserId: currentUserName,
        otherUserId: otherUserName,
      },
      'lastMessage': null,
      'lastMessageTime': null,
      'createdAt': Timestamp.now(),
    });

    return newRoom.id;
  }
}
