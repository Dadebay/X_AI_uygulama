import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:atlas/core/services/firestore_service.dart';

/// RevenueCat SDK sarmalayıcısı.
///
/// Dashboard'dan alınan platforma özel PUBLIC SDK key'leri [_androidApiKey]/
/// [_iosApiKey] alanlarına girilene kadar [isConfigured] false döner ve tüm
/// metodlar güvenle no-op olur — key eklenene kadar uygulamanın geri kalanı
/// bundan etkilenmez, sadece satın alma özelliği pasif kalır.
class PurchasesService {
  PurchasesService._();

  // Android: gerçek Google Play public SDK key'i (RevenueCat "Pulse (Play
  // Store)" app'ine bağlı).
  static const String _androidApiKey = 'goog_fdnWLMdPRYiGHNNBpbZozwMQLkW';

  // iOS: App Store Connect + RevenueCat iOS app'i kurulunca buraya `appl_...`
  // ile başlayan gerçek public key girilecek. Boş bırakıldığı sürece satın
  // alma iOS'ta devre dışı kalır — Test Store key'i BURAYA YAZILMAMALI,
  // yoksa yayınlanan sürümde sahte satın almalar mümkün olur.
  static const String _iosApiKey = '';

  /// RevenueCat'te tanımlı entitlement identifier'ı (Premium erişimini temsil eder).
  static const String entitlementId = 'Pulse Premium';

  static String get _apiKey => Platform.isAndroid ? _androidApiKey : _iosApiKey;

  static bool get isConfigured => !kIsWeb && _apiKey.isNotEmpty;

  static Future<void> init({String? appUserId}) async {
    if (!isConfigured) {
      if (kDebugMode) print('[Purchases] RevenueCat API key girilmedi, init atlandı.');
      return;
    }
    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
      final config = PurchasesConfiguration(_apiKey)..appUserID = appUserId;
      await Purchases.configure(config);
    } catch (e) {
      if (kDebugMode) print('[Purchases] init başarısız: $e');
    }
  }

  /// Firebase kullanıcısı giriş yaptığında RevenueCat kimliğini onunla eşler
  /// — satın almalar doğru kullanıcıya bağlanır.
  static Future<void> logIn(String appUserId) async {
    if (!isConfigured) return;
    try {
      await Purchases.logIn(appUserId);
    } catch (e) {
      if (kDebugMode) print('[Purchases] logIn başarısız: $e');
    }
  }

  static Future<void> logOut() async {
    if (!isConfigured) return;
    try {
      await Purchases.logOut();
    } catch (e) {
      if (kDebugMode) print('[Purchases] logOut başarısız: $e');
    }
  }

  static Future<Offerings?> getOfferings() async {
    if (!isConfigured) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      if (kDebugMode) print('[Purchases] getOfferings başarısız: $e');
      return null;
    }
  }

  static Future<PurchaseResult> purchasePackage(Package package) => Purchases.purchasePackage(package);

  static Future<CustomerInfo> restorePurchases() => Purchases.restorePurchases();

  static bool hasPremium(CustomerInfo info) => info.entitlements.active.containsKey(entitlementId);

  static Future<CustomerInfo?> getCustomerInfo() async {
    if (!isConfigured) return null;
    try {
      return await Purchases.getCustomerInfo();
    } catch (e) {
      if (kDebugMode) print('[Purchases] getCustomerInfo başarısız: $e');
      return null;
    }
  }

  /// Aktif Premium aboneliğin bitiş tarihi + planı. RevenueCat kaynağından
  /// okunur; Firestore'daki kayıt eski/eksik olsa bile doğru veriyi verir.
  static Future<({DateTime? until, String? plan})?> activeSubscription() async {
    final info = await getCustomerInfo();
    final ent = info?.entitlements.active[entitlementId];
    if (ent == null) return null;

    DateTime? until;
    final raw = ent.expirationDate;
    if (raw != null) {
      try {
        until = DateTime.parse(raw).toLocal();
      } catch (_) {}
    }

    final id = ent.productIdentifier.toLowerCase();
    final plan = id.contains('year') || id.contains('annual')
        ? 'yearly'
        : (id.contains('month') ? 'monthly' : null);

    return (until: until, plan: plan);
  }

  /// RevenueCat'i tek doğru kaynak kabul edip Firestore'u ona göre günceller:
  /// abonelik aktifse plan/bitiş tarihini yazar, süresi dolmuşsa premium'u
  /// geri alır. Admin panelden bedava verilen premium'a dokunmaz — onlarda
  /// `premiumPlan` alanı olmaz, satın almalarda olur.
  static Future<void> syncWithFirestore(String uid) async {
    if (!isConfigured) return;
    final firestore = FirestoreService();
    final sub = await activeSubscription();

    if (sub != null) {
      await firestore.setUserPremium(uid, true, plan: sub.plan, until: sub.until);
      return;
    }

    // RevenueCat'te aktif abonelik yok — daha önce satın alma ile verilmiş bir
    // premium duruyorsa (plan alanı var) süresi dolmuş demektir, geri al.
    try {
      final status = await firestore.watchPremiumStatus(uid).first;
      if (status.isPremium && status.plan != null) {
        await firestore.revokeUserPremium(uid);
      }
    } catch (e) {
      if (kDebugMode) print('[Purchases] Firestore senkronu başarısız: $e');
    }
  }
}
