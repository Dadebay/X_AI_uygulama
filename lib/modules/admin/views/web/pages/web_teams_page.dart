import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:atlas/modules/admin/controllers/web_admin_controller.dart';
import 'package:atlas/modules/admin/views/web/admin_theme.dart';
import 'package:atlas/modules/admin/views/team_form_screen.dart';
import 'package:atlas/widgets/app_network_image.dart';

class WebTeamsPage extends StatelessWidget {
  const WebTeamsPage({super.key});

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
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Takımlar',
                    style: TextStyle(
                      color: t.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Takımları ve Twitter hesaplarını yönetin',
                    style: TextStyle(color: t.textSecondary, fontSize: 13, fontFamily: 'Gilroy'),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: ctrl.loadTeams,
                icon: Icon(Icons.refresh, color: t.iconMuted),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  await Get.to(() => const TeamFormScreen(), transition: Transition.cupertino);
                  await ctrl.loadTeams();
                  await ctrl.loadStats();
                },
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Takım Ekle', style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (ctrl.isLoadingTeams.value && ctrl.teams.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (ctrl.teams.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.groups_outlined, size: 64, color: t.textMuted),
                    const SizedBox(height: 16),
                    Text('Henüz takım yok', style: TextStyle(color: t.textSecondary, fontFamily: 'Gilroy', fontSize: 16)),
                    const SizedBox(height: 8),
                    Text('Sağ üstten takım ekleyin', style: TextStyle(color: t.textMuted, fontFamily: 'Gilroy', fontSize: 13)),
                  ],
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: Column(
                children: ctrl.teams.map((team) => _TeamRow(
                  team: team,
                  theme: t,
                  onEdit: () async {
                    await Get.to(() => TeamFormScreen(team: team), transition: Transition.cupertino);
                    await ctrl.loadTeams();
                  },
                  onDelete: () => _confirmDelete(context, ctrl, team, t),
                )).toList(),
              ),
            );
          }),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, WebAdminController ctrl, TeamModel team, AdminTheme t) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: t.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Takımı Sil', style: TextStyle(color: t.textPrimary, fontFamily: 'Gilroy', fontWeight: FontWeight.w700)),
        content: Text(
          '"${team.name}" takımını silmek istediğinize emin misiniz?',
          style: TextStyle(color: t.textSecondary, fontFamily: 'Gilroy', fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('İptal', style: TextStyle(color: t.textSecondary, fontFamily: 'Gilroy')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sil', style: TextStyle(color: AppColors.red, fontFamily: 'Gilroy', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirmed == true) await ctrl.deleteTeam(team.id);
  }
}

class _TeamRow extends StatelessWidget {
  final TeamModel team;
  final AdminTheme theme;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TeamRow({required this.team, required this.theme, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final primary = team.colors.isNotEmpty ? team.colors.first : AppColors.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: t.border),
      ),
      child: Row(
        children: [
          _TeamLogo(team: team, primary: primary),
          const SizedBox(width: 14),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: TextStyle(color: t.textPrimary, fontFamily: 'Gilroy', fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Text(
                  '${team.league} · Sıra: ${team.order}',
                  style: TextStyle(color: t.textSecondary, fontFamily: 'Gilroy', fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: team.twitterAccounts.isNotEmpty
                ? Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    children: team.twitterAccounts.map((h) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DA1F2).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF1DA1F2).withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        '@$h',
                        style: const TextStyle(color: Color(0xFF1DA1F2), fontFamily: 'Gilroy', fontSize: 11, fontWeight: FontWeight.w600),
                      ),
                    )).toList(),
                  )
                : team.searchQuery.isNotEmpty
                    ? Row(
                        children: [
                          Icon(Icons.search, size: 12, color: t.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              team.searchQuery,
                              style: TextStyle(color: t.textSecondary, fontFamily: 'Gilroy', fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      )
                    : Text('—', style: TextStyle(color: t.textMuted, fontFamily: 'Gilroy')),
          ),
          const SizedBox(width: 12),
          IconButton(
            onPressed: onEdit,
            icon: Icon(Icons.edit_outlined, size: 18, color: t.iconMuted),
            tooltip: 'Düzenle',
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.red),
            tooltip: 'Sil',
          ),
        ],
      ),
    );
  }
}

class _TeamLogo extends StatelessWidget {
  final TeamModel team;
  final Color primary;
  const _TeamLogo({required this.team, required this.primary});

  @override
  Widget build(BuildContext context) {
    final source = team.logoUrl.isNotEmpty ? team.logoUrl : team.logoAsset;
    final fallback = Center(
      child: Text(
        team.shortName.isNotEmpty ? team.shortName[0] : '⚽',
        style: TextStyle(color: primary, fontWeight: FontWeight.w800, fontSize: 18, fontFamily: 'Gilroy'),
      ),
    );
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: source.isEmpty
          ? fallback
          : ClipOval(
              child: AppNetworkImage(
                url: source,
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorWidget: fallback,
              ),
            ),
    );
  }
}
