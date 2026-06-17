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
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}

  await GetStorage.init();
  Get.put(GetStorage());
  Get.put(LanguageController());
  final themeCtrl = Get.put(ThemeController());
  themeCtrl.toggleTheme(themeCtrl.isDark.value);
  Get.put(AuthController());
  Get.put(SavedController());

  final localNotificationsService = LocalNotificationsService.instance();
  await localNotificationsService.init();

  final firebaseMessagingService = FirebaseMessagingService.instance();
  await firebaseMessagingService.init(localNotificationsService: localNotificationsService);

  // Set up global token refresh listener for server registration
  _setupFcmTokenListener();

  runApp(const AtlasApp());
}

void _setupFcmTokenListener() {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    print('[FCM] Token refresh detected: $newToken');
    try {
      final storage = Get.find<GetStorage>();
      await ApiService().registerFcmToken(newToken);
      storage.write('fcm_token', newToken);
      print('[FCM] Token registered successfully via global listener');
    } catch (e) {
      print('[FCM] Failed to register token via global listener: $e');
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
            return GlobalSafeAreaWrapper(child: child ?? const SizedBox.shrink());
          },
        ));
  }
}
