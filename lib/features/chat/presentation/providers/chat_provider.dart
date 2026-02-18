import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:amazon_syria/features/chat/domain/entities/chat_room_entity.dart';
import 'package:amazon_syria/features/chat/domain/entities/message_entity.dart';
import 'package:amazon_syria/features/chat/domain/repositories/chat_repository.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository;

  List<ChatRoomEntity> _chatRooms = [];
  List<MessageEntity> _messages = [];
  bool _isLoading = false;
  String? _error;

  StreamSubscription<List<ChatRoomEntity>>? _roomsSub;
  StreamSubscription<List<MessageEntity>>? _messagesSub;

  ChatProvider(this._repository);

  List<ChatRoomEntity> get chatRooms => _chatRooms;
  List<MessageEntity> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadChatRooms(String userId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _roomsSub?.cancel();
    _roomsSub = _repository.getChatRooms(userId).listen(
      (rooms) {
        _chatRooms = rooms;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = 'حدث خطأ في تحميل المحادثات';
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void loadMessages(String chatRoomId) {
    _messagesSub?.cancel();
    _messagesSub = _repository.getMessages(chatRoomId).listen(
      (msgs) {
        _messages = msgs;
        notifyListeners();
      },
      onError: (e) {
        _error = 'حدث خطأ في تحميل الرسائل';
        notifyListeners();
      },
    );
  }

  Future<void> sendMessage(MessageEntity message) async {
    try {
      _error = null;
      await _repository.sendMessage(message);
    } catch (e) {
      _error = 'فشل إرسال الرسالة';
      notifyListeners();
    }
  }

  Future<String> createOrGetChatRoom(
    String currentUserId,
    String currentUserName,
    String otherUserId,
    String otherUserName,
  ) async {
    try {
      _error = null;
      return await _repository.createOrGetChatRoom(
        currentUserId,
        currentUserName,
        otherUserId,
        otherUserName,
      );
    } catch (e) {
      _error = 'فشل إنشاء المحادثة';
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _roomsSub?.cancel();
    _messagesSub?.cancel();
    super.dispose();
  }
}
