import 'package:atlas/core/api/xquik_service.dart';
import 'package:atlas/core/services/firestore_service.dart';
import 'package:atlas/core/utils/engagement_filter.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';

class ExploreController extends GetxController {
  final XquikService _xquik = XquikService();
  final FirestoreService _firestore = FirestoreService();

  final trendTopics = <TrendTopic>[].obs;
  final popularTweets = <TweetModel>[].obs;
  final searchResults = <TweetModel>[].obs;

  final isLoadingTrends = false.obs;
  final isLoadingPopular = false.obs;
  final isLoadingMorePopular = false.obs;
  final hasMorePopular = true.obs;
  final isLoadingSearch = false.obs;

  final trendsError = ''.obs;
  final popularError = ''.obs;

  static const String _popularQuery =
      '(#Galatasaray OR #Fenerbahçe OR #Beşiktaş OR #SüperLig OR #transfer) lang:tr';
  String? _popularCursor;

  String _lastQuery = '';

  // Admin panelden yönetilen öncelikli hesaplar ve minimum etkileşim eşiği
  List<String> _priorityAccounts = [];
  int _minEngagementThreshold = 500;

  @override
  void onInit() {
    super.onInit();
    _loadEngagementSettings().then((_) => loadPopularTweets());
    loadTrends();
  }

  Future<void> _loadEngagementSettings() async {
    try {
      final results = await Future.wait([
        _firestore.getPriorityAccounts(),
        _firestore.getMinEngagementThreshold(),
      ]);
      _priorityAccounts = results[0] as List<String>;
      _minEngagementThreshold = results[1] as int;
    } catch (e) {
      if (kDebugMode) print('[ExploreController] etkileşim ayarları yüklenemedi: $e');
    }
  }

  Future<void> loadTrends() async {
    isLoadingTrends.value = true;
    trendsError.value = '';
    try {
      final trends = await _xquik.getTrends();
      trendTopics.assignAll(
          trends.isEmpty ? MockData.trendTopics : trends.take(8).toList());
    } catch (e) {
      trendsError.value = e.toString();
      trendTopics.assignAll(MockData.trendTopics);
    } finally {
      isLoadingTrends.value = false;
    }
  }

  int _score(TweetModel t) =>
      t.views > 0 ? t.views : (t.likes * 100 + t.retweets * 200);

  /// Bir sayfayı etkileşime göre sıralar. Eşiği geçenler önce gelir; sayı
  /// [_minPopularCount]'un altında kalırsa (ör. az tweet eşiği geçiyorsa)
  /// liste görsel olarak boş/yetersiz kalmasın diye ham sonuçtan en yüksek
  /// etkileşimli tweetlerle tamamlanır.
  static const int _minPopularCount = 10;
  List<TweetModel> _rankPopularPage(List<TweetModel> raw) {
    final filtered = filterByEngagement(
      raw,
      priorityAccounts: _priorityAccounts,
      minEngagementThreshold: _minEngagementThreshold,
    );
    if (filtered.length < _minPopularCount) {
      final seen = filtered.map((t) => t.id).toSet();
      final rest = raw.where((t) => seen.add(t.id)).toList()
        ..sort((a, b) => _score(b).compareTo(_score(a)));
      for (final t in rest) {
        if (filtered.length >= _minPopularCount) break;
        filtered.add(t);
      }
    }
    filtered.sort((a, b) => _score(b).compareTo(_score(a)));
    return filtered;
  }

  /// İlk sayfa: en az 20 popüler tweet çek, sonsuz kaydırma için imleci sıfırla.
  Future<void> loadPopularTweets() async {
    isLoadingPopular.value = true;
    popularError.value = '';
    _popularCursor = null;
    hasMorePopular.value = true;
    try {
      final res = await _xquik.searchTweetsPaged(customQuery: _popularQuery, limit: 20);
      popularTweets.assignAll(_rankPopularPage(res.tweets));
      _popularCursor = res.cursor;
      hasMorePopular.value = res.cursor != null && res.tweets.isNotEmpty;
    } catch (e) {
      popularError.value = e.toString();
      popularTweets.assignAll(MockData.homeFeed);
      hasMorePopular.value = false;
    } finally {
      isLoadingPopular.value = false;
    }
  }

  /// Kullanıcı listenin dibine geldiğinde çağrılır: sonraki 20 tweeti çekip
  /// mevcut listenin sonuna ekler. İmleç bittiğinde durur.
  Future<void> loadMorePopular() async {
    if (isLoadingMorePopular.value || isLoadingPopular.value) return;
    if (!hasMorePopular.value || _popularCursor == null) return;

    isLoadingMorePopular.value = true;
    try {
      final res = await _xquik.searchTweetsPaged(
        customQuery: _popularQuery,
        limit: 20,
        cursor: _popularCursor,
      );
      // Tekrar eden tweetleri ele (aynı id ikinci kez eklenmesin)
      final existing = popularTweets.map((t) => t.id).toSet();
      final fresh = res.tweets.where((t) => existing.add(t.id)).toList();
      popularTweets.addAll(_rankPopularPage(fresh));
      _popularCursor = res.cursor;
      hasMorePopular.value = res.cursor != null && fresh.isNotEmpty;
    } catch (e) {
      if (kDebugMode) print('[ExploreController] daha fazla popüler yüklenemedi: $e');
    } finally {
      isLoadingMorePopular.value = false;
    }
  }

  Future<void> search(String query) async {
    final q = query.trim();
    if (q == _lastQuery) return;
    _lastQuery = q;

    if (q.isEmpty) {
      searchResults.clear();
      return;
    }

    isLoadingSearch.value = true;
    try {
      final tweets = await _xquik.searchTweets(
        customQuery: '$q lang:tr',
        limit: 20,
      );
      searchResults.assignAll(tweets);
    } catch (_) {
      searchResults.assignAll(
        MockData.homeFeed
            .where((t) =>
                t.content.toLowerCase().contains(q.toLowerCase()) ||
                t.username.toLowerCase().contains(q.toLowerCase()))
            .toList(),
      );
    } finally {
      isLoadingSearch.value = false;
    }
  }

  @override
  Future<void> refresh() async {
    _lastQuery = '';
    searchResults.clear();
    await _loadEngagementSettings();
    await Future.wait([loadTrends(), loadPopularTweets()]);
  }
}
