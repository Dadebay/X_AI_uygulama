import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/modules/admin/controllers/web_admin_controller.dart';
import 'package:atlas/modules/admin/views/web/admin_theme.dart';

class WebAnalyticsPage extends StatelessWidget {
  const WebAnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<WebAdminController>();
    final t = AdminThemeScope.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(28, 24, 28, 20),
          decoration: BoxDecoration(
            color: t.headerBg,
            border: Border(bottom: BorderSide(color: t.headerBorder)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Analitik', style: TextStyle(color: t.textPrimary, fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Gilroy')),
              const SizedBox(height: 2),
              Text('Uygulama kullanım istatistikleri', style: TextStyle(color: t.textSecondary, fontSize: 13, fontFamily: 'Gilroy')),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _QuickStatsRow(ctrl: ctrl, theme: t),
                const SizedBox(height: 24),
                _ExternalLinks(theme: t),
                const SizedBox(height: 24),
                _TwitterAccountsTable(ctrl: ctrl, theme: t),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickStatsRow extends StatelessWidget {
  final WebAdminController ctrl;
  final AdminTheme theme;
  const _QuickStatsRow({required this.ctrl, required this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Obx(() {
      return Row(
        children: [
          _MiniStat(label: 'Toplam Kullanıcı', value: ctrl.usersCount.value.toString(), icon: Icons.person_outline, color: const Color(0xFF4F8EF7), theme: t),
          const SizedBox(width: 16),
          _MiniStat(label: 'Aktif Takım', value: ctrl.teamsCount.value.toString(), icon: Icons.groups_outlined, color: AppColors.primary, theme: t),
          const SizedBox(width: 16),
          _MiniStat(label: 'İzlenen Hesap', value: ctrl.totalTwitterAccounts.toString(), icon: Icons.alternate_email, color: const Color(0xFF1DA1F2), theme: t),
        ],
      );
    });
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final AdminTheme theme;

  const _MiniStat({required this.label, required this.value, required this.icon, required this.color, required this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: TextStyle(color: t.textPrimary, fontSize: 22, fontWeight: FontWeight.w800, fontFamily: 'Gilroy')),
                Text(label, style: TextStyle(color: t.textSecondary, fontSize: 12, fontFamily: 'Gilroy')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExternalLinks extends StatelessWidget {
  final AdminTheme theme;
  const _ExternalLinks({required this.theme});

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dış Paneller', style: TextStyle(color: t.textPrimary, fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Gilroy')),
          const SizedBox(height: 4),
          Text('Detaylı analitik veriler için aşağıdaki panelleri kullanın', style: TextStyle(color: t.textSecondary, fontSize: 12, fontFamily: 'Gilroy')),
          const SizedBox(height: 16),
          Row(
            children: [
              _LinkCard(title: 'Firebase Analytics', subtitle: 'Kullanıcı davranışı, etkinlikler', icon: Icons.local_fire_department_outlined, color: const Color(0xFFFF7043), url: 'https://console.firebase.google.com/project/xaiuygulama/analytics'),
              const SizedBox(width: 12),
              _LinkCard(title: 'Google Analytics', subtitle: 'Trafik, oturum, dönüşüm', icon: Icons.bar_chart_outlined, color: const Color(0xFF4F8EF7), url: 'https://analytics.google.com'),
              const SizedBox(width: 12),
              _LinkCard(title: 'Firestore Konsol', subtitle: 'Veri tabanı yönetimi', icon: Icons.storage_outlined, color: AppColors.primary, url: 'https://console.firebase.google.com/project/xaiuygulama/firestore'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LinkCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String url;

  const _LinkCard({required this.title, required this.subtitle, required this.icon, required this.color, required this.url});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Clipboard.setData(ClipboardData(text: url));
          Get.snackbar('Link kopyalandı', 'Tarayıcınıza yapıştırın: $url',
            backgroundColor: const Color(0xFF1A1A1A), colorText: Colors.white, duration: const Duration(seconds: 3));
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: color, fontFamily: 'Gilroy', fontWeight: FontWeight.w700, fontSize: 13)),
                    Text(subtitle, style: const TextStyle(color: Color(0xFF555555), fontFamily: 'Gilroy', fontSize: 11)),
                  ],
                ),
              ),
              Icon(Icons.copy_outlined, color: color.withValues(alpha: 0.5), size: 14),
            ],
          ),
        ),
      ),
    );
  }
}

class _TwitterAccountsTable extends StatelessWidget {
  final WebAdminController ctrl;
  final AdminTheme theme;
  const _TwitterAccountsTable({required this.ctrl, required this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Obx(() {
      final teamsWithAccounts = ctrl.teams.where((t) => t.twitterAccounts.isNotEmpty).toList();
      if (teamsWithAccounts.isEmpty) return const SizedBox.shrink();

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
              child: Text('İzlenen Twitter Hesapları', style: TextStyle(color: t.textPrimary, fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'Gilroy')),
            ),
            Divider(height: 1, color: t.border),
            ...teamsWithAccounts.asMap().entries.map((e) {
              final team = e.value;
              final isLast = e.key == teamsWithAccounts.length - 1;
              final primary = team.colors.isNotEmpty ? team.colors.first : AppColors.primary;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(color: primary.withValues(alpha: 0.15), shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              team.shortName.isNotEmpty ? team.shortName[0] : '⚽',
                              style: TextStyle(color: primary, fontWeight: FontWeight.w800, fontSize: 13, fontFamily: 'Gilroy'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(team.name, style: TextStyle(color: t.textPrimary, fontFamily: 'Gilroy', fontWeight: FontWeight.w600, fontSize: 13)),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                children: team.twitterAccounts.map((h) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1DA1F2).withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: const Color(0xFF1DA1F2).withValues(alpha: 0.2)),
                                  ),
                                  child: Text('@$h', style: const TextStyle(color: Color(0xFF1DA1F2), fontFamily: 'Gilroy', fontSize: 11, fontWeight: FontWeight.w600)),
                                )).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isLast) Divider(height: 1, color: t.borderLight),
                ],
              );
            }),
          ],
        ),
      );
    });
  }
}
