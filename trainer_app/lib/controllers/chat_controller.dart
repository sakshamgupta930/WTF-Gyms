import 'dart:async';
import 'package:get/get.dart';
import 'storage_controller.dart';
import 'socket_controller.dart';
import 'package:trainer_app/models/models.dart';

class ChatController extends GetxController {
  final _storage = Get.find<StorageController>();
  final _socket = Get.find<SocketController>();

  Timer? _typingTimer;

  List<MessageModel> get messages => _storage.chats;
  bool get isMemberTyping => _socket.isTyping.value;

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final msg = MessageModel(
      id: 'msg_' + DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: 'dk_aarav_chat',
      senderId: 'aarav_trainer',
      receiverId: 'dk_member',
      text: text,
      createdAt: DateTime.now(),
      status: 'sent',
    );

    // Save locally
    _storage.saveMessage(msg);

    // Send over WebSocket to Guru client
    _socket.broadcast({
      'type': 'chat',
      'message': msg.toJson()
    });
  }

  void startTyping() {
    _socket.broadcast({
      'type': 'typing',
      'isTyping': true,
      'userId': 'aarav_trainer'
    });
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 1200), () {
      stopTyping();
    });
  }

  void stopTyping() {
    _socket.broadcast({
      'type': 'typing',
      'isTyping': false,
      'userId': 'aarav_trainer'
    });
  }
}
