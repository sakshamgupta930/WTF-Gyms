import 'dart:async';
import 'package:get/get.dart';
import 'storage_controller.dart';
import 'socket_controller.dart';
import 'package:guru_app/models/models.dart';

class ChatController extends GetxController {
  final _storage = Get.find<StorageController>();
  final _socket = Get.find<SocketController>();

  Timer? _typingTimer;

  List<MessageModel> get messages => _storage.chats;
  bool get isTrainerTyping => _socket.isTyping.value;

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final msg = MessageModel(
      id: 'msg_' + DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: 'dk_aarav_chat',
      senderId: 'dk_member',
      receiverId: 'aarav_trainer',
      text: text,
      createdAt: DateTime.now(),
      status: 'sending',
    );

    // Dispatches via socket (optimistically saves locally)
    _socket.sendMessage(msg);
  }

  void startTyping() {
    _socket.sendTyping(true);
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 1200), () {
      stopTyping();
    });
  }

  void stopTyping() {
    _socket.sendTyping(false);
  }
}
