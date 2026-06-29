import 'package:atlas/core/api/xquik_service.dart';
import 'package:atlas/core/services/firestore_service.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final XquikService _xquik = XquikService();
  final FirestoreService _firestore = FirestoreService();

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

  String? _feedCursor;
  final hasMoreFeed = true.obs;

  final selectedTeam = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadFeed();
    loadTrending();
    loadTrends();
    loadTransfer();
    loadTeamsFromFirebase();
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
    } finally {
      isLoadingTeams.value = false;
    }
  }

  Future<void> loadFeed({String category = '', String? customQuery, bool refresh = false}) async {
    if (refresh) {
      _feedCursor = null;
      hasMoreFeed.value = true;
    }
    if (isLoadingFeed.value) return;

    isLoadingFeed.value = true;
    feedError.value = '';
    try {
      final tweets = await _xquik.searchTweets(
        category: category,
        customQuery: customQuery,
        cursor: refresh ? null : _feedCursor,
      );
      if (refresh || _feedCursor == null) {
        feedTweets.assignAll(tweets);
      } else {
        feedTweets.addAll(tweets);
      }
      hasMoreFeed.value = tweets.isNotEmpty;
    } catch (e) {
      feedError.value = e.toString();
    } finally {
      isLoadingFeed.value = false;
    }
  }

  Future<void> loadTrending() async {
    isLoadingTrending.value = true;
    trendingError.value = '';
    try {
      final tweets = await _xquik.searchTweets(
        customQuery: '(#Galatasaray OR #Fenerbahçe OR #Beşiktaş OR #SüperLig) lang:tr',
        limit: 15,
      );
      trendingTweets.assignAll(tweets);
    } catch (e) {
      trendingError.value = e.toString();
    } finally {
      isLoadingTrending.value = false;
    }
  }

  Future<void> loadTrends() async {
    isLoadingTrends.value = true;
    trendsError.value = '';
    try {
      final trends = await _xquik.getTrends();
      trendTopics.assignAll(trends.take(10).toList());
    } catch (e) {
      trendsError.value = e.toString();
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
      transferTweets.assignAll(tweets);
    } catch (e) {
      transferError.value = e.toString();
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
      } else if (team.searchQuery.isNotEmpty) {
        tweets = await _xquik.searchTweets(customQuery: team.searchQuery, limit: 20);
      } else {
        tweets = [];
      }
      teamTweets.assignAll(tweets);
    } catch (e) {
      teamError.value = e.toString();
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
      final tweets = await _xquik.searchTweets(customQuery: '$q lang:tr', limit: 20);
      searchResults.assignAll(tweets);
    } catch (_) {
      searchResults.clear();
    } finally {
      isLoadingSearch.value = false;
    }
  }

  void onCategorySelected(int index, String tag) {
    loadFeed(category: tag, refresh: true);
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadFeed(refresh: true),
      loadTrending(),
      loadTrends(),
      loadTransfer(),
    ]);
  }

  Future<void> reloadTeams() async {
    await loadTeamsFromFirebase();
  }
}
