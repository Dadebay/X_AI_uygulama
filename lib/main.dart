import 'package:atlas/core/lang/app_translations.dart';
import 'package:atlas/firebase_options.dart';
import 'package:atlas/main_admin.dart' show bootstrapAdminPanel;
import 'package:atlas/firebase_messaging_service.dart';
import 'package:atlas/local_notifications_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:get_storage/get_storage.dart';
import 'package:atlas/core/theme/app_theme.dart';
import 'package:atlas/modules/splash/views/splash_screen.dart';
import 'package:atlas/utils/global_safe_area_wrapper.dart';
import 'package:atlas/modules/profile/controllers/language_controller.dart';
import 'package:atlas/modules/profile/controllers/theme_controller.dart';
import 'package:atlas/modules/auth/controllers/auth_controller.dart';
import 'package:atlas/modules/saved/controllers/saved_controller.dart';
import 'package:atlas/core/services/ads_config_controller.dart';
import 'package:atlas/core/services/analytics_service.dart';
import 'package:atlas/core/services/purchases_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Web'de (chrome / web-server) admin paneli açılır, mobilde uygulamanın
  // kendisi. kIsWeb derleme zamanı sabiti olduğu için mobil build'de bu dal
  // tamamen elenir; admin kodu iOS/Android paketine girmez.
  if (kIsWeb) {
    await bootstrapAdminPanel();
    return;
  }

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}

  await GetStorage.init();
  Get.put(GetStorage());
  Get.put(LanguageController());
  final themeCtrl = Get.put(ThemeController());
  themeCtrl.toggleTheme(themeCtrl.isDark.value);
  await PurchasesService.init();
  Get.put(AuthController());
  Get.put(SavedController());

  // Buradan aşağısı yalnızca mobilde çalışır — web yukarıda admin paneline
  // dallanıp döndüğü için ayrıca kIsWeb kontrolüne gerek yok.
  final localNotificationsService = LocalNotificationsService.instance();
  await localNotificationsService.init();

  final firebaseMessagingService = FirebaseMessagingService.instance();
  try {
    // Push bildirimleri uygulamanın çekirdek işlevi değil — APNS/FCM token
    // alımı burada başarısız olursa (izin reddi, simülatör kısıtı vb.)
    // uygulamanın açılışını (runApp) engellememeli.
    await firebaseMessagingService.init(localNotificationsService: localNotificationsService);
  } catch (e) {
    debugPrint('[FirebaseMessagingService] init başarısız: $e');
  }

  _setupFcmTokenListener();

  Get.put(AdsConfigController());
  await MobileAds.instance.initialize();
  // Geliştirme cihazında yanlışlıkla gerçek reklamlara tıklayıp AdMob
  // hesabını "geçersiz trafik" riskine atmamak için test cihazı olarak
  // işaretliyoruz. Yayınlanan sürümde bu ayar uygulanmaz — aksi halde gerçek
  // kullanıcılara da test reklamı gider ve gelir oluşmaz.
  if (kDebugMode) {
    await MobileAds.instance.updateRequestConfiguration(
      RequestConfiguration(testDeviceIds: ['83A6251569C5C4C7D038FED72DCA41E6']),
    );
  }

  runApp(const AtlasApp());
}

void _setupFcmTokenListener() {
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    print('[FCM] Token refresh detected: $newToken');
    try {
      final storage = Get.find<GetStorage>();
      storage.write('fcm_token', newToken);
    } catch (e) {
      print('[FCM] Failed to store refreshed token: $e');
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
          navigatorObservers: [AnalyticsService.observer],
          defaultTransition: Transition.cupertino,
          builder: (context, child) {
            return GlobalSafeAreaWrapper(child: child ?? const SizedBox.shrink());
          },
        ));
  }
}
