import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'storage_controller.dart';
import 'package:trainer_app/models/models.dart';
import 'package:trainer_app/utils/utils.dart';

class SocketController extends GetxController {
  HttpServer? _server;
  final List<WebSocket> _clients = [];
  var isServerRunning = false.obs;
  var isClientConnected = false.obs;
  var isTyping = false.obs; // Tracks if Member is typing

  late StorageController _storage;

  @override
  void onInit() {
    super.onInit();
    _storage = Get.find<StorageController>();
    startServer();
  }

  @override
  void onClose() {
    stopServer();
    super.onClose();
  }

  void startServer() async {
    try {
      AppLogger.info('RTC', 'Starting WebSocket server on port 8080...');
      // Bind to loopback/localhost
      _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 8080);
      isServerRunning.value = true;
      AppLogger.info('RTC', 'WebSocket Server running on ws://localhost:8080/ws');

      _server!.listen((HttpRequest request) {
        if (request.uri.path == '/ws') {
          WebSocketTransformer.upgrade(request).then((WebSocket socket) {
            _handleNewClient(socket);
          });
        } else if (request.uri.path == '/token') {
          // Section 5: HTTP token server endpoint
          final userId = request.uri.queryParameters['userId'] ?? 'aarav_trainer';
          final role = request.uri.queryParameters['role'] ?? 'trainer';
          request.response.headers.contentType = ContentType.json;
          request.response.write(jsonEncode({
            'token': 'mock_100ms_token_for_${userId}_as_${role}_' + DateTime.now().millisecondsSinceEpoch.toString()
          }));
          request.response.close();
          AppLogger.info('RTC', 'Issued mock 100ms token for "$userId" ($role)');
        } else {
          request.response.statusCode = HttpStatus.notFound;
          request.response.close();
        }
      });
    } catch (e) {
      AppLogger.error('RTC', 'Failed to start WebSocket server: $e');
    }
  }

  void _handleNewClient(WebSocket socket) {
    AppLogger.info('RTC', 'New client connected over WebSocket');
    _clients.add(socket);
    isClientConnected.value = true;

    // Send existing chats, requests, and logs to keep client in sync
    _sendToClient(socket, {
      'type': 'sync_init',
      'messages': _storage.chats.map((e) => e.toJson()).toList(),
      'requests': _storage.requests.map((e) => e.toJson()).toList(),
      'logs': _storage.sessionLogs.map((e) => e.toJson()).toList(),
    });

    socket.listen(
      (data) {
        _handleMessage(data);
      },
      onDone: () {
        AppLogger.warn('RTC', 'Client disconnected');
        _clients.remove(socket);
        isClientConnected.value = _clients.isNotEmpty;
        isTyping.value = false;
      },
      onError: (err) {
        AppLogger.error('RTC', 'WebSocket client error: $err');
        _clients.remove(socket);
        isClientConnected.value = _clients.isNotEmpty;
        isTyping.value = false;
      },
    );
  }

  void _handleMessage(dynamic rawData) {
    try {
      final data = jsonDecode(rawData as String) as Map<String, dynamic>;
      final type = data['type'] as String;

      switch (type) {
        case 'chat':
          final msgJson = data['message'] as Map<String, dynamic>;
          final msg = MessageModel.fromJson(msgJson);
          
          // Save and mark as read immediately if trainer views it
          _storage.saveMessage(msg.copyWith(status: 'read'));
          
          // Echo message back with 'read' receipt status
          broadcast({
            'type': 'chat_status',
            'messageId': msg.id,
            'status': 'read'
          });
          break;

        case 'typing':
          final memberTyping = data['isTyping'] as bool;
          isTyping.value = memberTyping;
          // Echo typing state to any other listening client
          broadcast({
            'type': 'typing',
            'isTyping': memberTyping,
            'userId': 'dk_member'
          });
          break;

        case 'call_request':
          final reqJson = data['request'] as Map<String, dynamic>;
          final req = CallRequestModel.fromJson(reqJson);
          _storage.saveRequest(req);
          
          // Sync requests locally
          broadcast({
            'type': 'call_request_sync',
            'request': req.toJson()
          });
          break;
          
        case 'call_room_state':
          // Sync call room transitions
          final reqId = data['requestId'] as String;
          final state = data['state'] as String;
          final hmsRoomId = data['hmsRoomId'] as String;
          broadcast({
            'type': 'call_room_state_sync',
            'requestId': reqId,
            'state': state,
            'hmsRoomId': hmsRoomId,
          });
          break;
          
        case 'session_log':
          final logJson = data['log'] as Map<String, dynamic>;
          final log = SessionLogModel.fromJson(logJson);
          _storage.saveSessionLog(log);
          broadcast({
            'type': 'session_log_sync',
            'log': log.toJson()
          });
          break;
      }
    } catch (e) {
      AppLogger.error('RTC', 'Error handling WebSocket message: $e');
    }
  }

  void _sendToClient(WebSocket socket, Map<String, dynamic> data) {
    try {
      socket.add(jsonEncode(data));
    } catch (e) {
      AppLogger.error('RTC', 'Failed to send to client: $e');
    }
  }

  void broadcast(Map<String, dynamic> data) {
    final payload = jsonEncode(data);
    for (var client in _clients) {
      try {
        client.add(payload);
      } catch (e) {
        AppLogger.error('RTC', 'Failed to broadcast: $e');
      }
    }
  }

  void stopServer() async {
    for (var client in _clients) {
      await client.close();
    }
    _clients.clear();
    if (_server != null) {
      await _server!.close(force: true);
    }
    isServerRunning.value = false;
    isClientConnected.value = false;
    AppLogger.warn('RTC', 'WebSocket Server stopped');
  }
}
