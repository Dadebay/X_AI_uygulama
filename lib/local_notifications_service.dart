import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationsService {
  LocalNotificationsService._internal();
  static final LocalNotificationsService _instance =
      LocalNotificationsService._internal();
  factory LocalNotificationsService.instance() => _instance;

  late final FlutterLocalNotificationsPlugin _plugin;
  static const _androidChannel = AndroidNotificationChannel(
    'channel_id',
    'Pulse notifications',
    description: 'Push notifications from Pulse',
    importance: Importance.max,
  );
  bool _initialized = false;
  int _notificationId = 0;

  Future<void> init() async {
    if (_initialized) return;
    _plugin = FlutterLocalNotificationsPlugin();
    await _plugin.initialize(const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    ));
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
    _initialized = true;
  }

  Future<void> showNotification(
      String? title, String? body, String? payload) async {
    await _plugin.show(
      _notificationId++,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'channel_id',
          'Pulse notifications',
          channelDescription: 'Push notifications from Pulse',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: payload,
    );
  }
}
