import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/widgets/common/settings_row.dart';
import 'package:atlas/modules/profile/controllers/language_controller.dart';
import 'package:atlas/modules/profile/controllers/theme_controller.dart';
import 'package:hugeicons/hugeicons.dart';

// ─── Shared bottom-sheet header ───────────────────────────────────────────────

class _SheetTitle extends StatelessWidget {
  final String title;
  final String? subtitle;
  const _SheetTitle(this.title, {this.subtitle});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontSize: 18, fontFamily: 'Gilroy')),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(subtitle!, style: TextStyle(color: c.textMuted, fontSize: 13, fontFamily: 'Gilroy')),
        ],
      ],
    );
  }
}

// ─── Notifications Sheet ──────────────────────────────────────────────────────

class NotificationsSheet extends StatefulWidget {
  const NotificationsSheet({super.key});

  @override
  State<NotificationsSheet> createState() => _NotificationsSheetState();
}

class _NotificationsSheetState extends State<NotificationsSheet> {
  bool _pushEnabled = true;
  bool _breakingNews = true;
  bool _savedUpdates = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SheetTitle('notifications_settings'.tr),
          const SizedBox(height: 20),
          ToggleRow(label: 'notif_push'.tr, value: _pushEnabled, onChanged: (v) => setState(() => _pushEnabled = v)),
          ToggleRow(label: 'notif_breaking'.tr, value: _breakingNews, onChanged: (v) => setState(() => _breakingNews = v)),
          ToggleRow(label: 'notif_saved'.tr, value: _savedUpdates, onChanged: (v) => setState(() => _savedUpdates = v)),
        ],
      ),
    );
  }
}

// ─── Language Sheet ───────────────────────────────────────────────────────────

class LanguageSheet extends StatelessWidget {
  const LanguageSheet({super.key});

  static const _languages = [
    {'code': 'tr', 'label': 'Türkçe', 'flag': '🇹🇷'},
    {'code': 'en', 'label': 'English', 'flag': '🇬🇧'},
    {'code': 'ru', 'label': 'Русский', 'flag': '🇷🇺'},
  ];

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<LanguageController>();
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetTitle('lang_select'.tr),
              const SizedBox(height: 16),
              ..._languages.map((lang) {
                final selected = ctrl.selectedLanguage.value == lang['code'];
                final c = Tc.of(context);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Text(lang['flag']!, style: const TextStyle(fontSize: 24)),
                  title: Text(lang['label']!,
                      style: TextStyle(
                          color: selected ? AppColors.primary : c.textPrimary,
                          fontFamily: 'Gilroy',
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
                  trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                  onTap: () {
                    ctrl.changeLanguage(lang['code']!);
                    Get.back();
                  },
                );
              }),
            ],
          ),
        ));
  }
}

// ─── Theme Sheet ──────────────────────────────────────────────────────────────

class ThemeSheet extends StatelessWidget {
  const ThemeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ThemeController>();
    return Obx(() => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SheetTitle('theme_select'.tr, subtitle: 'theme_select_sub'.tr),
              const SizedBox(height: 20),
              _ThemeOption(
                icon: HugeIcons.strokeRoundedMoon02,
                label: 'theme_dark_label'.tr,
                description: 'theme_dark_desc'.tr,
                selected: ctrl.isDark.value,
                onTap: () { ctrl.toggleTheme(true); Get.back(); },
              ),
              const SizedBox(height: 12),
              _ThemeOption(
                icon: HugeIcons.strokeRoundedSun03,
                label: 'theme_light_label'.tr,
                description: 'theme_light_desc'.tr,
                selected: !ctrl.isDark.value,
                onTap: () { ctrl.toggleTheme(false); Get.back(); },
              ),
            ],
          ),
        ));
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({required this.icon, required this.label, required this.description, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.lightPrimary : c.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.primary : c.divider, width: selected ? 1.5 : 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary.withValues(alpha: 0.15) : c.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: selected ? AppColors.primary : c.textSecondary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: selected ? c.textPrimary : c.textSecondary,
                          fontFamily: 'Gilroy', fontWeight: FontWeight.w700, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(description, style: TextStyle(color: c.textMuted, fontFamily: 'Gilroy', fontSize: 12)),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
          ],
        ),
      ),
    );
  }
}

