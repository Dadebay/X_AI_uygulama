import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/modules/admin/controllers/web_admin_controller.dart';
import 'package:atlas/modules/admin/views/web/admin_theme.dart';

class WebPriorityAccountsPage extends StatefulWidget {
  const WebPriorityAccountsPage({super.key});

  @override
  State<WebPriorityAccountsPage> createState() => _WebPriorityAccountsPageState();
}

class _WebPriorityAccountsPageState extends State<WebPriorityAccountsPage> {
  final _accountCtrl = TextEditingController();
  final _minFavesCtrl = TextEditingController();
  final _minRetweetsCtrl = TextEditingController();
  final _minRepliesCtrl = TextEditingController();
  final _minQuotesCtrl = TextEditingController();
  final _minViewsCtrl = TextEditingController();
  bool _thresholdsSeeded = false;

  @override
  void dispose() {
    _accountCtrl.dispose();
    _minFavesCtrl.dispose();
    _minRetweetsCtrl.dispose();
    _minRepliesCtrl.dispose();
    _minQuotesCtrl.dispose();
    _minViewsCtrl.dispose();
    super.dispose();
  }

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
                    'Öncelikli Hesaplar',
                    style: TextStyle(color: t.textPrimary, fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Gilroy'),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Ana sayfada tüm günlük tweetleri filtresiz gösterilecek hesaplar',
                    style: TextStyle(color: t.textSecondary, fontSize: 13, fontFamily: 'Gilroy'),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: ctrl.loadPriorityAccounts,
                icon: Icon(Icons.refresh, color: t.iconMuted),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (ctrl.isLoadingPriorityAccounts.value && ctrl.priorityAccounts.isEmpty) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            if (!_thresholdsSeeded) {
              _minFavesCtrl.text = ctrl.minFaves.value.toString();
              _minRetweetsCtrl.text = ctrl.minRetweets.value.toString();
              _minRepliesCtrl.text = ctrl.minReplies.value.toString();
              _minQuotesCtrl.text = ctrl.minQuotes.value.toString();
              _minViewsCtrl.text = ctrl.minViews.value.toString();
              _thresholdsSeeded = true;
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionCard(
                      theme: t,
                      icon: Icons.push_pin_outlined,
                      title: 'Hesap Ekle',
                      description: 'Buraya eklenen hesapların tüm günlük tweetleri, herhangi bir görüntülenme/beğeni şartı aranmadan ana sayfada en üstte gösterilir. "@" işareti yazmanıza gerek yok.',
                      child: Row(
                        children: [
                          Expanded(
                            child: _AccountInput(
                              controller: _accountCtrl,
                              theme: t,
                              onSubmitted: () => _addAccount(ctrl),
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () => _addAccount(ctrl),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (ctrl.priorityAccounts.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: t.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: t.border),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.push_pin_outlined, color: t.textMuted, size: 24),
                            const SizedBox(height: 8),
                            Text('Henüz öncelikli hesap eklenmedi', style: TextStyle(color: t.textSecondary, fontSize: 13, fontFamily: 'Gilroy', fontWeight: FontWeight.w600)),
                          ],
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: t.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: t.border),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ctrl.priorityAccounts.map((handle) {
                            return _AccountChip(
                              handle: handle,
                              onRemove: () => ctrl.removePriorityAccount(handle),
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 28),
                    _SectionCard(
                      theme: t,
                      icon: Icons.visibility_outlined,
                      title: 'Diğer Tweetler İçin Minimum Etkileşim',
                      description: 'Yukarıdaki hesaplar dışından gelen (gündem ve genel akış) tweetler için Xquik arama API\'sine gönderilen minimum eşikler. Filtre API tarafında uygulanır — eşiği geçmeyen tweetler hiç çekilmez, kredi harcanmaz. Min. görüntülenme yalnızca arama sonuçlarına uygulanır (öncelikli hesap/takım akışlarında Xquik bu filtreyi desteklemiyor).',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _EngagementNumberField(theme: t, controller: _minFavesCtrl, label: 'Min. beğeni'),
                              _EngagementNumberField(theme: t, controller: _minRetweetsCtrl, label: 'Min. retweet'),
                              _EngagementNumberField(theme: t, controller: _minRepliesCtrl, label: 'Min. yanıt'),
                              _EngagementNumberField(theme: t, controller: _minQuotesCtrl, label: 'Min. alıntı'),
                              _EngagementNumberField(theme: t, controller: _minViewsCtrl, label: 'Min. görüntülenme'),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ElevatedButton(
                            onPressed: () => _saveThresholds(ctrl),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            ),
                            child: const Text('Kaydet', style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _addAccount(WebAdminController ctrl) {
    final handle = _accountCtrl.text.trim();
    if (handle.isEmpty) return;
    ctrl.addPriorityAccount(handle).then((success) {
      if (success) _accountCtrl.clear();
    });
  }

  void _saveThresholds(WebAdminController ctrl) {
    final minFaves = int.tryParse(_minFavesCtrl.text.trim());
    final minRetweets = int.tryParse(_minRetweetsCtrl.text.trim());
    final minReplies = int.tryParse(_minRepliesCtrl.text.trim());
    final minQuotes = int.tryParse(_minQuotesCtrl.text.trim());
    final minViews = int.tryParse(_minViewsCtrl.text.trim());
    if ([minFaves, minRetweets, minReplies, minQuotes, minViews].any((v) => v == null || v < 0)) {
      Get.snackbar('Geçersiz değer', 'Lütfen tüm alanlara geçerli bir sayı girin', backgroundColor: const Color(0xFF1A1A1A), colorText: Colors.white);
      return;
    }
    ctrl
        .updateEngagementThresholds(
      minFaves: minFaves!,
      minRetweets: minRetweets!,
      minReplies: minReplies!,
      minQuotes: minQuotes!,
      minViews: minViews!,
    )
        .then((success) {
      if (success) {
        Get.snackbar('Kaydedildi', 'Etkileşim eşikleri güncellendi', backgroundColor: const Color(0xFF1A1A1A), colorText: Colors.white);
      }
    });
  }
}

class _SectionCard extends StatelessWidget {
  final AdminTheme theme;
  final IconData icon;
  final String title;
  final String description;
  final Widget child;

  const _SectionCard({
    required this.theme,
    required this.icon,
    required this.title,
    required this.description,
    required this.child,
  });

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
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 16),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(color: t.textPrimary, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Gilroy')),
            ],
          ),
          const SizedBox(height: 6),
          Text(description, style: TextStyle(color: t.textSecondary, fontSize: 12, fontFamily: 'Gilroy', height: 1.4)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _AccountChip extends StatelessWidget {
  final String handle;
  final VoidCallback onRemove;

  const _AccountChip({required this.handle, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    const twitterBlue = Color(0xFF1DA1F2);
    return Container(
      padding: const EdgeInsets.only(left: 12, right: 6, top: 6, bottom: 6),
      decoration: BoxDecoration(
        color: twitterBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: twitterBlue.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '@$handle',
            style: const TextStyle(color: twitterBlue, fontFamily: 'Gilroy', fontWeight: FontWeight.w600, fontSize: 13),
          ),
          const SizedBox(width: 2),
          GestureDetector(
            onTap: onRemove,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.close, color: twitterBlue.withValues(alpha: 0.7), size: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountInput extends StatelessWidget {
  final TextEditingController controller;
  final AdminTheme theme;
  final VoidCallback onSubmitted;

  const _AccountInput({required this.controller, required this.theme, required this.onSubmitted});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return TextField(
      controller: controller,
      onSubmitted: (_) => onSubmitted(),
      style: TextStyle(color: t.textPrimary, fontFamily: 'Gilroy', fontSize: 14),
      decoration: InputDecoration(
        hintText: 'örn: FabrizioRomano',
        hintStyle: TextStyle(color: t.textMuted, fontFamily: 'Gilroy', fontSize: 13),
        prefixIcon: Icon(Icons.alternate_email, color: t.iconMuted, size: 18),
        filled: true,
        fillColor: t.bg,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _EngagementNumberField extends StatelessWidget {
  final AdminTheme theme;
  final TextEditingController controller;
  final String label;

  const _EngagementNumberField({required this.theme, required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return SizedBox(
      width: 150,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        style: TextStyle(color: t.textPrimary, fontFamily: 'Gilroy', fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: t.textSecondary, fontFamily: 'Gilroy', fontSize: 13),
          filled: true,
          fillColor: t.bg,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: t.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}
