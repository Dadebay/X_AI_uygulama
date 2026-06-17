import 'package:atlas/core/services/notification_storage_service.dart';
import 'package:atlas/firebase_options.dart';
import 'package:atlas/local_notifications_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._internal();
  factory FirebaseMessagingService.instance() => _instance;
  static final FirebaseMessagingService _instance = FirebaseMessagingService._internal();
  LocalNotificationsService? _localNotificationsService;

  Future<void> init({
    required LocalNotificationsService localNotificationsService,
  }) async {
    _localNotificationsService = localNotificationsService;
    await _handlePushNotificationsToken();
    await _requestPermission();
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _onMessageOpenedApp(initialMessage);
    }
  }

  Future<void> _handlePushNotificationsToken() async {
    // FCM Token (Android & iOS)
    final String? fcmToken = await FirebaseMessaging.instance.getToken();
    print('========== FCM TOKEN ==========');
    print(fcmToken);
    print('================================');

    // APNS Token (iOS only)
    final String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();
    print('========== APNS TOKEN ==========');
    print(apnsToken);
    print('=================================');

    // await NotificationService().sendDeviceToken();
    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      print('========== FCM TOKEN (refreshed) ==========');
      print(fcmToken);
      print('===========================================');
      // NotificationService().sendDeviceToken();
    }).onError((error) {});
  }

  Future<void> _requestPermission() async {
    final result = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('User granted permission: ${result.authorizationStatus}');
  }

  void _onForegroundMessage(RemoteMessage message) {
    print('Foreground message received: ${message.data.toString()}');
    _saveNotification(message);
    final notificationData = message.notification;
    if (notificationData != null) {
      _localNotificationsService?.showNotification(
        notificationData.title,
        notificationData.body,
        message.data.toString(),
      );
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) {
    print('Notification caused the app to open: ${message.data.toString()}');
    _saveNotification(message);
  }

  void _saveNotification(RemoteMessage message) {
    try {
      final notif = message.notification;
      final notifMap = {
        'id': message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'title': notif?.title ?? message.data['title'] ?? '',
        'body': notif?.body ?? message.data['body'] ?? '',
        'icon': message.data['icon'] ?? '🔔',
        'time': DateTime.now().toIso8601String(),
        'read': false,
        'data': message.data,
      };
      NotificationStorageService().save(notifMap);
    } catch (e) {
      print('[FCM] Failed to save notification: $e');
    }
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  }
  print('Background message received: ${message.data.toString()}');
}
