import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:lottie/lottie.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/widgets/profile/premium_card.dart';
import 'package:atlas/core/services/firestore_service.dart';
import 'package:atlas/core/services/analytics_service.dart';
import 'package:atlas/core/services/purchases_service.dart';
import 'package:atlas/modules/auth/controllers/auth_controller.dart';
import 'package:atlas/modules/auth/views/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _yearlySelected = true;
  bool _submitting = false;

  // Firestore'daki `prices/premium` dokümanı gelene kadar null — ekranda
  // varsayılan/eski bir fiyat göstermek yerine yükleniyor durumu gösterilir.
  PremiumPricing? _pricing;
  StreamSubscription<PremiumPricing>? _pricingSub;
  Offerings? _offerings;
  PremiumStatus? _status;
  StreamSubscription<PremiumStatus>? _statusSub;
  bool _showConfetti = false;

  static const List<Map<String, String>> _features = [
    {'icon': '🚫', 'text': 'Reklamsız kullanım'},
    {'icon': '🤖', 'text': 'Gelişmiş AI özetleri'},
    {'icon': '🔔', 'text': 'Anlık bildirimler'},
    {'icon': '🎯', 'text': 'Özel filtreler'},
    {'icon': '🔖', 'text': 'Kaydedilenler sınırsız'},
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsService.logScreenView('premium', screenClass: 'PremiumScreen');
    AnalyticsService.logPremiumView();
    _pricingSub = FirestoreService().watchPremiumPricing().listen((p) {
      if (mounted) setState(() => _pricing = p);
    });
    PurchasesService.getOfferings().then((o) {
      if (mounted) setState(() => _offerings = o);
    });
    final auth = Get.find<AuthController>();
    if (auth.isLoggedIn) {
      _statusSub = FirestoreService().watchPremiumStatus(auth.uid!).listen((s) {
        if (mounted) setState(() => _status = s);
      });
      // Firestore'daki kayıt eski/eksik olabilir (bitiş tarihi yazılmadan önce
      // alınmış ya da abonelik süresi dolmuş). Gerçek kaynak RevenueCat.
      PurchasesService.syncWithFirestore(auth.uid!);
    }
  }

  @override
  void dispose() {
    _pricingSub?.cancel();
    _statusSub?.cancel();
    super.dispose();
  }

  Future<void> _purchase() async {
    final auth = Get.find<AuthController>();
    if (!auth.isLoggedIn) {
      Get.to(() => const LoginScreen(), transition: Transition.cupertino);
      return;
    }

    final wantedType = _yearlySelected ? PackageType.annual : PackageType.monthly;
    Package? package;
    for (final p in _offerings?.current?.availablePackages ?? const <Package>[]) {
      if (p.packageType == wantedType) {
        package = p;
        break;
      }
    }
    if (package == null) {
      Get.snackbar(
        'Ürün bulunamadı',
        'RevenueCat\'te bu plan için tanımlı bir ürün yok. Lütfen daha sonra tekrar dene.',
        backgroundColor: AppColors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _submitting = true);
    final plan = _yearlySelected ? 'yearly' : 'monthly';
    try {
      final result = await PurchasesService.purchasePackage(package);
      final entitlement = result.customerInfo.entitlements.active[PurchasesService.entitlementId];
      if (entitlement == null) {
        throw Exception('purchase succeeded but entitlement not active');
      }
      DateTime? until;
      final expirationDate = entitlement.expirationDate;
      if (expirationDate != null) {
        try {
          until = DateTime.parse(expirationDate);
        } catch (_) {}
      }
      await FirestoreService().setUserPremium(auth.uid!, true, plan: plan, until: until);
      final product = package.storeProduct;
      AnalyticsService.logPremiumPurchase(
        plan: plan,
        value: product.price,
        currency: product.currencyCode,
      );
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _showConfetti = true;
      });
      await Future.delayed(const Duration(milliseconds: 2200));
      if (!mounted) return;
      setState(() => _showConfetti = false);
      Get.back();
      Get.snackbar(
        'Başarılı! 🎉',
        'Premium aboneliğiniz aktif edildi.',
        backgroundColor: AppColors.primary,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      final cancelled = PurchasesErrorHelper.getErrorCode(e) == PurchasesErrorCode.purchaseCancelledError;
      if (cancelled) return;
      Get.snackbar(
        'Hata',
        'Premium etkinleştirilemedi, tekrar dene.',
        backgroundColor: AppColors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      Get.snackbar(
        'Hata',
        'Premium etkinleştirilemedi, tekrar dene.',
        backgroundColor: AppColors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _backHeader(Tc c) {
    return Padding(
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
              child: Text('Premium', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontSize: 18, fontFamily: 'Gilroy')),
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _statusCard(Tc c) {
    final status = _status;
    final planLabel = status?.plan == 'yearly' ? 'Yıllık Plan' : (status?.plan == 'monthly' ? 'Aylık Plan' : null);
    final until = status?.until;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E2200), Color(0xFF17120A)],
        ),
        border: Border.all(color: AppColors.yellow.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: AppColors.yellow.withValues(alpha: 0.12), blurRadius: 24, spreadRadius: 1)],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [AppColors.yellow.withValues(alpha: 0.95), const Color(0xFFB8860B)],
              ),
              boxShadow: [BoxShadow(color: AppColors.yellow.withValues(alpha: 0.35), blurRadius: 18, spreadRadius: 1)],
            ),
            child: const Center(child: Text('👑', style: TextStyle(fontSize: 26))),
          ),
          const SizedBox(height: 12),
          const Text('Premium Aktif', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, fontFamily: 'Gilroy')),
          const SizedBox(height: 20),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 16),
          if (until != null) ...[
            Text(
              planLabel == null ? 'Yenilenmesine kalan süre' : '$planLabel · yenilenmesine kalan',
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontFamily: 'Gilroy'),
            ),
            const SizedBox(height: 12),
            _CountdownTimer(until: until),
          ] else
            Text(
              planLabel == null ? 'Süresiz erişim' : '$planLabel · süresiz erişim',
              style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Gilroy'),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    final pricing = _pricing;
    if (pricing == null) {
      return Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          child: Column(
            children: [
              _backHeader(c),
              const Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.primary))),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: c.bg,
      body: Stack(
        children: [
          SafeArea(
        child: Column(
          children: [
            _backHeader(c),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    // ── Markalı koyu-altın hero başlık ────────────────────
                    // Temadan bağımsız sabit koyu-altın zemin — açık temada
                    // yarı saydam sarı üstü metin rengi kontrastı yetersiz
                    // kalıyordu, burada her zaman aynı (yüksek kontrastlı) görünür.
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF2E2200), Color(0xFF17120A)],
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.yellow.withValues(alpha: 0.95), const Color(0xFFB8860B)],
                              ),
                              boxShadow: [
                                BoxShadow(color: AppColors.yellow.withValues(alpha: 0.4), blurRadius: 28, spreadRadius: 2),
                              ],
                            ),
                            child: const Center(child: Text('👑', style: TextStyle(fontSize: 38))),
                          ),
                          const SizedBox(height: 18),
                          const Text('Pulse Premium', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 27, fontFamily: 'Gilroy')),
                          const SizedBox(height: 8),
                          const Text(
                            'Reklamsız deneyim, gelişmiş AI özellikleri\nve daha fazlası.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Gilroy', height: 1.5),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                      child: Column(
                        children: [
                          Obx(() {
                            final isPremium = Get.find<AuthController>().isPremium.value;
                            final accent = isPremium ? AppColors.yellow : AppColors.primary;
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: c.card,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isPremium ? AppColors.yellow.withValues(alpha: 0.35) : c.divider,
                                  width: isPremium ? 1 : 0.5,
                                ),
                              ),
                              child: Column(
                                children: [
                                  if (isPremium) ...[
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: AppColors.yellow.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        children: [
                                          const Text('✨', style: TextStyle(fontSize: 15)),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              'Şu an bu özelliklerin tamamını kullanabiliyorsun',
                                              style: TextStyle(
                                                color: c.textPrimary,
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'Gilroy',
                                                height: 1.3,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                  ],
                                  ..._features.map((f) => Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8),
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                color: isPremium ? AppColors.yellow.withValues(alpha: 0.15) : AppColors.lightPrimary,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Center(child: Text(f['icon']!, style: const TextStyle(fontSize: 15))),
                                            ),
                                            const SizedBox(width: 14),
                                            Expanded(
                                              child: Text(f['text']!, style: TextStyle(color: c.textPrimary, fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'Gilroy')),
                                            ),
                                            if (isPremium)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: AppColors.yellow.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: const Text(
                                                  'Aktif',
                                                  style: TextStyle(color: AppColors.yellow, fontSize: 10, fontWeight: FontWeight.w800, fontFamily: 'Gilroy'),
                                                ),
                                              )
                                            else
                                              Icon(HugeIcons.strokeRoundedCheckmarkCircle02, color: accent, size: 18),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                            );
                          }),
                          const SizedBox(height: 20),
                          Obx(() {
                            final alreadyPremium = Get.find<AuthController>().isPremium.value;
                            if (alreadyPremium) return _statusCard(c);
                            return Column(
                              children: [
                                PriceOption(
                                  label: 'Aylık',
                                  price: pricing.formattedMonthly,
                                  selected: !_yearlySelected,
                                  onTap: () {
                                    AnalyticsService.logPremiumPlanSelected('monthly');
                                    setState(() => _yearlySelected = false);
                                  },
                                ),
                                const SizedBox(height: 10),
                                PriceOption(
                                  label: 'Yıllık',
                                  price: pricing.formattedYearly,
                                  discount: pricing.yearlyDiscountLabel,
                                  selected: _yearlySelected,
                                  onTap: () {
                                    AnalyticsService.logPremiumPlanSelected('yearly');
                                    setState(() => _yearlySelected = true);
                                  },
                                ),
                              ],
                            );
                          }),
                          const SizedBox(height: 28),
                          Obx(() {
                            final alreadyPremium = Get.find<AuthController>().isPremium.value;
                            if (alreadyPremium) return const SizedBox.shrink();
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _submitting ? null : _purchase,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                                  disabledForegroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                child: _submitting
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                                      )
                                    : const Text(
                                        "Premium'u Başlat",
                                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, fontFamily: 'Gilroy'),
                                      ),
                              ),
                            );
                          }),
                          const SizedBox(height: 10),
                          Text(
                            'İstediğin zaman iptal edebilirsin, gizli ücret yok',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Gilroy'),
                          ),
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: () => launchUrl(
                              Uri.parse('https://xaiuygulama.web.app/privacy'),
                              mode: LaunchMode.externalApplication,
                            ),
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
                  ],
                ),
              ),
            ),
          ],
        ),
          ),
          if (_showConfetti)
            Positioned.fill(
              child: IgnorePointer(
                child: Lottie.asset(
                  'assets/lottie/confetti.json',
                  repeat: false,
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Bitiş tarihine kalan süreyi gün/saat/dakika olarak canlı gösterir.
class _CountdownTimer extends StatefulWidget {
  final DateTime until;
  const _CountdownTimer({required this.until});

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer> {
  Timer? _timer;
  late Duration _remaining;

  @override
  void initState() {
    super.initState();
    _remaining = widget.until.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _remaining = widget.until.difference(DateTime.now()));
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = _remaining.isNegative ? Duration.zero : _remaining;
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _unit(days, 'gün'),
        _unit(hours, 'saat'),
        _unit(minutes, 'dk'),
        // Son gün içindeyken saniye de göster — bitişe yaklaşırken sayacın
        // canlı olduğu görünür.
        if (days == 0) _unit(seconds, 'sn'),
      ],
    );
  }

  Widget _unit(int value, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
      children: [
        Container(
          width: 56,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.yellow.withValues(alpha: 0.25)),
          ),
          child: Text(
            value.toString().padLeft(2, '0'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.yellow, fontWeight: FontWeight.w900, fontSize: 20, fontFamily: 'Gilroy'),
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 10, fontFamily: 'Gilroy')),
      ],
      ),
    );
  }
}
