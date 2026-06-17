import 'package:atlas/themes/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GlobalSafeAreaWrapper extends StatelessWidget {
  final Widget child;
  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  const GlobalSafeAreaWrapper({
    super.key,
    required this.child,
    this.top = false,
    this.bottom = true,
    this.left = true,
    this.right = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.light,
              statusBarBrightness: Brightness.dark,
              systemNavigationBarColor: AppColors.background,
              systemNavigationBarIconBrightness: Brightness.light,
              systemNavigationBarContrastEnforced: false,
            )
          : const SystemUiOverlayStyle(
              statusBarColor: Colors.transparent,
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
              systemNavigationBarColor: AppColors.lightBackground,
              systemNavigationBarIconBrightness: Brightness.dark,
              systemNavigationBarContrastEnforced: false,
            ),
      child: SafeArea(
        top: top,
        bottom: true,
        left: left,
        right: right,
        child: child,
      ),
    );
  }
}
