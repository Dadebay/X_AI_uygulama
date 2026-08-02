import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/modules/admin/controllers/web_admin_controller.dart';
import 'package:atlas/modules/admin/views/web/admin_theme.dart';

class WebAdsSettingsPage extends StatelessWidget {
  const WebAdsSettingsPage({super.key});

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
                    'Reklamlar',
                    style: TextStyle(color: t.textPrimary, fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Gilroy'),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Uygulama genelinde reklamları açıp kapatın',
                    style: TextStyle(color: t.textSecondary, fontSize: 13, fontFamily: 'Gilroy'),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: ctrl.loadAdsEnabled,
                icon: Icon(Icons.refresh, color: t.iconMuted),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (ctrl.isLoadingAdsEnabled.value) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(28),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Container(
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
                          Icon(Icons.campaign_outlined, color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Reklamlar',
                            style: TextStyle(color: t.textPrimary, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Gilroy'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Kapatıldığında akıştaki banner reklamlar ve linke tıklanınca gösterilen reklam ekranı, açık uygulamalar dahil anında tüm kullanıcılar için devre dışı kalır.',
                        style: TextStyle(color: t.textSecondary, fontSize: 12, fontFamily: 'Gilroy', height: 1.4),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: t.bg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: t.border),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          activeThumbColor: AppColors.primary,
                          title: Text(
                            ctrl.adsEnabled.value ? 'Reklamlar açık' : 'Reklamlar kapalı',
                            style: TextStyle(color: t.textPrimary, fontFamily: 'Gilroy', fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                          subtitle: Text(
                            ctrl.adsEnabled.value
                                ? 'Kullanıcılar banner ve reklam ekranını görmeye devam ediyor'
                                : 'Hiçbir yerde reklam gösterilmiyor',
                            style: TextStyle(color: t.textSecondary, fontFamily: 'Gilroy', fontSize: 12),
                          ),
                          value: ctrl.adsEnabled.value,
                          onChanged: (value) => _toggle(ctrl, value),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  void _toggle(WebAdminController ctrl, bool value) {
    ctrl.setAdsEnabled(value).then((success) {
      if (success) {
        Get.snackbar(
          'Kaydedildi',
          value ? 'Reklamlar açıldı' : 'Reklamlar kapatıldı',
          backgroundColor: const Color(0xFF1A1A1A),
          colorText: Colors.white,
        );
      }
    });
  }
}
