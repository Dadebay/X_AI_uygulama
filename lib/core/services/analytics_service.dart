import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

/// Tek merkezden Firebase/Google Analytics event ve kullanıcı özelliği
/// gönderimi. Tüm event isimleri GA4'ün snake_case konvansiyonuna uyar.
///
/// Her çağrı [_guard] ile sarılır: native tarafta plugin henüz kayıtlı
/// değilse (ör. hot restart sonrası, native kod yeniden derlenmeden) ya da
/// ağ/servis hatası olursa uygulamayı çökertmez, sessizce loglar.
class AnalyticsService {
  AnalyticsService._();

  static final FirebaseAnalytics instance = FirebaseAnalytics.instance;

  static FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: instance);

  static Future<void> _guard(String label, Future<void> Function() action) async {
    try {
      await action();
    } catch (e) {
      if (kDebugMode) print('[Analytics] $label gönderilemedi: $e');
    }
  }

  static Future<void> _log(String name, [Map<String, Object?>? params]) => _guard(name, () {
        final clean = params == null
            ? null
            : Map<String, Object>.fromEntries(
                params.entries.where((e) => e.value != null).map((e) => MapEntry(e.key, e.value!)),
              );
        return instance.logEvent(name: name, parameters: clean);
      });

  // ─── Ekran görüntülemeleri ────────────────────────────────────────────
  static Future<void> logScreenView(String screenName, {String? screenClass}) => _guard(
        'screen_view',
        () => instance.logScreenView(screenName: screenName, screenClass: screenClass ?? screenName),
      );

  // ─── Kimlik / kullanıcı ───────────────────────────────────────────────
  static Future<void> setUserId(String? uid) => _guard('set_user_id', () => instance.setUserId(id: uid));

  static Future<void> setUserProperties({bool? isPremium, String? plan}) => _guard('set_user_properties', () async {
        if (isPremium != null) {
          await instance.setUserProperty(name: 'is_premium', value: isPremium.toString());
        }
        if (plan != null) {
          await instance.setUserProperty(name: 'premium_plan', value: plan);
        }
      });

  static Future<void> logLogin(String method) =>
      _guard('login', () => instance.logLogin(loginMethod: method));

  static Future<void> logSignUp(String method) =>
      _guard('sign_up', () => instance.logSignUp(signUpMethod: method));

  static Future<void> logLogout() => _log('logout');

  // ─── Arama / keşif ──────────────────────────────────────────────────
  static Future<void> logSearch(String term) =>
      _guard('search', () => instance.logSearch(searchTerm: term));

  static Future<void> logSelectContent({required String type, required String id}) =>
      _guard('select_content', () => instance.logSelectContent(contentType: type, itemId: id));

  static Future<void> logTrendView(String trendName) => _log('trend_view', {'trend_name': trendName});

  // ─── Tweet etkileşimleri ────────────────────────────────────────────
  static Future<void> logTweetOpen(String tweetId, {String? source}) =>
      _log('tweet_open', {'tweet_id': tweetId, 'source': source});

  static Future<void> logTweetSave(String tweetId, bool saved) => _log(
        saved ? 'add_to_wishlist' : 'remove_from_wishlist',
        {'item_id': tweetId, 'item_category': 'tweet'},
      );

  static Future<void> logTweetShare(String tweetId, {String method = 'share_sheet'}) => _guard(
        'share',
        () => instance.logShare(contentType: 'tweet', itemId: tweetId, method: method),
      );

  // ─── Bildirim ──────────────────────────────────────────────────────
  static Future<void> logNotificationOpened({String? type}) =>
      _log('notification_opened', {'type': type});

  // ─── Premium / gelir ────────────────────────────────────────────────
  static Future<void> logPremiumView() => _log('premium_screen_view');

  static Future<void> logPremiumPlanSelected(String plan) =>
      _log('premium_plan_selected', {'plan': plan});

  static Future<void> logPremiumPurchase({
    required String plan,
    required double value,
    required String currency,
  }) =>
      _guard(
        'purchase',
        () => instance.logPurchase(
          currency: currency,
          value: value,
          transactionId: null,
          parameters: {'plan': plan, 'item_name': 'premium_$plan'},
        ),
      );

  // ─── Reklam ────────────────────────────────────────────────────────
  static Future<void> logAdImpression({required String adType, required String placement}) => _guard(
        'ad_impression',
        () => instance.logAdImpression(adPlatform: 'admob', adSource: adType, adFormat: placement),
      );

  static Future<void> logAdClick({required String adType, required String placement}) =>
      _log('ad_click', {'ad_type': adType, 'placement': placement});

  static Future<void> logAdFailed({required String adType, required String placement, String? error}) =>
      _log('ad_failed_to_load', {'ad_type': adType, 'placement': placement, 'error': error});

  // ─── Ayarlar ──────────────────────────────────────────────────────
  static Future<void> logLanguageChanged(String langCode) =>
      _log('language_changed', {'language': langCode});

  static Future<void> logThemeChanged(bool isDark) =>
      _log('theme_changed', {'theme': isDark ? 'dark' : 'light'});

  static Future<void> setCollectionEnabled(bool enabled) async {
    if (kIsWeb) return; // web'de otomatik açık, ayrıca çağrıya gerek yok
    await _guard('set_collection_enabled', () => instance.setAnalyticsCollectionEnabled(enabled));
  }
}
