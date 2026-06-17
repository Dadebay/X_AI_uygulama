import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/shared/no_internet_screen.dart';
import 'package:atlas/modules/main/views/main_screen.dart';
import 'package:atlas/modules/main/bindings/main_binding.dart';
import 'package:hugeicons/hugeicons.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuart),
    );

    _controller.forward();
    _checkStatus();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    bool hasInternet = false;
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 5));
      hasInternet = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      hasInternet = false;
    }

    if (!mounted) return;

    if (!hasInternet) {
      Get.offAll(() => const NoInternetScreen());
      return;
    }

    await _syncFcmToken();
    await _syncDevice();
    Get.offAll(() => const MainScreen(), binding: MainBinding());
  }

  Future<void> _syncFcmToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      // For iOS, wait for APNS token to be ready (up to 5 seconds)
      if (Platform.isIOS) {
        print('[APNS] Waiting for APNS token...');

        bool apnsReady = false;
        for (int i = 0; i < 5; i++) {
          await Future.delayed(const Duration(seconds: 1));
          final apnsToken = await messaging.getAPNSToken();

          if (apnsToken != null) {
            print('[APNS] Token received: $apnsToken');
            apnsReady = true;
            break;
          }

          print('[APNS] Attempt ${i + 1}/5: Token not available yet...');
        }

        if (!apnsReady) {
          // APNS not ready yet — schedule a background retry after navigation
          // onTokenRefresh in main.dart also covers this, but an explicit retry
          // is more reliable when the token is generated for the first time.
          _scheduleFcmBackgroundRetry(messaging);
          return;
        }
      }

      await _registerFcmToken(messaging);
    } catch (e) {
      print('[FCM] Registration failed: $e');
    }
  }

  void _scheduleFcmBackgroundRetry(FirebaseMessaging messaging) {
    print('[FCM] Scheduling background retry in 20 seconds...');
    Future.delayed(const Duration(seconds: 20), () async {
      try {
        if (Platform.isIOS) {
          final apnsToken = await messaging.getAPNSToken();
          if (apnsToken == null) {
            print('[APNS] Background retry: token still not available');
            return;
          }
          print('[APNS] Background retry: token received');
        }
        await _registerFcmToken(messaging);
      } catch (e) {
        print('[FCM] Background retry failed: $e');
      }
    });
  }

  Future<void> _registerFcmToken(FirebaseMessaging messaging) async {
    String? token;
    try {
      token = await messaging.getToken();
    } catch (e) {
      print('[FCM] Error getting token: $e');
      token = null;
    }

    if (token == null) {
      print('[FCM] Token is null, will register when available via listener');
      return; // Listener in main.dart will handle registration
    }

    print('[FCM] Current token: $token');
    print('[DEVICE ID: ${Get.find<GetStorage>().read<String>('device_id')}]');

    final storage = Get.find<GetStorage>();
    final stored = storage.read<String>('fcm_token');
    if (stored == token) return;

    await ApiService().registerFcmToken(token);
    storage.write('fcm_token', token);
    print('[FCM] Token registered successfully: $token');
  }

  Future<void> _syncDevice() async {
    try {
      final storage = Get.find<GetStorage>();
      var deviceId = storage.read<String>('device_id');

      // Create device ID only if it doesn't exist
      // Don't migrate legacy IDs to preserve favorites and other data
      if (deviceId == null) {
        deviceId = await _buildDeviceId();
        storage.write('device_id', deviceId);
      }

      // Only register once per unique device_id
      final registered = storage.read<String>('device_registered');
      if (registered == deviceId) return;

      await ApiService().registerDevice(deviceId);
      storage.write('device_registered', deviceId);
      print('[Device] Registered successfully: $deviceId');
    } catch (e) {
      print('[Device] Registration failed: $e');
    }
  }

  Future<String> _buildDeviceId() async {
    final now = DateTime.now();
    final timestamp = '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}-${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';
    final entropy = now.microsecondsSinceEpoch.toRadixString(36);
    final rawName = await _readDeviceName();
    final safeName = rawName.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_|_$'), '');

    return 'atlas-${safeName.isEmpty ? 'unknown' : safeName}-$timestamp-$entropy';
  }

  Future<String> _readDeviceName() async {
    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final android = await info.androidInfo;
        return '${android.brand} ${android.model}';
      }
      if (Platform.isIOS) {
        final ios = await info.iosInfo;
        return '${ios.name} ${ios.utsname.machine}';
      }
      return Platform.operatingSystem;
    } catch (_) {
      return Platform.operatingSystem;
    }
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Center(
                    child: Icon(
                      HugeIcons.strokeRoundedPulse01,
                      color: AppColors.white,
                      size: 35,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pulse',
                  style: TextStyle(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w900,
                    fontSize: 32,
                    fontFamily: 'Gilroy',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'app_tagline'.tr,
                  style: TextStyle(
                    color: c.textMuted,
                    fontSize: 14,
                    fontFamily: 'Gilroy',
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 50,
            right: 50,
            bottom: 100,
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                final value = _animation.value;
                final c = Tc.of(context);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(value * 100).toInt()}%',
                      style: TextStyle(
                        color: c.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: c.divider,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: value,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
