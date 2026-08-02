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

  /// Öncelikli hesaplar dışındaki tweetlerin gösterilmesi için gereken minimum
  /// görüntülenme/beğeni sayısı
  Future<int> getMinEngagementThreshold() async {
    final settings = await getSettings();
    return (settings['minEngagementThreshold'] as num?)?.toInt() ?? 500;
  }

  Future<void> setMinEngagementThreshold(int value) async {
    await _db.collection('config').doc('settings').set(
      {'minEngagementThreshold': value},
      SetOptions(merge: true),
    );
    _patchSettingsCache({'minEngagementThreshold': value});
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
}

class UsersPage {
  final List<Map<String, dynamic>> users;
  final DocumentSnapshot? lastDoc;
  final bool hasMore;

  UsersPage({required this.users, required this.lastDoc, required this.hasMore});
}
