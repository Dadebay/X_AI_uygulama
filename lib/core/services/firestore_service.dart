import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:atlas/models/tweet_model.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._();
  FirestoreService._();
  factory FirestoreService() => _instance;

  final _db = FirebaseFirestore.instance;

  Map<String, dynamic>? _settingsCache;

  /// `config/settings` dokümanını tek seferde okur ve cache'ler; aynı doküman
  /// için tekrarlanan network round-trip'leri önler.
  Future<Map<String, dynamic>> getSettings({bool forceRefresh = false}) async {
    if (!forceRefresh && _settingsCache != null) return _settingsCache!;
    try {
      final snap = await _db.collection('config').doc('settings').get();
      _settingsCache = snap.data() ?? {};
    } catch (_) {
      _settingsCache = {};
    }
    return _settingsCache!;
  }

  void _patchSettingsCache(Map<String, dynamic> patch) {
    _settingsCache = {...?_settingsCache, ...patch};
  }

  Future<Map<String, dynamic>?> getDocument(String collection, String docId) async {
    final snap = await _db.collection(collection).doc(docId).get();
    return snap.exists ? snap.data() : null;
  }

  /// Firestore `teams` koleksiyonundan takımları çeker.
  Future<List<TeamModel>> getTeams() async {
    final snap = await _db.collection('teams').orderBy('order').get();
    return snap.docs.map((doc) {
      final d = doc.data();
      final rawColors = (d['colors'] as List<dynamic>?) ?? [];
      final colors = rawColors.map((c) => _hexToColor(c.toString())).whereType<Color>().toList();
      final rawAccounts = (d['twitterAccounts'] as List<dynamic>?) ?? [];
      final twitterAccounts = rawAccounts.map((a) => a.toString()).toList();
      return TeamModel(
        id: doc.id,
        name: d['name']?.toString() ?? '',
        shortName: d['shortName']?.toString() ?? '',
        logoUrl: d['logoUrl']?.toString() ?? '',
        followers: (d['followers'] as num?)?.toInt() ?? 0,
        league: d['league']?.toString() ?? '',
        colors: colors,
        twitterAccounts: twitterAccounts,
        searchQuery: d['searchQuery']?.toString() ?? '',
        order: (d['order'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  Future<void> addTeam(Map<String, dynamic> data) async {
    await _db.collection('teams').add(data);
  }

  Future<void> updateTeam(String id, Map<String, dynamic> data) async {
    await _db.collection('teams').doc(id).update(data);
  }

  Future<void> deleteTeam(String id) async {
    await _db.collection('teams').doc(id).delete();
  }

  Future<String> getAdminPin() async {
    final settings = await getSettings();
    return settings['adminPin']?.toString() ?? '2024';
  }

  /// Ana sayfada tüm günlük tweetleri filtresiz gösterilecek öncelikli hesaplar
  Future<List<String>> getPriorityAccounts() async {
    final settings = await getSettings();
    final raw = (settings['priorityAccounts'] as List<dynamic>?) ?? [];
    return raw.map((a) => a.toString()).toList();
  }

  Future<void> setPriorityAccounts(List<String> accounts) async {
    await _db.collection('config').doc('settings').set(
      {'priorityAccounts': accounts},
      SetOptions(merge: true),
    );
    _patchSettingsCache({'priorityAccounts': accounts});
  }

  /// Öncelikli hesaplar dışındaki tweetlerin Xquik'ten çekilebilmesi için
  /// gereken minimum etkileşim eşikleri. Bunlar Xquik'in `/x/tweets/search`
  /// endpoint'inin gerçek query parametreleridir (minFaves/minRetweets/
  /// minReplies/minQuotes) — filtre API seviyesinde uygulanır.
  Future<EngagementThresholds> getEngagementThresholds() async {
    final settings = await getSettings();
    return EngagementThresholds(
      minFaves: (settings['minFaves'] as num?)?.toInt() ?? 500,
      minRetweets: (settings['minRetweets'] as num?)?.toInt() ?? 0,
      minReplies: (settings['minReplies'] as num?)?.toInt() ?? 0,
      minQuotes: (settings['minQuotes'] as num?)?.toInt() ?? 0,
      minViews: (settings['minViews'] as num?)?.toInt() ?? 0,
    );
  }

  Future<void> setEngagementThresholds(EngagementThresholds thresholds) async {
    final data = {
      'minFaves': thresholds.minFaves,
      'minRetweets': thresholds.minRetweets,
      'minReplies': thresholds.minReplies,
      'minQuotes': thresholds.minQuotes,
      'minViews': thresholds.minViews,
    };
    await _db.collection('config').doc('settings').set(data, SetOptions(merge: true));
    _patchSettingsCache(data);
  }

  /// Reklamların uygulama genelinde açık/kapalı olduğunu kontrol eden bayrak
  Future<bool> getAdsEnabled() async {
    final settings = await getSettings();
    return settings['adsEnabled'] as bool? ?? true;
  }

  Future<void> setAdsEnabled(bool value) async {
    await _db.collection('config').doc('settings').set(
      {'adsEnabled': value},
      SetOptions(merge: true),
    );
    _patchSettingsCache({'adsEnabled': value});
  }

  /// Admin panelden reklam ayarı değiştiğinde açık uygulamalara anında yansıması için canlı akış
  Stream<bool> watchAdsEnabled() {
    return _db.collection('config').doc('settings').snapshots().map(
      (snap) => snap.data()?['adsEnabled'] as bool? ?? true,
    );
  }

  Future<List<Map<String, dynamic>>> getUsers({int limit = 100}) async {
    final snap = await _db.collection('users').orderBy('createdAt', descending: true).limit(limit).get();
    return snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  /// Cursor tabanlı sayfalama ile kullanıcı listesi çeker. `startAfter` verilirse
  /// önceki sayfanın son dokümanından devam eder.
  Future<UsersPage> getUsersPage({int limit = 25, DocumentSnapshot? startAfter}) async {
    var q = _db.collection('users').orderBy('createdAt', descending: true).limit(limit);
    if (startAfter != null) q = q.startAfterDocument(startAfter);
    final snap = await q.get();
    return UsersPage(
      users: snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList(),
      lastDoc: snap.docs.isEmpty ? null : snap.docs.last,
      hasMore: snap.docs.length == limit,
    );
  }

  Future<int> getUsersCount() async {
    final snap = await _db.collection('users').count().get();
    return snap.count ?? 0;
  }

  Future<int> getTeamsCount() async {
    final snap = await _db.collection('teams').count().get();
    return snap.count ?? 0;
  }

  Color? _hexToColor(String hex) {
    try {
      final h = hex.replaceAll('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return null;
    }
  }

  // ─── Premium fiyatlandırma (prices/premium) ──────────────────────────────
  // Admin panelden yönetilir; uygulama tarafında PremiumScreen bu değerleri
  // gösterir. Ayrı bir koleksiyonda tutuluyor çünkü config/settings PIN'le
  // korunan admin ayarları içeriyor, fiyatlar ise doğrudan uygulamadan da
  // (watchPremiumPricing ile) canlı okunuyor.
  PremiumPricing _parsePremiumPricing(Map<String, dynamic> d) => PremiumPricing(
        monthlyPrice: (d['monthlyPrice'] as num?)?.toDouble() ?? 49.99,
        yearlyPrice: (d['yearlyPrice'] as num?)?.toDouble() ?? 399.99,
        yearlyDiscountLabel: d['yearlyDiscountLabel']?.toString() ?? '%33 indirim!',
        currency: d['currency']?.toString() ?? '₺',
      );

  Future<PremiumPricing> getPremiumPricing() async {
    try {
      final snap = await _db.collection('prices').doc('premium').get();
      return _parsePremiumPricing(snap.data() ?? {});
    } catch (_) {
      return _parsePremiumPricing(const {});
    }
  }

  Future<void> setPremiumPricing(PremiumPricing pricing) async {
    await _db.collection('prices').doc('premium').set({
      'monthlyPrice': pricing.monthlyPrice,
      'yearlyPrice': pricing.yearlyPrice,
      'yearlyDiscountLabel': pricing.yearlyDiscountLabel,
      'currency': pricing.currency,
    }, SetOptions(merge: true));
  }

  /// Admin panelden fiyat değiştiğinde açık uygulamalara anında yansıması için canlı akış
  Stream<PremiumPricing> watchPremiumPricing() {
    return _db.collection('prices').doc('premium').snapshots().map(
          (snap) => _parsePremiumPricing(snap.data() ?? {}),
        );
  }

  // ─── Kullanıcı premium durumu ────────────────────────────────────────────
  Future<void> setUserPremium(String uid, bool isPremium, {String? plan, DateTime? until}) async {
    final data = <String, dynamic>{'isPremium': isPremium};
    if (isPremium) {
      data['premiumSince'] = FieldValue.serverTimestamp();
      if (plan != null) data['premiumPlan'] = plan;
      if (until != null) data['premiumUntil'] = Timestamp.fromDate(until);
    }
    await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
  }

  /// Abonelik süresi dolduğunda premium'u geri alır — plan/bitiş alanlarını da
  /// temizler ki ekranda eski plandan kalma bilgi görünmesin.
  Future<void> revokeUserPremium(String uid) async {
    await _db.collection('users').doc(uid).set({
      'isPremium': false,
      'premiumPlan': FieldValue.delete(),
      'premiumUntil': FieldValue.delete(),
    }, SetOptions(merge: true));
  }

  /// Kullanıcının premium durumunu canlı izler — satın alma/admin tarafından
  /// bedava verme işlemi anında uygulamaya yansır.
  Stream<bool> watchUserPremium(String uid) {
    return _db.collection('users').doc(uid).snapshots().map(
          (snap) => snap.data()?['isPremium'] as bool? ?? false,
        );
  }

  /// Premium ekranında hangi planın alındığını ve ne zaman biteceğini
  /// göstermek için plan + bitiş tarihini de içeren canlı akış.
  Stream<PremiumStatus> watchPremiumStatus(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      final d = snap.data();
      final until = d?['premiumUntil'];
      return PremiumStatus(
        isPremium: d?['isPremium'] as bool? ?? false,
        plan: d?['premiumPlan'] as String?,
        until: until is Timestamp ? until.toDate() : null,
      );
    });
  }
}

class PremiumStatus {
  final bool isPremium;
  final String? plan;
  final DateTime? until;

  const PremiumStatus({required this.isPremium, this.plan, this.until});
}

class UsersPage {
  final List<Map<String, dynamic>> users;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;

  UsersPage({required this.users, required this.lastDoc, required this.hasMore});
}

/// `prices/premium` dokümanındaki Premium abonelik fiyatlandırması.
class PremiumPricing {
  final double monthlyPrice;
  final double yearlyPrice;
  final String yearlyDiscountLabel;
  final String currency;

  const PremiumPricing({
    required this.monthlyPrice,
    required this.yearlyPrice,
    required this.yearlyDiscountLabel,
    required this.currency,
  });

  String get formattedMonthly => '$currency${monthlyPrice.toStringAsFixed(2).replaceAll('.', ',')}';
  String get formattedYearly => '$currency${yearlyPrice.toStringAsFixed(2).replaceAll('.', ',')}';
}

/// Xquik `/x/tweets/search` API'sinin gerçek etkileşim filtresi parametreleri.
class EngagementThresholds {
  final int minFaves;
  final int minRetweets;
  final int minReplies;
  final int minQuotes;
  final int minViews;

  const EngagementThresholds({
    required this.minFaves,
    required this.minRetweets,
    required this.minReplies,
    required this.minQuotes,
    required this.minViews,
  });
}
