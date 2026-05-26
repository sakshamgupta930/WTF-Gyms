import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:guru_app/models/models.dart';
import 'package:guru_app/utils/utils.dart';

class StorageController extends GetxController {
  final _box = GetStorage();

  var isFirstRun = true.obs;
  var isLoggedIn = false.obs;
  var currentUser = Rxn<UserModel>();

  var chats = <MessageModel>[].obs;
  var requests = <CallRequestModel>[].obs;
  var sessionLogs = <SessionLogModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void _loadData() {
    AppLogger.info('AUTH', 'Initializing storage for Guru app');

    isFirstRun.value = _box.read<bool>('isFirstRun') ?? true;
    isLoggedIn.value = _box.read<bool>('isLoggedIn') ?? false;

    if (isLoggedIn.value) {
      final userJson = _box.read('currentUser');
      if (userJson != null) {
        currentUser.value = UserModel.fromJson(Map<String, dynamic>.from(userJson));
      }
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

  void completeOnboarding() {
    isFirstRun.value = false;
    _box.write('isFirstRun', false);
    AppLogger.info('AUTH', 'Onboarding completed');
  }

  void loginAsDK(UserModel user) {
    currentUser.value = user;
    isLoggedIn.value = true;
    _box.write('currentUser', user.toJson());
    _box.write('isLoggedIn', true);
    AppLogger.info('AUTH', 'User profile created and logged in as ${user.name}');
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
    isFirstRun.value = true;
    isLoggedIn.value = false;
    currentUser.value = null;
    chats.clear();
    requests.clear();
    sessionLogs.clear();
    AppLogger.warn('AUTH', 'Storage wiped for Guru App');
  }
}
