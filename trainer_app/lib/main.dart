import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controllers/storage_controller.dart';
import 'controllers/socket_controller.dart';
import 'controllers/chat_controller.dart';
import 'controllers/request_controller.dart';
import 'controllers/call_controller.dart';
import 'views/home_screen.dart';
import 'package:trainer_app/theme/theme.dart';
import 'package:trainer_app/utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize local persistent storage
  await GetStorage.init();

  // Dependency Injections
  Get.put(StorageController());
  Get.put(SocketController());
  Get.put(ChatController());
  Get.put(RequestController());
  Get.put(CallController());

  AppLogger.info('AUTH', 'Trainer App successfully booted on local environment');

  runApp(const TrainerPulseApp());
}

class TrainerPulseApp extends StatelessWidget {
  const TrainerPulseApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Trainer Pulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTrainerTheme(),
      home: const HomeScreen(),
    );
  }
}
