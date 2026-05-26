import 'dart:async';
import 'package:get/get.dart';
import 'socket_controller.dart';
import 'package:guru_app/models/models.dart';
import 'package:guru_app/utils/utils.dart';

class CallController extends GetxController {
  final _socket = Get.find<SocketController>();

  var isMicOn = true.obs;
  var isCamOn = true.obs;
  var isJoined = false.obs;
  var peerState = 'idle'.obs;
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

    // Notify Trainer app that Member has joined the call room
    _socket.sendCallRoomState(reqId, 'in-call', 'room_' + reqId);

    AppLogger.info('RTC', 'Member joined call room for request $reqId');
  }

  void updateRoomState(String reqId, String state, String hmsRoomId) {
    peerState.value = state;
    AppLogger.info('RTC', 'Peer (Trainer) updated room state to: $state');
    
    if (state == 'ended') {
      _durationTimer?.cancel();
      isJoined.value = false;
      AppLogger.info('RTC', 'Call session terminated by Trainer');
    }
  }

  void leaveRoom(String reqId) {
    _durationTimer?.cancel();
    isJoined.value = false;
    
    _socket.sendCallRoomState(reqId, 'ended', 'room_' + reqId);
    AppLogger.info('RTC', 'Call session terminated by Member');
  }

  void submitSessionRating(String ratingNote, int ratingScore) {
    final endTime = DateTime.now();
    final log = SessionLogModel(
      id: 'log_' + DateTime.now().millisecondsSinceEpoch.toString(),
      memberId: 'dk_member',
      trainerId: 'aarav_trainer',
      startedAt: callStartTime ?? endTime.subtract(Duration(seconds: durationSec.value)),
      endedAt: endTime,
      durationSec: durationSec.value,
      rating: ratingScore,
      memberNotes: ratingNote,
    );

    // Save and sync over WS
    _socket.sendSessionLog(log);
    AppLogger.info('RTC', 'Session rated $ratingScore★. Notes: $ratingNote');
  }
}
