import 'dart:async';
import 'dart:io' show InternetAddress;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/modules/splash/views/splash_screen.dart';

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _isChecking = false;

  Future<void> _retry() async {
    setState(() => _isChecking = true);
    bool ok = false;
    try {
      // Check connection to a reliable host
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      ok = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on TimeoutException catch (_) {
      ok = false;
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    if (ok) {
      Get.offAll(() => const SplashScreen());
    } else {
      setState(() => _isChecking = false);
      Get.snackbar(
        'error'.tr,
        'no_internet_retry_failed'.tr,
        // snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                HugeIcons.strokeRoundedWifiOff01,
                size: 100,
                color: AppColors.primary,
              ),
              const SizedBox(height: 30),
              Text(
                'no_internet'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Gilroy',
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'no_internet_desc'.tr,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: 'Gilroy',
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isChecking ? null : _retry,
                child: _isChecking
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'retry'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
