import 'dart:async';
import 'package:get/get.dart';
import 'storage_controller.dart';
import 'socket_controller.dart';
import 'package:trainer_app/models/models.dart';
import 'package:trainer_app/utils/utils.dart';

class CallController extends GetxController {
  final _storage = Get.find<StorageController>();
  final _socket = Get.find<SocketController>();

  var isMicOn = true.obs;
  var isCamOn = true.obs;
  var isJoined = false.obs;
  var peerState = 'idle'.obs; // 'idle', 'joining', 'in-call', 'ended'
  var isReconnecting = false.obs;
  var isLocalCamFlipped = false.obs;

  Timer? _durationTimer;
  var durationSec = 0.obs;
  DateTime? callStartTime;

  void toggleMic() {
    isMicOn.value = !isMicOn.value;
    AppLogger.info('RTC', 'Microphone toggled: ${isMicOn.value}');
  }

  void toggleCam() {
    isCamOn.value = !isCamOn.value;
    AppLogger.info('RTC', 'Camera toggled: ${isCamOn.value}');
  }

  void flipCamera() {
    isLocalCamFlipped.value = !isLocalCamFlipped.value;
    AppLogger.info('RTC', 'Camera flipped: ${isLocalCamFlipped.value}');
  }

  void joinRoom(String reqId) {
    AppLogger.info('RTC', 'Requesting mock 100ms room entry...');
    
    isJoined.value = true;
    callStartTime = DateTime.now();
    durationSec.value = 0;
    
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      durationSec.value++;
    });

    // Notify Guru app that Trainer has joined the call room
    _socket.broadcast({
      'type': 'call_room_state',
      'requestId': reqId,
      'state': 'in-call',
      'hmsRoomId': 'room_' + reqId
    });

    AppLogger.info('RTC', 'Trainer joined call room for request $reqId');
  }

  void updateRoomState(String reqId, String state, String hmsRoomId) {
    peerState.value = state;
    AppLogger.info('RTC', 'Peer (Member) updated room state to: $state');
  }

  void endCall(String reqId, {String? trainerNotes}) {
    _durationTimer?.cancel();
    isJoined.value = false;

    // Create session log
    final endTime = DateTime.now();
    final log = SessionLogModel(
      id: 'log_' + DateTime.now().millisecondsSinceEpoch.toString(),
      memberId: 'dk_member',
      trainerId: 'aarav_trainer',
      startedAt: callStartTime ?? endTime.subtract(Duration(seconds: durationSec.value)),
      endedAt: endTime,
      durationSec: durationSec.value,
      trainerNotes: trainerNotes ?? 'Reviewed food log, adjusted daily protein intake, and scheduled next form review.',
    );

    // Save and sync
    _storage.saveSessionLog(log);
    
    // Post system message
    final sysMsg = MessageModel(
      id: 'sys_' + DateTime.now().millisecondsSinceEpoch.toString(),
      chatId: 'dk_aarav_chat',
      senderId: 'system',
      receiverId: 'dk_member',
      text: 'Session saved to your logs.',
      createdAt: DateTime.now(),
      status: 'read',
    );
    _storage.saveMessage(sysMsg);

    _socket.broadcast({
      'type': 'session_log_sync',
      'log': log.toJson()
    });

    _socket.broadcast({
      'type': 'chat',
      'message': sysMsg.toJson()
    });

    _socket.broadcast({
      'type': 'call_room_state',
      'requestId': reqId,
      'state': 'ended',
      'hmsRoomId': 'room_' + reqId
    });

    AppLogger.info('RTC', 'Call session ended. Duration: ${durationSec.value}s');
  }
}
