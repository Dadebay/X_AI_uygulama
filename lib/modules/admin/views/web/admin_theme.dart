import 'package:flutter/material.dart';

class AdminTheme {
  final bool isDark;
  const AdminTheme(this.isDark);

  Color get bg => isDark ? const Color(0xFF0D0D0D) : const Color(0xFFF5F7FA);
  Color get surface => isDark ? const Color(0xFF1A1A1A) : Colors.white;
  Color get border => isDark ? const Color(0xFF222222) : const Color(0xFFE8E8E8);
  Color get borderLight => isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF0F0F0);
  Color get sidebarBg => isDark ? const Color(0xFF111111) : Colors.white;
  Color get headerBg => isDark ? const Color(0xFF111111) : Colors.white;
  Color get headerBorder => isDark ? const Color(0xFF1E1E1E) : const Color(0xFFEEEEEE);
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF111111);
  Color get textSecondary => isDark ? const Color(0xFF555555) : const Color(0xFF777777);
  Color get textMuted => isDark ? const Color(0xFF333333) : const Color(0xFFBBBBBB);
  Color get sectionLabel => isDark ? const Color(0xFF444444) : const Color(0xFF999999);
  Color get tableHeader => isDark ? const Color(0xFF444444) : const Color(0xFF999999);
  Color get iconMuted => isDark ? const Color(0xFF555555) : const Color(0xFFAAAAAA);
  Color get navSelected => isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5);
  Color get divider => isDark ? const Color(0xFF222222) : const Color(0xFFEEEEEE);
  Color get circleFallback => isDark ? const Color(0xFF333333) : const Color(0xFFE0E0E0);
}

class AdminThemeScope extends InheritedWidget {
  final AdminTheme theme;

  const AdminThemeScope({
    super.key,
    required this.theme,
    required super.child,
  });

  static AdminTheme of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AdminThemeScope>()!.theme;
  }

  @override
  bool updateShouldNotify(AdminThemeScope old) => old.theme.isDark != theme.isDark;
}
