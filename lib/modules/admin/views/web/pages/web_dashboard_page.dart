import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/modules/admin/controllers/web_admin_controller.dart';
import 'package:atlas/modules/admin/views/web/admin_theme.dart';

class WebDashboardPage extends StatelessWidget {
  const WebDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<WebAdminController>();
    final t = AdminThemeScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PageHeader(
          title: 'Dashboard',
          subtitle: 'Genel uygulama istatistikleri',
          onRefresh: () {
            ctrl.loadStats();
            ctrl.refreshPage(0);
          },
          theme: t,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatsGrid(ctrl: ctrl, theme: t),
                const SizedBox(height: 32),
                _TeamsOverview(ctrl: ctrl, theme: t),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final WebAdminController ctrl;
  final AdminTheme theme;
  const _StatsGrid({required this.ctrl, required this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Obx(() {
      if (ctrl.isLoadingStats.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 2.2,
        children: [
          _StatCard(label: 'Toplam Kullanıcı', value: ctrl.usersCount.value.toString(), icon: Icons.person_outline, color: const Color(0xFF4F8EF7), theme: t),
          _StatCard(label: 'Toplam Takım', value: ctrl.teamsCount.value.toString(), icon: Icons.groups_outlined, color: AppColors.primary, theme: t),
          _StatCard(label: 'Twitter Hesabı', value: ctrl.totalTwitterAccounts.toString(), icon: Icons.alternate_email, color: const Color(0xFF1DA1F2), theme: t),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final AdminTheme theme;

  const _StatCard({required this.label, required this.value, required this.icon, required this.color, required this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: TextStyle(color: t.textPrimary, fontSize: 26, fontWeight: FontWeight.w800, fontFamily: 'Gilroy')),
                Text(label, style: TextStyle(color: t.textSecondary, fontSize: 12, fontFamily: 'Gilroy', fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamsOverview extends StatelessWidget {
  final WebAdminController ctrl;
  final AdminTheme theme;
  const _TeamsOverview({required this.ctrl, required this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Row(
                children: [
                  Text('Takım Özeti', style: TextStyle(color: t.textPrimary, fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Gilroy')),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${ctrl.teams.length} takım',
                      style: const TextStyle(color: AppColors.primary, fontSize: 12, fontFamily: 'Gilroy', fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: t.border),
            if (ctrl.isLoadingTeams.value)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              )
            else if (ctrl.teams.isEmpty)
              Padding(
                padding: const EdgeInsets.all(30),
                child: Center(
                  child: Text('Henüz takım yok', style: TextStyle(color: t.textSecondary, fontFamily: 'Gilroy')),
                ),
              )
            else
              ...ctrl.teams.map((team) {
                final primary = team.colors.isNotEmpty ? team.colors.first : AppColors.primary;
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(color: primary.withValues(alpha: 0.15), shape: BoxShape.circle),
                            child: Center(
                              child: Text(
                                team.shortName.isNotEmpty ? team.shortName[0] : '⚽',
                                style: TextStyle(color: primary, fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'Gilroy'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(team.name, style: TextStyle(color: t.textPrimary, fontFamily: 'Gilroy', fontWeight: FontWeight.w600, fontSize: 14)),
                                Text(team.league, style: TextStyle(color: t.textSecondary, fontFamily: 'Gilroy', fontSize: 12)),
                              ],
                            ),
                          ),
                          if (team.twitterAccounts.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1DA1F2).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${team.twitterAccounts.length} hesap',
                                style: const TextStyle(color: Color(0xFF1DA1F2), fontSize: 11, fontFamily: 'Gilroy', fontWeight: FontWeight.w600),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: t.borderLight),
                  ],
                );
              }),
          ],
        ),
      );
    });
  }
}

class _PageHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onRefresh;
  final AdminTheme theme;

  const _PageHeader({required this.title, required this.subtitle, required this.onRefresh, required this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
      decoration: BoxDecoration(
        color: t.headerBg,
        border: Border(bottom: BorderSide(color: t.headerBorder)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: t.textPrimary, fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Gilroy')),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: t.textSecondary, fontSize: 13, fontFamily: 'Gilroy')),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: onRefresh,
            icon: Icon(Icons.refresh, color: t.iconMuted),
            tooltip: 'Yenile',
          ),
        ],
      ),
    );
  }
}
