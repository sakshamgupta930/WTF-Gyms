import 'package:flutter_test/flutter_test.dart';
import 'package:guru_app/models/models.dart';
import 'package:guru_app/utils/utils.dart';

void main() {
  group('Guru App Unit Tests', () {
    test('Message serialization & deserialization', () {
      final now = DateTime.now();
      final msg = MessageModel(
        id: 'msg_1',
        chatId: 'chat_1',
        senderId: 'dk_member',
        receiverId: 'aarav_trainer',
        text: 'Hello Coach!',
        createdAt: now,
        status: 'sending',
      );

      final json = msg.toJson();
      expect(json['id'], 'msg_1');
      expect(json['text'], 'Hello Coach!');

      final parsed = MessageModel.fromJson(json);
      expect(parsed.id, 'msg_1');
      expect(parsed.text, 'Hello Coach!');
      expect(parsed.createdAt.day, now.day);
    });

    test('Scheduler past time validation', () {
      final pastTime = DateTime.now().subtract(const Duration(minutes: 10));
      final futureTime = DateTime.now().add(const Duration(minutes: 30));

      expect(Validators.isTimeInPast(pastTime), isTrue);
      expect(Validators.isTimeInPast(futureTime), isFalse);
    });

    test('Session log duration calculation', () {
      final start = DateTime.now();
      final end = start.add(const Duration(minutes: 45));
      final duration = end.difference(start).inSeconds;

      expect(duration, 45 * 60);
    });
  });
}
