import 'package:get/get.dart';
import 'storage_controller.dart';
import 'socket_controller.dart';
import 'package:guru_app/models/models.dart';
import 'package:guru_app/utils/utils.dart';

class RequestController extends GetxController {
  final _storage = Get.find<StorageController>();
  final _socket = Get.find<SocketController>();

  List<CallRequestModel> get requests => _storage.requests;

  bool hasConflict(DateTime requestedSlot) {
    // Check if any existing approved/pending slot matches within 30-min block
    for (var r in requests) {
      if ((r.status == 'approved' || r.status == 'pending') &&
          r.scheduledFor.year == requestedSlot.year &&
          r.scheduledFor.month == requestedSlot.month &&
          r.scheduledFor.day == requestedSlot.day &&
          r.scheduledFor.hour == requestedSlot.hour &&
          r.scheduledFor.minute == requestedSlot.minute) {
        return true;
      }
    }
    return false;
  }

  bool createCallRequest(DateTime slot, String note) {
    if (hasConflict(slot)) {
      AppLogger.error('SCHEDULE', 'Time slot conflict detected for $slot');
      return false;
    }

    final req = CallRequestModel(
      id: 'req_' + DateTime.now().millisecondsSinceEpoch.toString(),
      memberId: 'dk_member',
      trainerId: 'aarav_trainer',
      requestedAt: DateTime.now(),
      scheduledFor: slot,
      note: note,
      status: 'pending',
    );

    // Persist locally and dispatch to server
    _socket.sendCallRequest(req);
    AppLogger.info('SCHEDULE', 'Submitted call request for: $slot');
    return true;
  }
}
