import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/modules/profile/views/premium_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shows a full-screen ad before redirecting to [targetUrl].
/// - Countdown starts at 3 seconds.
/// - Tapping "Reklamı Geç" DURING countdown → Premium paywall.
/// - Tapping "Reklamı Geç" AFTER countdown → closes ad & opens [targetUrl].
class AdOverlayScreen extends StatefulWidget {
  final String targetUrl;

  const AdOverlayScreen({super.key, required this.targetUrl});

  @override
  State<AdOverlayScreen> createState() => _AdOverlayScreenState();
}

class _AdOverlayScreenState extends State<AdOverlayScreen> with SingleTickerProviderStateMixin {
  static const int _totalSeconds = 3;
  int _remaining = _totalSeconds;
  Timer? _timer;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _remaining--);
      if (_remaining <= 0) {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  bool get _canSkip => _remaining <= 0;

  Future<void> _handleSkip() async {
    if (_canSkip) {
      Get.back();
      final uri = Uri.parse(widget.targetUrl.startsWith('http') ? widget.targetUrl : 'https://${widget.targetUrl}');
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    } else {
      // User wants to skip early → show premium
      Get.to(() => const PremiumScreen(), transition: Transition.cupertino);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Ad content ──────────────────────────────────────────
          Positioned.fill(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sponsor label
                SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Reklam',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontFamily: 'Gilroy',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                // Ad image
                Expanded(
                  child: Image.asset(
                    'assets/images/banner.png',
                    width: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF1A1A1A), Color(0xFF0D0D0D)],
                        ),
                      ),
                      child: const Center(
                        child: Text('📢', style: TextStyle(fontSize: 80)),
                      ),
                    ),
                  ),
                ),
                // Ad text block
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'HIZINI\nORTAYA KOY',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          fontFamily: 'Gilroy',
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Yeni sezon koleksiyonu şimdi satışta.',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontFamily: 'Gilroy',
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text(
                          'Şimdi Keşfet',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Gilroy',
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(height: 60), // space for bottom bar
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Countdown circle (top-right) ─────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 8, 16, 0),
                child: _CountdownCircle(
                  remaining: _remaining,
                  total: _totalSeconds,
                  pulse: _pulseCtrl,
                ),
              ),
            ),
          ),

          // ── Bottom skip bar ──────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              color: Colors.black.withOpacity(0.85),
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 12,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button
                  GestureDetector(
                    onTap: _handleSkip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: _canSkip ? AppColors.primary.withOpacity(0.15) : Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _canSkip ? AppColors.primary : Colors.white24,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Reklamı Geç',
                            style: TextStyle(
                              color: _canSkip ? AppColors.primary : Colors.white54,
                              fontFamily: 'Gilroy',
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: _canSkip ? AppColors.primary : Colors.white38,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Countdown text
                  if (!_canSkip)
                    Text(
                      '$_remaining saniye sonra devam edecek',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontFamily: 'Gilroy',
                        fontSize: 12,
                      ),
                    )
                  else
                    const Text(
                      'Atlamak için dokunun',
                      style: TextStyle(
                        color: Colors.white38,
                        fontFamily: 'Gilroy',
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownCircle extends StatelessWidget {
  final int remaining;
  final int total;
  final AnimationController pulse;

  const _CountdownCircle({
    required this.remaining,
    required this.total,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    final progress = remaining / total;
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 2.5,
            backgroundColor: Colors.white24,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          Text(
            '$remaining',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
