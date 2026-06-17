import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/widgets/profile/premium_card.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _yearlySelected = true;

  static const List<Map<String, String>> _features = [
    {'icon': '🚫', 'text': 'Reklamsız kullanım'},
    {'icon': '🤖', 'text': 'Gelişmiş AI özetleri'},
    {'icon': '🔔', 'text': 'Anlık bildirimler'},
    {'icon': '🎯', 'text': 'Özel filtreler'},
    {'icon': '🔖', 'text': 'Kaydedilenler sınırsız'},
  ];

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: c.surfaceElevated, shape: BoxShape.circle),
                      child: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary, size: 16),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text('Premium',
                          style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontSize: 18, fontFamily: 'Gilroy')),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2000),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.35), width: 1.5),
                      ),
                      child: const Center(child: Text('👑', style: TextStyle(fontSize: 34))),
                    ),
                    const SizedBox(height: 14),
                    Text('Pulse Premium',
                        style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w900, fontSize: 24, fontFamily: 'Gilroy')),
                    const SizedBox(height: 8),
                    Text(
                      'Reklamsız deneyim, gelişmiş AI özellikleri\nve daha fazlası.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: c.textMuted, fontSize: 13, fontFamily: 'Gilroy', height: 1.5),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: c.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: c.divider, width: 0.5),
                      ),
                      child: Column(
                        children: _features
                            .map((f) => Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      Icon(HugeIcons.strokeRoundedCheckmarkCircle02, color: AppColors.primary, size: 18),
                                      const SizedBox(width: 12),
                                      Text(f['text']!,
                                          style: TextStyle(color: c.textPrimary, fontSize: 14, fontFamily: 'Gilroy')),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    PriceOption(
                      label: 'Aylık',
                      price: '₺49,99',
                      selected: !_yearlySelected,
                      onTap: () => setState(() => _yearlySelected = false),
                    ),
                    const SizedBox(height: 10),
                    PriceOption(
                      label: 'Yıllık',
                      price: '₺399,99',
                      discount: '%33 indirim!',
                      selected: _yearlySelected,
                      onTap: () => setState(() => _yearlySelected = true),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
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
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text("Premium'u Başlat",
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, fontFamily: 'Gilroy')),
                      ),
                    ),
                    const SizedBox(height: 14),
                    GestureDetector(
                      onTap: () {},
                      child: const Text(
                        'Satın alma koşulları ve gizlilik politikası',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontFamily: 'Gilroy',
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
