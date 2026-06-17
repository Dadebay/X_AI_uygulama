import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';

class AppDialogs {
  /// Generic bottom snackbar — use this everywhere.
  /// [message] : translated text
  /// [icon]    : leading icon
  /// [iconColor] : icon and tint color
  static void showSnackbar({
    required String message,
    required IconData icon,
    Color iconColor = const Color(0xFF4CAF7D),
  }) {
    try {
      Get.closeAllSnackbars();
    } catch (_) {
      // Ignore snackbar disposal errors
    }
    Get.showSnackbar(
      GetSnackBar(
        snackPosition: SnackPosition.BOTTOM,
        snackStyle: SnackStyle.FLOATING,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        padding: EdgeInsets.zero,
        borderRadius: 18,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 2),
        isDismissible: true,
        messageText: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1D1B20),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Pulse shortcuts ───────────────────────────────────────────────────
  static void showBookmarkAdded() => showSnackbar(
        message: 'Kaydedildi',
        icon: HugeIcons.strokeRoundedBookmark01,
        iconColor: const Color(0xFF4CAF7D),
      );

  static void showBookmarkRemoved() => showSnackbar(
        message: 'Kayıt kaldırıldı',
        icon: HugeIcons.strokeRoundedBookmark01,
        iconColor: Colors.grey,
      );

  static void showCopiedToClipboard() => showSnackbar(
        message: 'Panoya kopyalandı',
        icon: HugeIcons.strokeRoundedCopy01,
        iconColor: const Color(0xFF4CAF7D),
      );

  static void showTopSuccessSnackbar({
    required String title,
    required String subtitle,
    IconData icon = HugeIcons.strokeRoundedCheckmarkCircle02,
  }) {
    Get.closeAllSnackbars();
    Get.showSnackbar(
      GetSnackBar(
        snackPosition: SnackPosition.TOP,
        snackStyle: SnackStyle.FLOATING,
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
        padding: EdgeInsets.zero,
        borderRadius: 18,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 3),
        isDismissible: true,
        messageText: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF7D),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4CAF7D).withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.22),
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: Colors.white, size: 21),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
