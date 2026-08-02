import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:atlas/core/services/ad_service.dart';
import 'package:atlas/themes/tc.dart';

/// Small banner ad meant to be interleaved between tweet cards in a feed.
class InFeedBannerAd extends StatefulWidget {
  const InFeedBannerAd({super.key});

  @override
  State<InFeedBannerAd> createState() => _InFeedBannerAdState();
}

class _InFeedBannerAdState extends State<InFeedBannerAd> {
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
    AdService.log('Banner load requested (hash=$hashCode)');
    final ad = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: AdSize.mediumRectangle,
      request: AdService.request,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          AdService.log('Banner loaded OK (adUnitId=${AdService.bannerAdUnitId})');
          if (!mounted) return;
          setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          AdService.log('Banner failed to load: code=${error.code} domain=${error.domain} message=${error.message}');
          ad.dispose();
        },
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
      return _buildAd(context, ad);
    });
  }

  Widget _buildAd(BuildContext context, BannerAd ad) {
    final c = Tc.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.divider),
      ),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Text('sponsored'.tr, style: TextStyle(color: c.textSecondary, fontSize: 10, fontFamily: 'Gilroy')),
            ),
          ),
          SizedBox(
            width: ad.size.width.toDouble(),
            height: ad.size.height.toDouble(),
            child: AdWidget(ad: ad),
          ),
        ],
      ),
    );
  }
}

/// Returns [items] with an [InFeedBannerAd] inserted after every [every] entries.
List<Widget> interleaveBannerAds(List<Widget> items, {int every = 5}) {
  final result = <Widget>[];
  for (var i = 0; i < items.length; i++) {
    result.add(items[i]);
    if ((i + 1) % every == 0) {
      result.add(InFeedBannerAd(key: ValueKey('feed_ad_$i')));
    }
  }
  return result;
}
