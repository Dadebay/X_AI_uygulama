import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/modules/admin/controllers/web_admin_controller.dart';
import 'package:atlas/modules/admin/views/web/admin_theme.dart';

class WebUsersPage extends StatelessWidget {
  const WebUsersPage({super.key});

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
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kullanıcılar', style: TextStyle(color: t.textPrimary, fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Gilroy')),
                  const SizedBox(height: 2),
                  Text('${ctrl.usersCount.value} kayıtlı kullanıcı', style: TextStyle(color: t.textSecondary, fontSize: 13, fontFamily: 'Gilroy')),
                ],
              )),
              const Spacer(),
              IconButton(
                onPressed: () => ctrl.refreshPage(2),
                icon: Icon(Icons.refresh, color: t.iconMuted),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (ctrl.isLoadingUsers.value && ctrl.users.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (ctrl.users.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_outline, size: 64, color: t.textMuted),
                    const SizedBox(height: 16),
                    Text('Henüz kullanıcı yok', style: TextStyle(color: t.textSecondary, fontFamily: 'Gilroy', fontSize: 16)),
                  ],
                ),
              );
            }
            // itemCount: header (1) + kullanıcılar + "daha fazla yükle" satırı (varsa)
            final showLoadMore = ctrl.hasMoreUsers.value;
            final itemCount = 1 + ctrl.users.length + (showLoadMore ? 1 : 0);
            return Padding(
              padding: const EdgeInsets.all(28),
              child: Container(
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: t.border),
                ),
                child: ListView.builder(
                  itemCount: itemCount,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Column(
                        children: [
                          _TableHeader(theme: t),
                          Divider(height: 1, color: t.border),
                        ],
                      );
                    }
                    final userIndex = index - 1;
                    if (userIndex >= ctrl.users.length) {
                      return _LoadMoreRow(ctrl: ctrl, theme: t);
                    }
                    return _UserRow(
                      index: userIndex,
                      user: ctrl.users[userIndex],
                      isLast: !showLoadMore && userIndex == ctrl.users.length - 1,
                      theme: t,
                    );
                  },
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _LoadMoreRow extends StatelessWidget {
  final WebAdminController ctrl;
  final AdminTheme theme;
  const _LoadMoreRow({required this.ctrl, required this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: ctrl.isLoadingMoreUsers.value
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2))
                : TextButton(
                    onPressed: ctrl.loadMoreUsers,
                    child: Text('Daha fazla yükle', style: TextStyle(color: t.textSecondary, fontFamily: 'Gilroy', fontWeight: FontWeight.w600)),
                  ),
          ),
        ));
  }
}

class _TableHeader extends StatelessWidget {
  final AdminTheme theme;
  const _TableHeader({required this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          const SizedBox(width: 36),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text('#  İsim / E-posta', style: TextStyle(color: t.tableHeader, fontFamily: 'Gilroy', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          ),
          Expanded(
            flex: 2,
            child: Text('KAYIT TARİHİ', style: TextStyle(color: t.tableHeader, fontFamily: 'Gilroy', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          ),
          Expanded(
            flex: 1,
            child: Text('DURUM', style: TextStyle(color: t.tableHeader, fontFamily: 'Gilroy', fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
          ),
        ],
      ),
    );
  }
}

class _UserRow extends StatelessWidget {
  final int index;
  final Map<String, dynamic> user;
  final bool isLast;
  final AdminTheme theme;

  const _UserRow({required this.index, required this.user, required this.isLast, required this.theme});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    final name = user['displayName']?.toString() ?? '';
    final email = user['email']?.toString() ?? '';
    final photoUrl = user['photoUrl']?.toString() ?? '';
    final createdAt = user['createdAt'];
    String dateStr = '—';
    if (createdAt != null) {
      try {
        final ts = createdAt.toDate() as DateTime;
        dateStr = '${ts.day.toString().padLeft(2, '0')}.${ts.month.toString().padLeft(2, '0')}.${ts.year}';
      } catch (_) {}
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              photoUrl.isNotEmpty
                  ? CircleAvatar(
                      radius: 18,
                      backgroundImage: NetworkImage(photoUrl),
                      backgroundColor: t.circleFallback,
                    )
                  : CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : '?',
                        style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontFamily: 'Gilroy'),
                      ),
                    ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.isNotEmpty ? name : 'İsimsiz Kullanıcı',
                      style: TextStyle(color: t.textPrimary, fontFamily: 'Gilroy', fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                    if (email.isNotEmpty)
                      Text(email, style: TextStyle(color: t.textSecondary, fontFamily: 'Gilroy', fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(dateStr, style: TextStyle(color: t.textSecondary, fontFamily: 'Gilroy', fontSize: 13)),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('Aktif', style: TextStyle(color: AppColors.primary, fontFamily: 'Gilroy', fontSize: 11, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: t.borderLight),
      ],
    );
  }
}
