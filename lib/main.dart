import 'dart:async';

import 'package:atlas/core/lang/app_translations.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/firebase_options.dart';
import 'package:atlas/firebase_messaging_service.dart';
import 'package:atlas/local_notifications_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:atlas/core/theme/app_theme.dart';
import 'package:atlas/modules/splash/views/splash_screen.dart';
import 'package:atlas/utils/global_safe_area_wrapper.dart';
import 'package:atlas/modules/profile/controllers/language_controller.dart';
import 'package:atlas/modules/profile/controllers/theme_controller.dart';
import 'package:atlas/modules/auth/controllers/auth_controller.dart';
import 'package:atlas/modules/saved/controllers/saved_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    runApp(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: TextButton(
            onPressed: main,
            child: Text('Unable to start Pulse. Tap to retry.'),
          ),
        ),
      ),
    ));
    return;
  }

  await GetStorage.init();
  await GetStorage().remove('fcm_notifications');
  Get.put(GetStorage());
  Get.put(LanguageController());
  final themeCtrl = Get.put(ThemeController());
  themeCtrl.toggleTheme(themeCtrl.isDark.value);
  Get.put(AuthController());
  Get.put(SavedController());

  runApp(const AtlasApp());
  unawaited(_initializeNotifications());
}

Future<void> _initializeNotifications() async {
  try {
    final local = LocalNotificationsService.instance();
    await local.init();
    await FirebaseMessagingService.instance()
        .init(localNotificationsService: local);
    _setupFcmTokenListener();
  } catch (error) {
    debugPrint('[Startup] Notifications unavailable: ${error.runtimeType}');
  }
}

void _setupFcmTokenListener() {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    try {
      final storage = Get.find<GetStorage>();
      await ApiService().registerFcmToken(newToken);
      storage.write('fcm_token', newToken);
    } catch (error) {
      debugPrint('[FCM] Token registration failed: ${error.runtimeType}');
    }
  });
}

class AtlasApp extends StatelessWidget {
  const AtlasApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = Get.find<GetStorage>();
    final themeCtrl = Get.find<ThemeController>();
    String langCode = storage.read('langCode') ?? 'tr';

    return Obx(() => GetMaterialApp(
          title: 'Pulse',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.trueLight,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeCtrl.isDark.value ? ThemeMode.dark : ThemeMode.light,
          translations: AppTranslations(),
          locale: Locale(langCode),
          fallbackLocale: const Locale('tr'),
          home: const SplashScreen(),
          defaultTransition: Transition.cupertino,
          builder: (context, child) {
            return GlobalSafeAreaWrapper(
                child: child ?? const SizedBox.shrink());
          },
        ));
  }
}
