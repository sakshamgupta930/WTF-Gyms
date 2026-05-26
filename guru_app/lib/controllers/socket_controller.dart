import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'storage_controller.dart';
import 'call_controller.dart';
import 'package:guru_app/models/models.dart';
import 'package:guru_app/utils/utils.dart';

class SocketController extends GetxController {
  WebSocket? _socket;
  var isConnected = false.obs;
  var isConnecting = false.obs;
  var isTyping = false.obs; // Tracks if Trainer is typing
  Timer? _reconnectTimer;

  late StorageController _storage;

  @override
  void onInit() {
    super.onInit();
    _storage = Get.find<StorageController>();
    connect();
    // Retry connection every 4 seconds
    _reconnectTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!isConnected.value && !isConnecting.value) {
        connect();
      }
    });
  }

  @override
  void onClose() {
    _reconnectTimer?.cancel();
    _socket?.close();
    super.onClose();
  }

  void connect() async {
    if (isConnected.value || isConnecting.value) return;
    isConnecting.value = true;
    AppLogger.info('RTC', 'Connecting to Trainer WebSocket at ws://localhost:8080/ws...');

    try {
      _socket = await WebSocket.connect('ws://localhost:8080/ws').timeout(const Duration(seconds: 2));
      isConnected.value = true;
      isConnecting.value = false;
      AppLogger.info('RTC', 'Connected to Trainer WebSocket server');

      _socket!.listen(
        (rawData) {
          _handleMessage(rawData);
        },
        onDone: () {
          AppLogger.warn('RTC', 'WebSocket disconnected by server');
          isConnected.value = false;
          isConnecting.value = false;
          isTyping.value = false;
        },
        onError: (err) {
          AppLogger.error('RTC', 'WebSocket error: $err');
          isConnected.value = false;
          isConnecting.value = false;
          isTyping.value = false;
        },
      );
    } catch (e) {
      isConnecting.value = false;
      isConnected.value = false;
      // Silent retry to avoid clogging console logs
    }
  }

  void _handleMessage(dynamic rawData) {
    try {
      final data = jsonDecode(rawData as String) as Map<String, dynamic>;
      final type = data['type'] as String;

      switch (type) {
        case 'sync_init':
          AppLogger.info('RTC', 'Received complete state sync from Trainer server');
          final messagesJson = data['messages'] as List;
          final requestsJson = data['requests'] as List;
          final logsJson = data['logs'] as List;

          _storage.chats.clear();
          _storage.chats.addAll(messagesJson.map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e))));

          _storage.requests.clear();
          _storage.requests.addAll(requestsJson.map((e) => CallRequestModel.fromJson(Map<String, dynamic>.from(e))));

          _storage.sessionLogs.clear();
          _storage.sessionLogs.addAll(logsJson.map((e) => SessionLogModel.fromJson(Map<String, dynamic>.from(e))));
          break;

        case 'chat':
          final msgJson = data['message'] as Map<String, dynamic>;
          final msg = MessageModel.fromJson(msgJson);
          _storage.saveMessage(msg);
          break;

        case 'chat_status':
          final msgId = data['messageId'] as String;
          final status = data['status'] as String;
          _storage.updateMessageStatus(msgId, status);
          break;

        case 'typing':
          final trainerTyping = data['isTyping'] as bool;
          isTyping.value = trainerTyping;
          break;

        case 'call_request_sync':
          final reqJson = data['request'] as Map<String, dynamic>;
          final req = CallRequestModel.fromJson(reqJson);
          _storage.saveRequest(req);
          break;

        case 'call_room_state_sync':
          final reqId = data['requestId'] as String;
          final state = data['state'] as String;
          final hmsRoomId = data['hmsRoomId'] as String;
          
          // Grabbing CallController dynamically if active
          _updateCallRoomState(reqId, state, hmsRoomId);
          break;

        case 'session_log_sync':
          final logJson = data['log'] as Map<String, dynamic>;
          final log = SessionLogModel.fromJson(logJson);
          _storage.saveSessionLog(log);
          break;
      }
    } catch (e) {
      AppLogger.error('RTC', 'Error parsing WebSocket message: $e');
    }
  }

  void _updateCallRoomState(String reqId, String state, String hmsRoomId) {
    try {
      // Find CallController dynamically via GetX
      if (Get.isRegistered<CallController>()) {
        Get.find<CallController>().updateRoomState(reqId, state, hmsRoomId);
      }
    } catch (_) {}
  }

  void send(Map<String, dynamic> data) {
    if (!isConnected.value || _socket == null) {
      AppLogger.warn('RTC', 'WebSocket not connected, caching request locally');
      return;
    }
    try {
      _socket!.add(jsonEncode(data));
    } catch (e) {
      AppLogger.error('RTC', 'Failed to send payload: $e');
    }
  }

  void sendMessage(MessageModel msg) {
    send({
      'type': 'chat',
      'message': msg.toJson()
    });
    _storage.saveMessage(msg);
  }

  void sendTyping(bool typing) {
    send({
      'type': 'typing',
      'isTyping': typing
    });
  }

  void sendCallRequest(CallRequestModel req) {
    send({
      'type': 'call_request',
      'request': req.toJson()
    });
    _storage.saveRequest(req);
  }

  void sendCallRoomState(String reqId, String state, String roomId) {
    send({
      'type': 'call_room_state',
      'requestId': reqId,
      'state': state,
      'hmsRoomId': roomId
    });
  }

  void sendSessionLog(SessionLogModel log) {
    send({
      'type': 'session_log',
      'log': log.toJson()
    });
    _storage.saveSessionLog(log);
  }
}
