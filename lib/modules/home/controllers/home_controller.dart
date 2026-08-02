import 'dart:async';
import 'dart:convert';

import 'package:atlas/core/api/xquik_service.dart';
import 'package:atlas/core/services/firestore_service.dart';
import 'package:atlas/core/utils/engagement_filter.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class HomeController extends GetxController {
  final XquikService _xquik = XquikService();
  final FirestoreService _firestore = FirestoreService();
  final GetStorage _storage = GetStorage();

  // Ana sayfa akışı önbelleği: açılışta kayıtlı feed anında gösterilir,
  // arka planda tazelenir. Böylece her açılışta ~22 istek atılmaz.
  static const String _feedCacheKey = 'home_feed_cache_v1';
  static const String _feedCacheTimeKey = 'home_feed_cache_time_v1';
  static const Duration _feedCacheTtl = Duration(minutes: 10);

  final feedTweets = <TweetModel>[].obs;
  final trendingTweets = <TweetModel>[].obs;
  final trendTopics = <TrendTopic>[].obs;
  final transferTweets = <TweetModel>[].obs;
  final teamTweets = <TweetModel>[].obs;

  final isLoadingFeed = false.obs;
  final isLoadingTrending = false.obs;
  final isLoadingTrends = false.obs;
  final isLoadingTransfer = false.obs;
  final isLoadingTeam = false.obs;
  final isLoadingTeams = false.obs;

  final feedError = ''.obs;
  final trendingError = ''.obs;
  final trendsError = ''.obs;
  final transferError = ''.obs;
  final teamError = ''.obs;

  final searchResults = <TweetModel>[].obs;
  final isLoadingSearch = false.obs;

  // Firebase'den gelen dinamik takımlar
  final dynamicTeams = <TeamModel>[].obs;

  // Admin panelden yönetilen, takımlardan bağımsız öncelikli hesaplar listesi
  final priorityAccounts = <String>[].obs;
  int _minEngagementThreshold = 500;

  String? _feedCursor;
  final hasMoreFeed = true.obs;
  int _feedRequestToken = 0;

  // Ana sayfa (Tümü) akışı: öncelikli hesaplar → gündem → genel, sadece ilk sayfada birleştirilir
  bool _mainFeedLoaded = false;
  bool _feedHasContent = false;

  // Kategori (Tümü/GS/FB/BJK/...) bazlı bellek önbelleği: bir kategoriye tekrar
  // dönüldüğünde veriler state'ten anında gösterilir, yeniden çekilmez.
  // Yalnızca aşağı çekip yenileme (pull-to-refresh) veriyi tazeler.
  String _currentCategory = '';
  final Map<String, _CategoryFeed> _categoryCache = {};

  final selectedTeam = 0.obs;

  // Sekmeler tembel yüklenir: açılışta sadece görünen "Sana Özel" sekmesi
  // yüklenir; diğerleri kullanıcı o sekmeye geçtiğinde bir kez yüklenir.
  // Böylece açılışta API'ye onlarca eşzamanlı istek gitmez ve her sekme hızlanır.
  bool _trendingRequested = false;
  bool _transferRequested = false;
  bool _teamsRequested = false;

  @override
  void onInit() {
    super.onInit();
    _initMainFeed();
  }

  void ensureTrendingLoaded() {
    if (_trendingRequested) return;
    _trendingRequested = true;
    loadTrending();
    loadTrends();
  }

  void ensureTransferLoaded() {
    if (_transferRequested) return;
    _transferRequested = true;
    loadTransfer();
  }

  void ensureTeamsLoaded() {
    if (_teamsRequested) return;
    _teamsRequested = true;
    loadTeamsFromFirebase();
  }

  /// Öncelikli hesaplar ve eşik değeri önce yüklenir ki ana sayfa akışı bunları kullanabilsin
  Future<void> _initMainFeed() async {
    // 1) Kayıtlı feed varsa anında göster (açılış hızlansın, boş ekran olmasın)
    final cached = _readFeedCache();
    final hasCache = cached != null && cached.isNotEmpty;
    if (hasCache) {
      feedTweets.assignAll(cached);
      _feedHasContent = true;
    }

    // 2) Cache hem taze hem dolu ise ağ isteği hiç atma
    if (hasCache && _isFeedCacheFresh()) {
      _mainFeedLoaded = true;
      // "Tümü" kategorisini bellek önbelleğine de koy ki kategori değişip
      // geri dönüldüğünde yeniden çekilmesin.
      _categoryCache[''] = _CategoryFeed(
        tweets: List<TweetModel>.from(feedTweets),
        cursor: null,
        hasMore: true,
      );
      // Ayarları yine de sessizce güncelle (diğer sekmeler/filtreler için)
      unawaited(Future.wait([_loadPrioritySettings(), _loadEngagementThreshold()]));
      // Sana Özel hazır; diğer sekmeleri arka planda sırayla ısıt
      unawaited(_preloadSecondaryTabs());
      return;
    }

    await Future.wait([_loadPrioritySettings(), _loadEngagementThreshold()]);
    // Cache'ten içerik gösterdiysek arka planda sessiz yenile (loading gösterme)
    await loadFeed(silent: hasCache);

    // 3) Sana Özel yüklendikten SONRA diğer sekmeleri istenen öncelik sırasıyla
    // (Gündem → Takımlar → Transfer) arka planda sırayla ön yükle. Böylece
    // kullanıcı sekmeye geçtiğinde veri hazır olur; Sana Özel'in hızını da
    // yavaşlatmaz çünkü ancak o bittikten sonra başlar.
    unawaited(_preloadSecondaryTabs());
  }

  /// Sana Özel dışındaki sekmeleri istenen öncelik sırasıyla arka planda,
  /// birbirini bekleyerek (sıralı) yükler — hepsi aynı anda gidip API'yi
  /// boğmasın diye.
  Future<void> _preloadSecondaryTabs() async {
    if (!_trendingRequested) {
      _trendingRequested = true;
      await loadTrending();
      await loadTrends();
    }
    if (!_teamsRequested) {
      _teamsRequested = true;
      await loadTeamsFromFirebase();
    }
    if (!_transferRequested) {
      _transferRequested = true;
      await loadTransfer();
    }
  }

  List<TweetModel>? _readFeedCache() {
    try {
      final raw = _storage.read(_feedCacheKey);
      if (raw is! String || raw.isEmpty) return null;
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => TweetModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (e) {
      if (kDebugMode) print('[HomeController] feed cache okunamadı: $e');
      return null;
    }
  }

  bool _isFeedCacheFresh() {
    final ts = _storage.read(_feedCacheTimeKey);
    if (ts is! int) return false;
    final saved = DateTime.fromMillisecondsSinceEpoch(ts);
    return DateTime.now().difference(saved) < _feedCacheTtl;
  }

  void _writeFeedCache(List<TweetModel> tweets) {
    try {
      _storage.write(_feedCacheKey, jsonEncode(tweets.map((t) => t.toJson()).toList()));
      _storage.write(_feedCacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      if (kDebugMode) print('[HomeController] feed cache yazılamadı: $e');
    }
  }

  Future<void> _loadPrioritySettings() async {
    try {
      final accounts = await _firestore.getPriorityAccounts();
      priorityAccounts.assignAll(accounts);
    } catch (e) {
      if (kDebugMode) {
        print('[HomeController] öncelikli hesaplar yüklenemedi: $e');
      }
    }
  }

  Future<void> _loadEngagementThreshold() async {
    try {
      _minEngagementThreshold = await _firestore.getMinEngagementThreshold();
    } catch (e) {
      if (kDebugMode) print('[HomeController] etkileşim eşiği yüklenemedi: $e');
    }
  }

  Future<void> loadTeamsFromFirebase() async {
    isLoadingTeams.value = true;
    try {
      final teams = await _firestore.getTeams();
      dynamicTeams.assignAll(teams);
      if (teams.isNotEmpty) {
        await loadTeam(0);
      }
    } catch (e) {
      // Firebase'e erişilemezse boş bırak
      if (kDebugMode) {
        print('[HomeController] takımlar Firebase\'den yüklenemedi: $e');
      }
    } finally {
      isLoadingTeams.value = false;
    }
  }

  /// dynamicTeams boşsa Firebase'den takımları (yan etkisiz) yükler.
  Future<void> _ensureTeams() async {
    if (dynamicTeams.isNotEmpty) return;
    try {
      dynamicTeams.assignAll(await _firestore.getTeams());
    } catch (e) {
      if (kDebugMode) print('[HomeController] _ensureTeams başarısız: $e');
    }
  }

  /// Bir kategori etiketine (GS/FB/BJK...) karşılık gelen takımı bulur.
  TeamModel? _teamForTag(String tag) {
    for (final t in dynamicTeams) {
      if (t.shortName.toLowerCase() == tag.toLowerCase()) return t;
    }
    return null;
  }

  /// Bir kategori chip'inin ilk sayfasını oluşturur:
  /// 1) Takımın resmi hesaplarından popüler tweetler (eşikten muaf — Takımlar
  ///    sekmesindeki gibi dolu içerik).
  /// 2) Hashtag araması (etkileşim filtreli; hepsi eşiğin altındaysa ham sonuçlar
  ///    etkileşime göre sıralı). Load-more için cursor da döndürülür.
  Future<({List<TweetModel> tweets, String? cursor})> _buildCategoryFeed(
      String tag) async {
    await _ensureTeams();
    final team = _teamForTag(tag);
    final result = <TweetModel>[];
    final seen = <String>{};

    if (team != null && team.twitterAccounts.isNotEmpty) {
      try {
        final accountTweets = await _xquik.getPopularTweetsForAccounts(
          team.twitterAccounts,
          perAccount: 10,
          limit: 20,
        );
        for (final t in accountTweets) {
          if (seen.add(t.id)) result.add(t);
        }
      } catch (e) {
        if (kDebugMode) print('[HomeController] takım hesap akışı çekilemedi: $e');
      }
    }

    String? cursor;
    try {
      final res = await _xquik.searchTweetsPaged(
        category: tag,
        customQuery: (team != null && team.searchQuery.isNotEmpty)
            ? team.searchQuery
            : null,
        limit: 20,
      );
      cursor = res.cursor;
      var searchTweets = _applyEngagementFilter(res.tweets);
      if (searchTweets.isEmpty && res.tweets.isNotEmpty) {
        searchTweets = List<TweetModel>.from(res.tweets)
          ..sort((a, b) => _engagementScore(b).compareTo(_engagementScore(a)));
      }
      for (final t in searchTweets) {
        if (seen.add(t.id)) result.add(t);
      }
    } catch (e) {
      if (kDebugMode) print('[HomeController] kategori araması çekilemedi: $e');
    }

    return (tweets: result, cursor: cursor);
  }

  Future<void> loadFeed(
      {String category = '', String? customQuery, bool refresh = false, bool silent = false}) async {
    final isMainFeed = category.isEmpty && customQuery == null;

    if (refresh) {
      _feedCursor = null;
      hasMoreFeed.value = true;
      _feedHasContent = false;
      if (isMainFeed) _mainFeedLoaded = false;
    }
    // "Daha fazla yükle" sayfalaması sırasında zaten devam eden bir istek varsa
    // tekrar tetiklenmesin; ama kategori değişimi/refresh her zaman en son
    // seçilen kategoriyi göstermeli, önceki isteği iptal etmek yerine ona
    // öncelik verilir (aşağıdaki requestToken kontrolü eski sonucun üzerine
    // yazmasını engeller).
    if (isLoadingFeed.value && !refresh) return;

    final requestToken = ++_feedRequestToken;
    // silent: elimizde cache içeriği var, arka planda tazeliyoruz — yükleme
    // göstergesi gösterme ki ekran titremesin.
    if (!silent) isLoadingFeed.value = true;
    feedError.value = '';
    try {
      if (isMainFeed && !_mainFeedLoaded) {
        // İlk sayfa: öncelikli hesaplar → gündem → genel akış birleştirilir
        final tweets = await _buildPriorityFeed();
        if (requestToken != _feedRequestToken) return;
        feedTweets.assignAll(tweets);
        _writeFeedCache(tweets);
        hasMoreFeed.value = true;
        _mainFeedLoaded = true;
        _feedHasContent = true;
      } else if (category.isNotEmpty && customQuery == null && !_feedHasContent) {
        // Kategori chip'i ilk sayfası: takımın resmi hesapları + hashtag araması
        final built = await _buildCategoryFeed(category);
        if (requestToken != _feedRequestToken) return;
        feedTweets.assignAll(built.tweets);
        _feedCursor = built.cursor;
        _feedHasContent = true;
        hasMoreFeed.value = built.cursor != null;
      } else {
        // Cursor'lı sayfalama: her "daha fazla" isteği gerçekten sonraki sayfayı
        // çeker. Eskiden cursor güncellenmediği için aynı tweetler tekrar geliyordu.
        final res = await _xquik.searchTweetsPaged(
          category: category,
          customQuery: customQuery,
          cursor: refresh ? null : _feedCursor,
        );
        if (requestToken != _feedRequestToken) return;
        var tweets = _applyEngagementFilter(res.tweets);
        // Kategori chip'lerinde (GS/FB/BJK/Süper Lig...) hashtag araması düşük
        // etkileşimli tweetler döndürebilir; eşik filtresi hepsini eleyince
        // "içerik bulunamadı" görünüyordu. Boş bırakmak yerine ham sonuçları
        // etkileşime göre sıralayıp göster (Takımlar sekmesindeki gibi dolu gelsin).
        if (category.isNotEmpty && tweets.isEmpty && res.tweets.isNotEmpty) {
          tweets = List<TweetModel>.from(res.tweets)
            ..sort((a, b) => _engagementScore(b).compareTo(_engagementScore(a)));
        }
        // Zaten listede olan tweetleri ele (aynı tweet iki kez görünmesin)
        final existing = feedTweets.map((t) => t.id).toSet();
        final fresh = tweets.where((t) => existing.add(t.id)).toList();
        if (!_feedHasContent) {
          feedTweets.assignAll(tweets);
        } else {
          feedTweets.addAll(fresh);
        }
        _feedCursor = res.cursor;
        _feedHasContent = true;
        // İmleç yoksa ya da bu sayfada yeni içerik gelmediyse dur (sonsuz
        // tekrar döngüsünü önler).
        hasMoreFeed.value = res.cursor != null && fresh.isNotEmpty;
      }
      // Kategori feed'ini bellek önbelleğine al ki sekmeye/kategoriye geri
      // dönüldüğünde yeniden çekilmesin (sadece pull-to-refresh tazeler).
      if (customQuery == null) {
        _categoryCache[category] = _CategoryFeed(
          tweets: List<TweetModel>.from(feedTweets),
          cursor: _feedCursor,
          hasMore: hasMoreFeed.value,
        );
      }
    } catch (e) {
      if (requestToken == _feedRequestToken) {
        feedError.value = e.toString();
        if (kDebugMode) print('[HomeController] feed yüklenemedi: $e');
      }
    } finally {
      if (requestToken == _feedRequestToken) {
        isLoadingFeed.value = false;
      }
    }
  }

  /// Ana sayfa akışını iki gruptan harmanlayarak oluşturur:
  /// - Öncelikli grup: Admin panelde tanımlı hesapların günlük tweetleri (filtresiz)
  /// - Diğer grup: Gündem + genel akıştan yalnızca minimum etkileşim eşiğini geçen
  ///   (dikkat çekici) tweetler, etkileşime göre azalan sıralı
  /// Sonra her [_priorityPerOther] öncelikli tweete 1 dikkat çekici "diğer" tweet
  /// gelecek şekilde iç içe geçirilir; böylece yüksek etkileşimliler başa yakın
  /// görünür ama öncelikli hesaplar da bolca yer alır.
  /// Aynı tweet birden fazla kaynakta çıkarsa yalnızca ilk gördüğü yerde kalır.
  Future<List<TweetModel>> _buildPriorityFeed() async {
    final seen = <String>{};
    final priorityTweets = <TweetModel>[];
    final otherTweets = <TweetModel>[];

    void collect(List<TweetModel> target, List<TweetModel> tweets,
        {bool filter = false}) {
      for (final t in tweets) {
        if (filter && !_passesEngagementThreshold(t)) continue;
        if (seen.add(t.id)) target.add(t);
      }
    }

    if (priorityAccounts.isNotEmpty) {
      try {
        // Öncelikli hesapların tüm günlük tweetleri — filtre uygulanmaz.
        // Round-robin ile en yeni tweetler alındığı ve toplam 60 tweet
        // gösterildiği için hesap başına 10 yeterli; indirilen veri ~3 kat azalır.
        collect(priorityTweets,
            await _xquik.getLatestTweetsForAccounts(priorityAccounts, perAccount: 10, limit: 60));
      } catch (e) {
        if (kDebugMode) {
          print('[HomeController] öncelikli hesap akışı çekilemedi: $e');
        }
      }
    }

    try {
      collect(
        otherTweets,
        await _xquik.searchTweets(
          customQuery:
              '(#Galatasaray OR #Fenerbahçe OR #Beşiktaş OR #SüperLig) lang:tr',
          limit: 30,
        ),
        filter: true,
      );
    } catch (e) {
      if (kDebugMode) print('[HomeController] gündem akışı çekilemedi: $e');
    }

    try {
      collect(otherTweets, await _xquik.searchTweets(category: '', limit: 30),
          filter: true);
    } catch (e) {
      if (kDebugMode) print('[HomeController] genel akış çekilemedi: $e');
    }

    // Dikkat çekici "diğer" tweetleri etkileşime göre azalan sırala
    otherTweets.sort((a, b) => _engagementScore(b).compareTo(_engagementScore(a)));

    final result = _interleaveFeeds(priorityTweets, otherTweets);
    if (kDebugMode) {
      print('[HomeController] _buildPriorityFeed: '
          '${priorityTweets.length} öncelikli + ${otherTweets.length} dikkat çekici = ${result.length} tweet');
    }
    return result;
  }

  /// Öncelikli tweetler ile dikkat çekici diğer tweetleri harmanlar:
  /// her [_priorityPerOther] öncelikli tweetin ardına 1 "diğer" tweet ekler.
  /// Biri bitince kalanı sona eklenir.
  static const int _priorityPerOther = 2;
  List<TweetModel> _interleaveFeeds(
      List<TweetModel> priority, List<TweetModel> other) {
    final result = <TweetModel>[];
    var pi = 0;
    var oi = 0;
    while (pi < priority.length || oi < other.length) {
      for (var k = 0; k < _priorityPerOther && pi < priority.length; k++) {
        result.add(priority[pi++]);
      }
      if (oi < other.length) result.add(other[oi++]);
    }
    return result;
  }

  int _engagementScore(TweetModel t) =>
      t.views > 0 ? t.views : (t.likes * 100 + t.retweets * 200);

  /// Öncelikli hesaplar dışındaki tweetlerin gösterilebilmesi için gereken
  /// minimum görüntülenme (yoksa beğeni) sayısı kontrolü
  bool _passesEngagementThreshold(TweetModel t) {
    if (t.views >= _minEngagementThreshold) return true;
    if (t.views == 0 && t.likes >= _minEngagementThreshold) return true;
    return false;
  }

  /// Diğer tüm sekmeler (Gündem, Transfer, Takımlar, ana akışın sonraki
  /// sayfaları) için ortak eşik filtresi — bkz. [filterByEngagement].
  List<TweetModel> _applyEngagementFilter(List<TweetModel> tweets,
      {List<String> extraExempt = const []}) {
    return filterByEngagement(
      tweets,
      priorityAccounts: priorityAccounts,
      minEngagementThreshold: _minEngagementThreshold,
      extraExempt: extraExempt,
    );
  }

  Future<void> loadTrending() async {
    isLoadingTrending.value = true;
    trendingError.value = '';
    try {
      final tweets = await _xquik.searchTweets(
        customQuery:
            '(#Galatasaray OR #Fenerbahçe OR #Beşiktaş OR #SüperLig) lang:tr',
        limit: 15,
      );
      final filtered = _applyEngagementFilter(tweets);
      // "Popüler Gündemler" başlığıyla tutarlı olması için en çok görüntülenen
      // (yoksa en çok beğenilen) tweet en üstte gösterilir.
      filtered.sort((a, b) {
        final aScore =
            a.views > 0 ? a.views : (a.likes * 100 + a.retweets * 200);
        final bScore =
            b.views > 0 ? b.views : (b.likes * 100 + b.retweets * 200);
        return bScore.compareTo(aScore);
      });
      trendingTweets.assignAll(filtered);
    } catch (e) {
      trendingError.value = e.toString();
      if (kDebugMode) print('[HomeController] gündem tab yüklenemedi: $e');
    } finally {
      isLoadingTrending.value = false;
    }
  }

  Future<void> loadTrends() async {
    isLoadingTrends.value = true;
    trendsError.value = '';
    try {
      final trends = await _xquik.getTrends();
      // Futbol filtresi sonrası liste boş kalırsa sekme boş görünmesin.
      trendTopics.assignAll(
          trends.isEmpty ? MockData.trendTopics : trends.take(10).toList());
    } catch (e) {
      trendsError.value = e.toString();
      trendTopics.assignAll(MockData.trendTopics);
      if (kDebugMode) print('[HomeController] trendler yüklenemedi: $e');
    } finally {
      isLoadingTrends.value = false;
    }
  }

  Future<void> loadTransfer() async {
    isLoadingTransfer.value = true;
    transferError.value = '';
    try {
      final tweets = await _xquik.searchTweets(
        customQuery: '#transfer OR #transferhaberleri OR "bonservis" lang:tr',
        limit: 20,
      );
      transferTweets.assignAll(_applyEngagementFilter(tweets));
    } catch (e) {
      transferError.value = e.toString();
      if (kDebugMode) print('[HomeController] transfer tab yüklenemedi: $e');
    } finally {
      isLoadingTransfer.value = false;
    }
  }

  Future<void> loadTeam(int index) async {
    if (index < 0 || index >= dynamicTeams.length) return;
    selectedTeam.value = index;
    isLoadingTeam.value = true;
    teamError.value = '';
    teamTweets.clear();
    try {
      final team = dynamicTeams[index];
      List<TweetModel> tweets;
      if (team.twitterAccounts.isNotEmpty) {
        tweets = await _xquik.getPopularTweetsForAccounts(team.twitterAccounts);
        // Takımın kendi resmi hesapları bu sekmenin tüm amacı olduğu için eşikten muaf
        tweets =
            _applyEngagementFilter(tweets, extraExempt: team.twitterAccounts);
      } else if (team.searchQuery.isNotEmpty) {
        tweets =
            await _xquik.searchTweets(customQuery: team.searchQuery, limit: 20);
        tweets = _applyEngagementFilter(tweets);
      } else {
        tweets = [];
      }
      teamTweets.assignAll(tweets);
    } catch (e) {
      teamError.value = e.toString();
      if (kDebugMode) print('[HomeController] takım tweetleri yüklenemedi: $e');
    } finally {
      isLoadingTeam.value = false;
    }
  }

  Future<void> search(String query) async {
    final q = query.trim();
    if (q.isEmpty) {
      searchResults.clear();
      return;
    }
    isLoadingSearch.value = true;
    searchResults.clear();
    try {
      final tweets =
          await _xquik.searchTweets(customQuery: '$q lang:tr', limit: 20);
      searchResults.assignAll(tweets);
    } catch (e) {
      searchResults.clear();
      if (kDebugMode) print('[HomeController] arama başarısız (q="$q"): $e');
    } finally {
      isLoadingSearch.value = false;
    }
  }

  void onCategorySelected(int index, String tag) {
    _currentCategory = tag;
    feedError.value = '';

    // Bu kategori daha önce yüklendiyse state'ten anında göster — yeniden çekme.
    final cached = _categoryCache[tag];
    if (cached != null) {
      feedTweets.assignAll(cached.tweets);
      _feedCursor = cached.cursor;
      hasMoreFeed.value = cached.hasMore;
      _feedHasContent = cached.tweets.isNotEmpty;
      if (tag.isEmpty) _mainFeedLoaded = true;
      // Devam eden bir arka plan isteği bu kategoriye yazmasın diye token'ı ilerlet
      _feedRequestToken++;
      isLoadingFeed.value = false;
      return;
    }

    // İlk kez açılıyor: eski tweetleri temizle, shimmer göster ve çek.
    feedTweets.clear();
    _feedHasContent = false;
    if (tag.isEmpty) _mainFeedLoaded = false;
    loadFeed(category: tag, refresh: true);
  }

  /// Pull-to-refresh: o an seçili olan kategoriyi tazeler ve önbelleğini günceller.
  Future<void> refreshAll() async {
    await Future.wait([_loadPrioritySettings(), _loadEngagementThreshold()]);
    _categoryCache.remove(_currentCategory);
    if (_currentCategory.isEmpty) _mainFeedLoaded = false;
    await loadFeed(category: _currentCategory, refresh: true);
  }

  Future<void> reloadTeams() async {
    await loadTeamsFromFirebase();
  }
}

/// Bir kategorinin bellek önbelleği: tweetler + sayfalama imleci + devam durumu.
class _CategoryFeed {
  final List<TweetModel> tweets;
  final String? cursor;
  final bool hasMore;

  _CategoryFeed({
    required this.tweets,
    required this.cursor,
    required this.hasMore,
  });
}
