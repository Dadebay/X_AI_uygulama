import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/modules/admin/controllers/web_admin_controller.dart';
import 'package:atlas/modules/admin/views/web/admin_theme.dart';
import 'package:atlas/modules/admin/views/web/pages/web_dashboard_page.dart';
import 'package:atlas/modules/admin/views/web/pages/web_teams_page.dart';
import 'package:atlas/modules/admin/views/web/pages/web_users_page.dart';
import 'package:atlas/modules/admin/views/web/pages/web_analytics_page.dart';
import 'package:atlas/modules/admin/views/web/pages/web_priority_accounts_page.dart';
import 'package:atlas/modules/admin/views/web/pages/web_ads_settings_page.dart';
import 'package:atlas/modules/admin/views/web/pages/web_premium_settings_page.dart';

class AdminWebShell extends StatelessWidget {
  const AdminWebShell({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<WebAdminController>();
    // Tema (nadiren değişir) yalnızca InheritedWidget'ı güncellemek için burada
    // izleniyor; alttaki const _ShellBody sabit bir widget instance'ı olduğu
    // için tema değişiminde yeniden inşa edilmez, yalnızca ona bağımlı olan
    // (AdminThemeScope.of çağıran) widget'lar güncellenir.
    return Obx(() {
      final theme = AdminTheme(ctrl.isDarkMode.value);
      return AdminThemeScope(
        theme: theme,
        child: const _ShellBody(),
      );
    });
  }
}

class _ShellBody extends StatelessWidget {
  const _ShellBody();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<WebAdminController>();
    final theme = AdminThemeScope.of(context);
    return Scaffold(
      backgroundColor: theme.bg,
      body: Row(
        children: [
          _Sidebar(ctrl: ctrl, theme: theme),
          VerticalDivider(width: 1, color: theme.divider),
          Expanded(
            child: Obx(() => IndexedStack(
                  index: ctrl.selectedPage.value,
                  children: const [
                    WebDashboardPage(),
                    WebTeamsPage(),
                    WebUsersPage(),
                    WebPriorityAccountsPage(),
                    WebAnalyticsPage(),
                    WebAdsSettingsPage(),
                    WebPremiumSettingsPage(),
                  ],
                )),
          ),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final WebAdminController ctrl;
  final AdminTheme theme;
  const _Sidebar({required this.ctrl, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      color: theme.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  'Pulse Admin',
                  style: TextStyle(
                    color: theme.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    fontFamily: 'Gilroy',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _sectionLabel('GENEL', theme),
          const SizedBox(height: 6),
          Obx(() => _NavItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            isSelected: ctrl.selectedPage.value == 0,
            theme: theme,
            onTap: () => ctrl.selectPage(0),
          )),
          const SizedBox(height: 20),
          _sectionLabel('YÖNETİM', theme),
          const SizedBox(height: 6),
          Obx(() => _NavItem(
            icon: Icons.groups_outlined,
            label: 'Takımlar',
            isSelected: ctrl.selectedPage.value == 1,
            theme: theme,
            onTap: () => ctrl.selectPage(1),
          )),
          Obx(() => _NavItem(
            icon: Icons.person_outline,
            label: 'Kullanıcılar',
            isSelected: ctrl.selectedPage.value == 2,
            theme: theme,
            onTap: () => ctrl.selectPage(2),
          )),
          Obx(() => _NavItem(
            icon: Icons.push_pin_outlined,
            label: 'Öncelikli Hesaplar',
            isSelected: ctrl.selectedPage.value == 3,
            theme: theme,
            onTap: () => ctrl.selectPage(3),
          )),
          Obx(() => _NavItem(
            icon: Icons.campaign_outlined,
            label: 'Reklamlar',
            isSelected: ctrl.selectedPage.value == 5,
            theme: theme,
            onTap: () => ctrl.selectPage(5),
          )),
          Obx(() => _NavItem(
            icon: Icons.workspace_premium_outlined,
            label: 'Premium Fiyatları',
            isSelected: ctrl.selectedPage.value == 6,
            theme: theme,
            onTap: () => ctrl.selectPage(6),
          )),
          const SizedBox(height: 20),
          _sectionLabel('VERİ', theme),
          const SizedBox(height: 6),
          Obx(() => _NavItem(
            icon: Icons.analytics_outlined,
            label: 'Analitik',
            isSelected: ctrl.selectedPage.value == 4,
            theme: theme,
            onTap: () => ctrl.selectPage(4),
          )),
          const Spacer(),
          Divider(color: theme.divider, height: 1),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      ctrl.isPinVerified.value = false;
                      ctrl.selectedPage.value = 0;
                    },
                    icon: Icon(Icons.logout, size: 16, color: theme.iconMuted),
                    label: Text(
                      'Çıkış Yap',
                      style: TextStyle(color: theme.iconMuted, fontFamily: 'Gilroy', fontSize: 13),
                    ),
                  ),
                ),
                Obx(() => IconButton(
                  onPressed: () => ctrl.isDarkMode.value = !ctrl.isDarkMode.value,
                  tooltip: ctrl.isDarkMode.value ? 'Açık Mod' : 'Koyu Mod',
                  icon: Icon(
                    ctrl.isDarkMode.value
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                    size: 18,
                    color: theme.iconMuted,
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text, AdminTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        text,
        style: TextStyle(
          color: theme.sectionLabel,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          fontFamily: 'Gilroy',
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final AdminTheme theme;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.theme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : theme.iconMuted,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? theme.textPrimary : theme.textSecondary,
                fontFamily: 'Gilroy',
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
