import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:hugeicons/hugeicons.dart';

class PremiumCard extends StatelessWidget {
  final bool yearlySelected;
  final ValueChanged<bool> onToggle;

  const PremiumCard({super.key, required this.yearlySelected, required this.onToggle});

  static const List<String> _features = [
    'Reklamsız kullanım',
    'Gelişmiş AI özellikleri',
    'Anlık bildirimler',
    'Özel filtreler',
    'Kaydedilenler sınırsız',
  ];

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.divider, width: 0.5),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2000),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.4)),
            ),
            child: const Center(child: Text('👑', style: TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 12),
          Text('Pulse Premium',
              style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w900, fontSize: 20, fontFamily: 'Gilroy')),
          const SizedBox(height: 16),
          ..._features.map((f) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(HugeIcons.strokeRoundedCheckmarkCircle02, color: AppColors.primary, size: 18),
                    const SizedBox(width: 10),
                    Text(f, style: TextStyle(color: c.textPrimary, fontSize: 14, fontFamily: 'Gilroy')),
                  ],
                ),
              )),
          const SizedBox(height: 20),
          PriceOption(label: 'Aylık', price: '₺49,99', selected: !yearlySelected, onTap: () => onToggle(false)),
          const SizedBox(height: 10),
          PriceOption(label: 'Yıllık', price: '₺399,99', discount: '%33 indirim!', selected: yearlySelected, onTap: () => onToggle(true)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showConfirmDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Premium'u Başlat",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Gilroy')),
            ),
          ),
          const SizedBox(height: 8),
          Text('Tüm abonelik koşulları ve gizlilik politikası',
              textAlign: TextAlign.center,
              style: TextStyle(color: c.textMuted, fontSize: 11, fontFamily: 'Gilroy')),
        ],
      ),
    );
  }

  void _showConfirmDialog(BuildContext context) {
    final c = Tc.of(context);
    Get.dialog(
      Dialog(
        backgroundColor: c.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👑', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              Text('Pulse Premium',
                  style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w900, fontSize: 20, fontFamily: 'Gilroy')),
              const SizedBox(height: 8),
              Text(
                yearlySelected ? 'Yıllık ₺399,99 / yıl' : 'Aylık ₺49,99 / ay',
                style: const TextStyle(color: AppColors.primary, fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Gilroy'),
              ),
              const SizedBox(height: 10),
              Text(
                'Aboneliğiniz başlatılıyor. Ödeme tamamlandıktan sonra tüm premium özellikler aktif olacaktır.',
                textAlign: TextAlign.center,
                style: TextStyle(color: c.textMuted, fontSize: 13, fontFamily: 'Gilroy'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: c.textSecondary,
                        side: BorderSide(color: c.divider),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('İptal', style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          'Başarılı! 🎉',
                          'Premium aboneliğiniz aktif edildi.',
                          backgroundColor: AppColors.primary,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Onayla', style: TextStyle(fontFamily: 'Gilroy', fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PriceOption extends StatelessWidget {
  final String label;
  final String price;
  final String? discount;
  final bool selected;
  final VoidCallback onTap;

  const PriceOption({
    super.key,
    required this.label,
    required this.price,
    required this.selected,
    required this.onTap,
    this.discount,
  });

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.lightPrimary : c.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.primary : c.divider, width: selected ? 1.5 : 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: selected ? AppColors.primary : c.textMuted, width: 2),
              ),
              child: selected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                children: [
                  Text(label,
                      style: TextStyle(
                          color: selected ? c.textPrimary : c.textSecondary,
                          fontFamily: 'Gilroy',
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  if (discount != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                      child: Text(discount!,
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700, fontFamily: 'Gilroy')),
                    ),
                  ],
                ],
              ),
            ),
            Text(price,
                style: TextStyle(
                    color: selected ? c.textPrimary : c.textSecondary,
                    fontFamily: 'Gilroy',
                    fontWeight: FontWeight.w800,
                    fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
