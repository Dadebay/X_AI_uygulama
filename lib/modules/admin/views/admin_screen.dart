import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/modules/admin/controllers/admin_controller.dart';
import 'package:atlas/modules/admin/views/team_form_screen.dart';
import 'package:atlas/modules/home/controllers/home_controller.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  late AdminController _ctrl;
  bool _pinVerified = false;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(AdminController());
    WidgetsBinding.instance.addPostFrameCallback((_) => _showPinDialog());
  }

  void _showPinDialog() {
    final pinCtrl = TextEditingController();
    bool isChecking = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        final c = Tc.of(ctx);
        return StatefulBuilder(
          builder: (ctx, setDialogState) => AlertDialog(
            backgroundColor: c.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Admin Paneli',
              style: TextStyle(
                color: c.textPrimary,
                fontFamily: 'Gilroy',
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Devam etmek için PIN girin',
                  style: TextStyle(color: c.textSecondary, fontFamily: 'Gilroy', fontSize: 13),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: pinCtrl,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: TextStyle(color: c.textPrimary, fontFamily: 'Gilroy', letterSpacing: 4, fontSize: 18),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: '••••',
                    hintStyle: TextStyle(color: c.textMuted, letterSpacing: 4),
                    filled: true,
                    fillColor: c.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () { Get.back(); Get.back(); },
                child: Text('İptal', style: TextStyle(color: c.textMuted, fontFamily: 'Gilroy')),
              ),
              TextButton(
                onPressed: isChecking ? null : () async {
                  setDialogState(() => isChecking = true);
                  final ok = await _ctrl.verifyPin(pinCtrl.text.trim());
                  setDialogState(() => isChecking = false);
                  if (!ctx.mounted) return;
                  if (ok) {
                    Navigator.of(ctx).pop();
                    setState(() => _pinVerified = true);
                  } else {
                    pinCtrl.clear();
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Yanlış PIN'), backgroundColor: AppColors.red),
                    );
                  }
                },
                child: isChecking
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                    : const Text('Giriş', style: TextStyle(color: AppColors.primary, fontFamily: 'Gilroy', fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(TeamModel team) async {
    final c = Tc.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text('Takımı Sil', style: TextStyle(color: c.textPrimary, fontFamily: 'Gilroy', fontWeight: FontWeight.w700)),
        content: Text(
          '"${team.name}" takımını silmek istediğinize emin misiniz?',
          style: TextStyle(color: c.textSecondary, fontFamily: 'Gilroy', fontSize: 14),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: Text('İptal', style: TextStyle(color: c.textMuted, fontFamily: 'Gilroy'))),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Sil', style: TextStyle(color: AppColors.red, fontFamily: 'Gilroy', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _ctrl.deleteTeam(team.id);
      _reloadHomeTeams();
    }
  }

  void _reloadHomeTeams() {
    try {
      Get.find<HomeController>().reloadTeams();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        title: Text(
          'Admin Paneli',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 20,
            fontFamily: 'Gilroy',
          ),
        ),
        iconTheme: IconThemeData(color: c.textPrimary),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: c.textSecondary),
            onPressed: () { _ctrl.loadTeams(); _reloadHomeTeams(); },
          ),
        ],
      ),
      floatingActionButton: _pinVerified
          ? FloatingActionButton.extended(
              backgroundColor: AppColors.primary,
              onPressed: () async {
                await Get.to(
                  () => const TeamFormScreen(),
                  transition: Transition.cupertino,
                );
                _reloadHomeTeams();
              },
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('Takım Ekle', style: TextStyle(color: Colors.white, fontFamily: 'Gilroy', fontWeight: FontWeight.w700)),
            )
          : null,
      body: !_pinVerified
          ? Center(
              child: Text(
                'PIN gerekli',
                style: TextStyle(color: c.textMuted, fontFamily: 'Gilroy', fontSize: 15),
              ),
            )
          : Obx(() {
              if (_ctrl.isLoading.value && _ctrl.teams.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }
              if (_ctrl.teams.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.group_outlined, size: 60, color: c.textMuted),
                      const SizedBox(height: 16),
                      Text(
                        'Henüz takım yok',
                        style: TextStyle(color: c.textSecondary, fontFamily: 'Gilroy', fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aşağıdaki butona basarak takım ekleyin',
                        style: TextStyle(color: c.textMuted, fontFamily: 'Gilroy', fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 100),
                itemCount: _ctrl.teams.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final team = _ctrl.teams[i];
                  return _TeamCard(
                    team: team,
                    c: c,
                    onEdit: () async {
                      await Get.to(
                        () => TeamFormScreen(team: team),
                        transition: Transition.cupertino,
                      );
                      _reloadHomeTeams();
                    },
                    onDelete: () => _confirmDelete(team),
                  );
                },
              );
            }),
    );
  }
}

class _TeamCard extends StatelessWidget {
  final TeamModel team;
  final Tc c;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TeamCard({required this.team, required this.c, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final primaryColor = team.colors.isNotEmpty ? team.colors.first : AppColors.primary;

    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.divider, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      team.shortName.isNotEmpty ? team.shortName[0] : '⚽',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team.name,
                        style: TextStyle(color: c.textPrimary, fontFamily: 'Gilroy', fontWeight: FontWeight.w700, fontSize: 15),
                      ),
                      Text(
                        '${team.league} · Sıra: ${team.order}',
                        style: TextStyle(color: c.textMuted, fontFamily: 'Gilroy', fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.edit_outlined, color: c.textSecondary, size: 20),
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: AppColors.red, size: 20),
                  onPressed: onDelete,
                ),
              ],
            ),
            if (team.twitterAccounts.isNotEmpty) ...[
              const SizedBox(height: 10),
              Divider(height: 1, color: c.divider),
              const SizedBox(height: 10),
              Text(
                'Twitter Hesapları (${team.twitterAccounts.length})',
                style: TextStyle(color: c.textMuted, fontFamily: 'Gilroy', fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.4),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: team.twitterAccounts.map((handle) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: c.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: c.divider),
                  ),
                  child: Text(
                    '@$handle',
                    style: TextStyle(color: c.textSecondary, fontFamily: 'Gilroy', fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                )).toList(),
              ),
            ],
            if (team.searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.search, size: 12, color: c.textMuted),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      team.searchQuery,
                      style: TextStyle(color: c.textMuted, fontFamily: 'Gilroy', fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
