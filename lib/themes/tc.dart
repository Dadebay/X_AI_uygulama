import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/modules/profile/controllers/theme_controller.dart';

/// Theme-aware color helper.
/// `Tc.of(context).card` uses Theme — reacts automatically to ThemeMode changes.
/// `Tc.card` (static) reads ThemeController — use inside Obx or after initState.
class Tc {
  final BuildContext _ctx;
  const Tc._(this._ctx);

  factory Tc.of(BuildContext context) => Tc._(context);

  bool get _dark => Theme.of(_ctx).brightness == Brightness.dark;

  Color get bg => _dark ? AppColors.background : Colors.white;
  Color get surface => _dark ? AppColors.surface : AppColors.lightSurface;
  Color get surfaceElevated => _dark ? AppColors.surfaceElevated : AppColors.lightSurfaceElevated;
  Color get card => _dark ? AppColors.card : AppColors.lightCard;
  Color get divider => _dark ? AppColors.divider : AppColors.lightDivider;
  Color get textPrimary => _dark ? AppColors.textPrimary : AppColors.lightTextPrimary;
  Color get textSecondary => _dark ? AppColors.textSecondary : AppColors.lightTextSecondary;
  Color get textMuted => _dark ? AppColors.textMuted : AppColors.lightTextMuted;

  // Static shortcuts — reads ThemeController observable (use inside Obx)
  static bool get _isDark {
    try {
      return Get.find<ThemeController>().isDark.value;
    } catch (_) {
      return true;
    }
  }

  static Color get bg$ => _isDark ? AppColors.background : AppColors.lightBackground;
  static Color get surface$ => _isDark ? AppColors.surface : AppColors.lightSurface;
  static Color get surfaceElevated$ => _isDark ? AppColors.surfaceElevated : AppColors.lightSurfaceElevated;
  static Color get card$ => _isDark ? AppColors.card : AppColors.lightCard;
  static Color get divider$ => _isDark ? AppColors.divider : AppColors.lightDivider;
  static Color get textPrimary$ => _isDark ? AppColors.textPrimary : AppColors.lightTextPrimary;
  static Color get textSecondary$ => _isDark ? AppColors.textSecondary : AppColors.lightTextSecondary;
  static Color get textMuted$ => _isDark ? AppColors.textMuted : AppColors.lightTextMuted;

  // Theme-independent
  static Color get primary => AppColors.primary;
  static Color get lightPrimary => AppColors.lightPrimary;
  static Color get blue => AppColors.blue;
  static Color get red => AppColors.red;
  static Color get white => AppColors.white;
  static Color get black => AppColors.black;
}
