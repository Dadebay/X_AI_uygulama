import 'package:atlas/core/services/notification_storage_service.dart';
import 'package:atlas/firebase_options.dart';
import 'package:atlas/local_notifications_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  FirebaseMessagingService._internal();
  factory FirebaseMessagingService.instance() => _instance;
  static final FirebaseMessagingService _instance =
      FirebaseMessagingService._internal();
  LocalNotificationsService? _localNotificationsService;

  Future<void> init(
      {required LocalNotificationsService localNotificationsService}) async {
    _localNotificationsService = localNotificationsService;
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) _onMessageOpenedApp(initialMessage);
  }

  void _onForegroundMessage(RemoteMessage message) {
    _saveNotification(message);
    final notification = message.notification;
    if (notification != null) {
      _localNotificationsService?.showNotification(
        notification.title,
        notification.body,
        null,
      );
    }
  }

  void _onMessageOpenedApp(RemoteMessage message) => _saveNotification(message);

  void _saveNotification(RemoteMessage message) {
    final notification = message.notification;
    NotificationStorageService().save({
      'id':
          message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      'title': notification?.title ?? message.data['title'] ?? '',
      'body': notification?.body ?? message.data['body'] ?? '',
      'icon': message.data['icon'] ?? '🔔',
      'time': DateTime.now().toIso8601String(),
      'read': false,
      'data': message.data,
    });
  }
}

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
}
