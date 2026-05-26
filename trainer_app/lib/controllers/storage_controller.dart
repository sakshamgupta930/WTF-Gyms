import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:trainer_app/models/models.dart';
import 'package:trainer_app/utils/utils.dart';

class StorageController extends GetxController {
  final _box = GetStorage();

  // Observable lists
  var members = <UserModel>[].obs;
  var chats = <MessageModel>[].obs;
  var requests = <CallRequestModel>[].obs;
  var sessionLogs = <SessionLogModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    AppLogger.info('AUTH', 'Initializing storage and seeding Aarav profile');

    // Seed Member DK in CRM
    final memberList = _box.read<List>('members') ?? [];
    if (memberList.isEmpty) {
      final dk = UserModel(
        id: 'dk_member',
        role: 'member',
        name: 'DK',
        email: 'dk@wtf.fit',
        avatarUrl: 'https://ui-avatars.com/api/?name=DK&background=1769E0&color=fff&size=128',
        assignedTrainerId: 'aarav_trainer',
      );
      members.add(dk);
      _box.write('members', [dk.toJson()]);
    } else {
      members.clear();
      members.addAll(memberList.map((e) => UserModel.fromJson(Map<String, dynamic>.from(e))));
    }

    // Load Messages
    final msgList = _box.read<List>('messages') ?? [];
    chats.clear();
    chats.addAll(msgList.map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e))));

    // Load Requests
    final reqList = _box.read<List>('requests') ?? [];
    requests.clear();
    requests.addAll(reqList.map((e) => CallRequestModel.fromJson(Map<String, dynamic>.from(e))));

    // Load Session Logs
    final logsList = _box.read<List>('session_logs') ?? [];
    sessionLogs.clear();
    sessionLogs.addAll(logsList.map((e) => SessionLogModel.fromJson(Map<String, dynamic>.from(e))));
  }

  void saveMessage(MessageModel msg) {
    chats.add(msg);
    _box.write('messages', chats.map((e) => e.toJson()).toList());
    AppLogger.info('CHAT', 'Saved message: "${msg.text}" from ${msg.senderId}');
  }

  void updateMessageStatus(String msgId, String status) {
    final idx = chats.indexWhere((element) => element.id == msgId);
    if (idx != -1) {
      chats[idx] = chats[idx].copyWith(status: status);
      _box.write('messages', chats.map((e) => e.toJson()).toList());
    }
  }

  void saveRequest(CallRequestModel req) {
    final idx = requests.indexWhere((element) => element.id == req.id);
    if (idx != -1) {
      requests[idx] = req;
    } else {
      requests.add(req);
    }
    _box.write('requests', requests.map((e) => e.toJson()).toList());
    AppLogger.info('SCHEDULE', 'Saved/Updated call request: status=${req.status}');
  }

  void saveSessionLog(SessionLogModel log) {
    sessionLogs.add(log);
    _box.write('session_logs', sessionLogs.map((e) => e.toJson()).toList());
    AppLogger.info('RTC', 'Saved session log: duration=${log.durationSec}s');
  }

  void clearAll() {
    _box.erase();
    chats.clear();
    requests.clear();
    sessionLogs.clear();
    _loadData();
    AppLogger.warn('AUTH', 'Storage wiped and re-seeded');
  }
}
