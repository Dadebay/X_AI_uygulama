import 'package:flutter/material.dart';

abstract class AppColors {
  // Dark background palette
  static const background = Color(0xFF0D0D0D);
  static const surface = Color(0xFF1A1A1A);
  static const surfaceElevated = Color(0xFF242424);
  static const card = Color(0xFF1E1E1E);
  static const divider = Color(0xFF2A2A2A);

  // Light background palette
  static const lightBackground = Color(0xFFF2F2F7);   // iOS-style soft grey bg
  static const lightSurface = Color(0xFFFFFFFF);       // white cards on grey bg
  static const lightSurfaceElevated = Color(0xFFF2F2F7);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightDivider = Color(0xFFD1D1D6);       // iOS separator grey
  static const lightTextPrimary = Color(0xFF0A0A0A);   // near-black, strong
  static const lightTextSecondary = Color(0xFF3C3C43);  // iOS secondary label
  static const lightTextMuted = Color(0xFF8E8E93);      // iOS tertiary label

  // Accent — Pulse green
  static const primary = Color(0xFF22B241);
  static const primaryDark = Color(0xFF1E9E3A);
  static const lightPrimary = Color(0x1A22B241);

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF9E9E9E);
  static const textMuted = Color(0xFF6B6B6B);

  // Status
  static const red = Color(0xFFE53935);
  static const orange = Color(0xFFFF9500);
  static const blue = Color(0xFF1D9BF0);
  static const yellow = Color(0xFFFFD700);

  // Misc
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);
  static const transparent = Colors.transparent;

  // Legacy aliases kept so existing widgets compile
  static const greyBgColor = surface;
  static const greyColor = Color(0xFF3A3A3A);
  static const greyFgColor = textSecondary;
  static const mediumGreyColor = textMuted;
  static const dirtyWhiteColor = Color(0xFF1A1A1A);
  static const lightGreyColor = Color(0xFF2A2A2A);
  static const lighterGreyColor = Color(0xFF333333);
  static const dirtyGreyColor = Color(0xFF222222);
  static const dirtyGrey2Color = Color(0xFF1E1E1E);
  static const green = primary;
  static const lightGreen = lightPrimary;
  static const limeGreen = Color(0xFF1A3D2B);
  static const limePrimary = Color(0xFF1A3D2B);
  static const accent = Color(0xFF4CAF7D);
  static const purple = Color(0xFF7C4DFF);
  static const pink = Color(0xFFFF4081);
  static const blackWithOpacity = Color(0x80000000);
  static const greyBlack = Color(0xFF2A2A2A);
  static const greyText = textSecondary;
}
