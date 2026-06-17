import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:atlas/core/theme/app_theme.dart';

class ThemeController extends GetxController {
  final _storage = Get.find<GetStorage>();
  final isDark = true.obs;

  @override
  void onInit() {
    super.onInit();
    isDark.value = _storage.read('isDark') ?? true;
    _applyTheme();
  }

  void toggleTheme(bool dark) {
    isDark.value = dark;
    _storage.write('isDark', dark);
    _applyTheme();
  }

  void _applyTheme() {
    Get.changeTheme(isDark.value ? AppTheme.darkTheme : AppTheme.trueLight);
    SystemChrome.setSystemUIOverlayStyle(
      isDark.value
          ? const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarBrightness: Brightness.dark,
              statusBarIconBrightness: Brightness.light,
              systemNavigationBarColor: Color(0xFF0D0D0D),
              systemNavigationBarIconBrightness: Brightness.light,
              systemNavigationBarDividerColor: Colors.transparent,
            )
          : const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarBrightness: Brightness.light,
              statusBarIconBrightness: Brightness.dark,
              systemNavigationBarColor: Color(0xFFFFFFFF),
              systemNavigationBarIconBrightness: Brightness.dark,
              systemNavigationBarDividerColor: Colors.transparent,
            ),
    );
  }
}
