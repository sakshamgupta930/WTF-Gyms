import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'controllers/storage_controller.dart';
import 'controllers/socket_controller.dart';
import 'controllers/chat_controller.dart';
import 'controllers/request_controller.dart';
import 'controllers/call_controller.dart';
import 'views/onboarding_screen.dart';
import 'views/profile_creation_screen.dart';
import 'views/home_screen.dart';
import 'package:guru_app/theme/theme.dart';
import 'package:guru_app/utils/utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize local persistent storage
  await GetStorage.init();

  // Dependency Injections
  final storage = Get.put(StorageController());
  Get.put(SocketController());
  Get.put(ChatController());
  Get.put(RequestController());
  Get.put(CallController());

  AppLogger.info('AUTH', 'Guru App successfully booted on local environment');

  // Dynamic Routing Logic
  Widget initialScreen;
  if (storage.isFirstRun.value) {
    initialScreen = const OnboardingScreen();
  } else if (!storage.isLoggedIn.value) {
    initialScreen = const ProfileCreationScreen();
  } else {
    initialScreen = const HomeScreen();
  }

  runApp(GuruPulseApp(initialScreen: initialScreen));
}

class GuruPulseApp extends StatelessWidget {
  final Widget initialScreen;

  const GuruPulseApp({Key? key, required this.initialScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Guru Pulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getGuruTheme(),
      home: initialScreen,
    );
  }
}
