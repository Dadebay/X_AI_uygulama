import 'dart:async';
import 'dart:math';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:atlas/core/api/api_service.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/modules/main/views/main_screen.dart';
import 'package:atlas/modules/main/bindings/main_binding.dart';
import 'package:hugeicons/hugeicons.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
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

    Get.offAll(() => const MainScreen(), binding: MainBinding());
    unawaited(_syncDevice());
    unawaited(_syncFcmToken());
  }

  Future<void> _syncFcmToken() async {
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      // For iOS, wait for APNS token to be ready (up to 5 seconds)
      if (Platform.isIOS) {
        bool apnsReady = false;
        for (int i = 0; i < 5; i++) {
          await Future.delayed(const Duration(seconds: 1));
          final apnsToken = await messaging.getAPNSToken();

          if (apnsToken != null) {
            apnsReady = true;
            break;
          }
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
    } catch (error) {
      debugPrint('[FCM] Registration failed: ${error.runtimeType}');
    }
  }

  void _scheduleFcmBackgroundRetry(FirebaseMessaging messaging) {
    Future.delayed(const Duration(seconds: 20), () async {
      try {
        if (Platform.isIOS) {
          final apnsToken = await messaging.getAPNSToken();
          if (apnsToken == null) {
            return;
          }
        }
        await _registerFcmToken(messaging);
      } catch (error) {
        debugPrint('[FCM] Retry failed: ${error.runtimeType}');
      }
    });
  }

  Future<void> _registerFcmToken(FirebaseMessaging messaging) async {
    String? token;
    try {
      token = await messaging.getToken();
    } catch (e) {
      token = null;
    }

    if (token == null) {
      return; // Listener in main.dart will handle registration
    }

    final storage = Get.find<GetStorage>();
    final stored = storage.read<String>('fcm_token');
    if (stored == token) return;

    await ApiService().registerFcmToken(token);
    storage.write('fcm_token', token);
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
    } catch (error) {
      debugPrint('[Device] Registration failed: ${error.runtimeType}');
    }
  }

  Future<String> _buildDeviceId() async {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    final id =
        bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return 'pulse-$id';
  }

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
                                color: AppColors.primary.withValues(alpha: 0.4),
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
