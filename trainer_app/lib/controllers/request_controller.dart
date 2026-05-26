import 'package:get/get.dart';
import 'storage_controller.dart';
import 'socket_controller.dart';
import 'package:trainer_app/models/models.dart';
import 'package:trainer_app/utils/utils.dart';

class RequestController extends GetxController {
  final _storage = Get.find<StorageController>();
  final _socket = Get.find<SocketController>();

  List<CallRequestModel> get requests => _storage.requests;

  void approveRequest(String requestId) {
    final idx = requests.indexWhere((element) => element.id == requestId);
    if (idx != -1) {
      final updated = requests[idx].copyWith(status: 'approved');
      _storage.saveRequest(updated);

      // Post system message to chat
      final timeStr = _formatTime(updated.scheduledFor);
      final sysMsg = MessageModel(
        id: 'sys_' + DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: 'dk_aarav_chat',
        senderId: 'system',
        receiverId: 'dk_member',
        text: 'Call approved for $timeStr.',
        createdAt: DateTime.now(),
        status: 'read',
      );
      _storage.saveMessage(sysMsg);

      // Broadcast over WebSockets
      _socket.broadcast({
        'type': 'call_request_sync',
        'request': updated.toJson()
      });
      _socket.broadcast({
        'type': 'chat',
        'message': sysMsg.toJson()
      });
      AppLogger.info('SCHEDULE', 'Approved call request: $requestId');
    }
  }

  void declineRequest(String requestId, String reason) {
    final idx = requests.indexWhere((element) => element.id == requestId);
    if (idx != -1) {
      final updated = requests[idx].copyWith(
        status: 'declined',
        declineReason: reason,
      );
      _storage.saveRequest(updated);

      // Post system message to chat
      final sysMsg = MessageModel(
        id: 'sys_' + DateTime.now().millisecondsSinceEpoch.toString(),
        chatId: 'dk_aarav_chat',
        senderId: 'system',
        receiverId: 'dk_member',
        text: 'Call request declined. Reason: $reason',
        createdAt: DateTime.now(),
        status: 'read',
      );
      _storage.saveMessage(sysMsg);

      // Broadcast over WebSockets
      _socket.broadcast({
        'type': 'call_request_sync',
        'request': updated.toJson()
      });
      _socket.broadcast({
        'type': 'chat',
        'message': sysMsg.toJson()
      });
      AppLogger.warn('SCHEDULE', 'Declined call request: $requestId, reason: $reason');
    }
  }

  String _formatTime(DateTime time) {
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    final displayHour = time.hour > 12 ? time.hour - 12 : (time.hour == 0 ? 12 : time.hour);
    return '$displayHour:$minute $period';
  }
}
