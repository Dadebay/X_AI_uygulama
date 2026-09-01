import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/modules/admin/controllers/web_admin_controller.dart';
import 'package:atlas/modules/admin/views/web/admin_theme.dart';

class WebPremiumSettingsPage extends StatefulWidget {
  const WebPremiumSettingsPage({super.key});

  @override
  State<WebPremiumSettingsPage> createState() => _WebPremiumSettingsPageState();
}

class _WebPremiumSettingsPageState extends State<WebPremiumSettingsPage> {
  late final WebAdminController _ctrl;
  late final TextEditingController _monthlyCtrl;
  late final TextEditingController _yearlyCtrl;
  late final TextEditingController _discountCtrl;
  late final TextEditingController _currencyCtrl;
  bool _saving = false;
  bool _seeded = false;
  Worker? _pageEnterWorker;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<WebAdminController>();
    _monthlyCtrl = TextEditingController();
    _yearlyCtrl = TextEditingController();
    _discountCtrl = TextEditingController();
    _currencyCtrl = TextEditingController();
    // Sidebar bu sayfayı bir IndexedStack içinde canlı tutuyor (asla dispose
    // olmuyor) — bu yüzden yalnızca ilk build'de değil, kullanıcı her
    // "Premium Fiyatları"na her girdiğinde Firestore'daki güncel değeri
    // forma tekrar yazıyoruz.
    _pageEnterWorker = ever<int>(_ctrl.selectedPage, (page) {
      if (page == 6) _seedFromController(force: true);
    });
  }

  void _seedFromController({bool force = false}) {
    if (_seeded && !force) return;
    _seeded = true;
    _monthlyCtrl.text = _ctrl.premiumMonthlyPrice.value.toStringAsFixed(2);
    _yearlyCtrl.text = _ctrl.premiumYearlyPrice.value.toStringAsFixed(2);
    _discountCtrl.text = _ctrl.premiumYearlyDiscountLabel.value;
    _currencyCtrl.text = _ctrl.premiumCurrency.value;
  }

  @override
  void dispose() {
    _pageEnterWorker?.dispose();
    _monthlyCtrl.dispose();
    _yearlyCtrl.dispose();
    _discountCtrl.dispose();
    _currencyCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final monthly = double.tryParse(_monthlyCtrl.text.replaceAll(',', '.'));
    final yearly = double.tryParse(_yearlyCtrl.text.replaceAll(',', '.'));
    if (monthly == null || yearly == null) {
      Get.snackbar('Hata', 'Geçerli bir fiyat girin', backgroundColor: AppColors.red, colorText: Colors.white);
      return;
    }
    setState(() => _saving = true);
    final success = await _ctrl.updatePremiumPricing(
      monthlyPrice: monthly,
      yearlyPrice: yearly,
      yearlyDiscountLabel: _discountCtrl.text.trim(),
      currency: _currencyCtrl.text.trim().isEmpty ? '₺' : _currencyCtrl.text.trim(),
    );
    if (mounted) setState(() => _saving = false);
    if (success) {
      Get.snackbar(
        'Kaydedildi',
        'Premium fiyatları güncellendi',
        backgroundColor: const Color(0xFF1A1A1A),
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'Premium Fiyatları',
                    style: TextStyle(color: t.textPrimary, fontSize: 20, fontWeight: FontWeight.w800, fontFamily: 'Gilroy'),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Uygulamadaki Premium ekranında gösterilen abonelik fiyatları',
                    style: TextStyle(color: t.textSecondary, fontSize: 13, fontFamily: 'Gilroy'),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  setState(() => _seeded = false);
                  _ctrl.refreshPage(6);
                },
                icon: Icon(Icons.refresh, color: t.iconMuted),
              ),
            ],
          ),
        ),
        Expanded(
          child: Obx(() {
            if (_ctrl.isLoadingPremiumPricing.value && !_seeded) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primary));
            }
            _seedFromController();
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
                          Icon(Icons.workspace_premium_outlined, color: AppColors.primary, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            'Abonelik Fiyatları',
                            style: TextStyle(color: t.textPrimary, fontSize: 14, fontWeight: FontWeight.w700, fontFamily: 'Gilroy'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Değişiklik kaydedildiğinde açık uygulamalar dahil anında tüm kullanıcılara yansır.',
                        style: TextStyle(color: t.textSecondary, fontSize: 12, fontFamily: 'Gilroy', height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _Field(label: 'Para birimi sembolü', controller: _currencyCtrl, theme: t),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _Field(label: 'Aylık fiyat', controller: _monthlyCtrl, theme: t, keyboardType: TextInputType.number),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _Field(label: 'Yıllık fiyat', controller: _yearlyCtrl, theme: t, keyboardType: TextInputType.number),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _Field(label: 'Yıllık indirim etiketi (ör. %33 indirim!)', controller: _discountCtrl, theme: t),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _save,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _saving
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                              : const Text('Kaydet', style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w700)),
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
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final AdminTheme theme;
  final TextInputType? keyboardType;

  const _Field({required this.label, required this.controller, required this.theme, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    final t = theme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: t.textSecondary, fontSize: 12, fontFamily: 'Gilroy', fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: TextStyle(color: t.textPrimary, fontFamily: 'Gilroy', fontSize: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: t.bg,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.border)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: t.border)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary)),
          ),
        ),
      ],
    );
  }
}
