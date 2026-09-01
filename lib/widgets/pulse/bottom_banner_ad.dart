import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:atlas/core/services/ad_service.dart';
import 'package:atlas/core/services/analytics_service.dart';
import 'package:atlas/themes/tc.dart';

/// Thin, fixed banner ad shown above the app's bottom navigation bar.
/// Collapses reactively (via [AdService.adsEnabled]) once the user is Premium.
class BottomBannerAd extends StatefulWidget {
  const BottomBannerAd({super.key});

  @override
  State<BottomBannerAd> createState() => _BottomBannerAdState();
}

class _BottomBannerAdState extends State<BottomBannerAd> {
  BannerAd? _ad;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _maybeLoadAd();
  }

  void _maybeLoadAd() {
    if (_ad != null || _isLoaded) return;
    if (AdService.isSupported && AdService.adsEnabled) _loadAd();
  }

  void _loadAd() {
    AdService.log('Bottom banner load requested (hash=$hashCode)');
    final ad = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.banner,
      request: AdService.request,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          AdService.log('Bottom banner loaded OK (adUnitId=${AdService.bannerAdUnitId})');
          if (!mounted) return;
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          AdService.log('Bottom banner failed to load: code=${error.code} domain=${error.domain} message=${error.message}');
          AnalyticsService.logAdFailed(adType: 'banner', placement: 'bottom_nav', error: error.message);
          ad.dispose();
        },
        onAdImpression: (_) => AnalyticsService.logAdImpression(adType: 'banner', placement: 'bottom_nav'),
        onAdClicked: (_) => AnalyticsService.logAdClick(adType: 'banner', placement: 'bottom_nav'),
      ),
    );
    _ad = ad;
    ad.load();
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!AdService.adsEnabled) return const SizedBox.shrink();
      if (_ad == null && !_isLoaded) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLoadAd());
      }
      final ad = _ad;
      if (!_isLoaded || ad == null) return const SizedBox.shrink();
      final c = Tc.of(context);
      return Container(
        width: double.infinity,
        color: c.card,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: SizedBox(
          width: ad.size.width.toDouble(),
          height: ad.size.height.toDouble(),
          child: AdWidget(ad: ad),
        ),
      );
    });
  }
}
