import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/modules/profile/controllers/language_controller.dart';
import 'package:atlas/modules/profile/controllers/theme_controller.dart';
import 'package:atlas/modules/auth/controllers/auth_controller.dart';
import 'package:atlas/modules/auth/views/login_screen.dart';
import 'package:atlas/widgets/common/section_header.dart';
import 'package:atlas/widgets/common/settings_row.dart';
import 'package:atlas/widgets/profile/settings_sheets.dart';
import 'package:atlas/modules/profile/views/about_page.dart';
import 'package:atlas/modules/notifications/views/notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _openSheet(Widget sheet, {bool scrollable = false}) {
    final c = Tc.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: c.card,
      isScrollControlled: scrollable,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => sheet,
    );
  }

  static String _langName(String code) {
    switch (code) {
      case 'tr': return 'Türkçe';
      case 'en': return 'English';
      case 'ru': return 'Русский';
      default:   return 'Türkçe';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 1,
        // surfaceTintColor: Colors.transparent,
        title: Text('profile_title'.tr, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w900, fontSize: 22, fontFamily: 'Gilroy')),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 32),
          children: [
            const _AuthCard(),
            const SizedBox(height: 8),
            SectionHeader('settings_section'.tr),
            SettingsRow(
              icon: HugeIcons.strokeRoundedNotification01,
              label: 'notifications_settings'.tr,
              onTap: () => Get.to(() => const NotificationsScreen(), transition: Transition.cupertino),
            ),
            Obx(() {
              final ctrl = Get.find<LanguageController>();
              return SettingsRow(
                icon: HugeIcons.strokeRoundedGlobe,
                label: 'language'.tr,
                trailing: _langName(ctrl.selectedLanguage.value),
                onTap: () => _openSheet(const LanguageSheet()),
              );
            }),
            Obx(() {
              final ctrl = Get.find<ThemeController>();
              return SettingsRow(
                icon: ctrl.isDark.value ? HugeIcons.strokeRoundedMoon02 : HugeIcons.strokeRoundedSun03,
                label: 'appearance'.tr,
                trailing: ctrl.isDark.value ? 'theme_dark'.tr : 'theme_light'.tr,
                onTap: () => _openSheet(const ThemeSheet()),
              );
            }),
            const SizedBox(height: 8),
            SectionHeader('general_section'.tr),
            SettingsRow(icon: HugeIcons.strokeRoundedInformationCircle, label: 'about_app'.tr, onTap: () => Get.to(() => const AboutPage(), transition: Transition.cupertino)),
            SettingsRow(icon: HugeIcons.strokeRoundedShield01, label: 'privacy_policy'.tr, onTap: () => Get.to(() => const PrivacyPage(), transition: Transition.cupertino)),
            SettingsRow(icon: HugeIcons.strokeRoundedNote01, label: 'terms_of_use'.tr, onTap: () => Get.to(() => const TermsPage(), transition: Transition.cupertino)),
          ],
        ),
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  const _AuthCard();

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    final auth = Get.find<AuthController>();
    return Obx(() {
      final user = auth.user.value;
      if (user == null) return _LoginCard(c: c);
      return _ProfileCard(c: c, auth: auth);
    });
  }
}

class _ProfileCard extends StatelessWidget {
  final Tc c;
  final AuthController auth;
  const _ProfileCard({required this.c, required this.auth});

  @override
  Widget build(BuildContext context) {
    final photoUrl = auth.photoUrl;
    final name = auth.displayName;
    final email = auth.email;
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.divider, width: 0.5),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 28,
            backgroundColor: c.surfaceElevated,
            backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
            child: photoUrl.isEmpty
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 20,
                      fontFamily: 'Gilroy',
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          // İsim + email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (name.isNotEmpty)
                  Text(
                    name,
                    style: TextStyle(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      fontFamily: 'Gilroy',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    email,
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 13,
                      fontFamily: 'Gilroy',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                // Google badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: c.surfaceElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: c.divider, width: 0.5),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.g_mobiledata_rounded, size: 14, color: c.textMuted),
                      const SizedBox(width: 4),
                      Text(
                        'Google',
                        style: TextStyle(
                          color: c.textMuted,
                          fontSize: 11,
                          fontFamily: 'Gilroy',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Çıkış butonu
          GestureDetector(
            onTap: () => _confirmSignOut(context, c, auth),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(HugeIcons.strokeRoundedLogout01, color: AppColors.red, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, Tc c, AuthController auth) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'sign_out'.tr,
          style: TextStyle(color: c.textPrimary, fontFamily: 'Gilroy', fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          'sign_out_confirm'.tr,
          style: TextStyle(color: c.textSecondary, fontFamily: 'Gilroy', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr, style: const TextStyle(color: AppColors.primary, fontFamily: 'Gilroy', fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () { Get.back(); auth.signOut(); },
            child: Text('sign_out'.tr, style: const TextStyle(color: AppColors.red, fontFamily: 'Gilroy', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

class _LoginCard extends StatelessWidget {
  final Tc c;
  const _LoginCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.divider, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: c.surfaceElevated,
              shape: BoxShape.circle,
            ),
            child: Icon(HugeIcons.strokeRoundedUser, color: c.textMuted, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'profile_login_title'.tr,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    fontFamily: 'Gilroy',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'profile_login_sub'.tr,
                  style: TextStyle(
                    color: c.textMuted,
                    fontSize: 12,
                    fontFamily: 'Gilroy',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Get.to(() => const LoginScreen(), transition: Transition.cupertino),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'sign_in'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Gilroy',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
