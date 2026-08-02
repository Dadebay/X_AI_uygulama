import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:atlas/core/services/ads_config_controller.dart';

/// Central place for AdMob ad unit ids, wired to the real AdMob account
/// for both Android and iOS.
class AdService {
  AdService._();

  /// DEBUG ONLY: set to true to swap in Google's official sample ad unit
  /// ids (these always fill at 100%). If ads still fail to load with those,
  /// the problem is device/network-level (DNS, VPN, clock, firewall), not
  /// the AdMob account or our real ad unit ids. Set back to false when done.
  static const bool _useTestAdUnitIds = true;

  static String get bannerAdUnitId {
    if (_useTestAdUnitIds) {
      // Google sample banner test id (works on every device/account).
      return 'ca-app-pub-3940256099942544/6300978111';
    }
    if (Platform.isAndroid) return 'ca-app-pub-3012262156319967/7267232028';
    if (Platform.isIOS) return 'ca-app-pub-3012262156319967/3148857763';
    throw UnsupportedError('Unsupported platform for ads');
  }

  static String get interstitialAdUnitId {
    if (_useTestAdUnitIds) {
      // Google sample interstitial test id (works on every device/account).
      return 'ca-app-pub-3940256099942544/1033173712';
    }
    if (Platform.isAndroid) return 'ca-app-pub-3012262156319967/5818418981';
    if (Platform.isIOS) return 'ca-app-pub-3012262156319967/5440968866';
    throw UnsupportedError('Unsupported platform for ads');
  }

  static bool get isSupported => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static AdRequest get request => const AdRequest();

  /// Logs with a magenta ANSI wrap so `[Ads]` lines stand out from the rest
  /// of the logcat noise in the `flutter run` terminal.
  static void log(String message) {
    debugPrint('\x1B[35m[Ads] $message\x1B[0m');
  }

  /// Admin panelden yönetilen, uygulama genelinde reklamları açıp kapatan bayrak
  static bool get adsEnabled {
    if (!Get.isRegistered<AdsConfigController>()) return true;
    return Get.find<AdsConfigController>().adsEnabled.value;
  }
}
