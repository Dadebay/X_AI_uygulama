import 'package:atlas/core/api/xquik_service.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:get/get.dart';

class ExploreController extends GetxController {
  ExploreController({XquikService? xquik}) : _xquik = xquik ?? XquikService();

  final XquikService _xquik;

  final trendTopics = <TrendTopic>[].obs;
  final popularTweets = <TweetModel>[].obs;
  final searchResults = <TweetModel>[].obs;

  final isLoadingTrends = false.obs;
  final isLoadingPopular = false.obs;
  final isLoadingSearch = false.obs;

  final trendsError = ''.obs;
  final popularError = ''.obs;
  final searchError = ''.obs;

  String _lastQuery = '';
  String get lastQuery => _lastQuery;
  int _searchGeneration = 0;

  @override
  void onInit() {
    super.onInit();
    loadTrends();
    loadPopularTweets();
  }

  Future<void> loadTrends() async {
    isLoadingTrends.value = true;
    trendsError.value = '';
    try {
      final trends = await _xquik.getTrends();
      trendTopics.assignAll(trends.take(8).toList());
    } catch (e) {
      trendsError.value = e.toString();
      trendTopics.clear();
    } finally {
      isLoadingTrends.value = false;
    }
  }

  Future<void> loadPopularTweets() async {
    isLoadingPopular.value = true;
    popularError.value = '';
    try {
      final tweets = await _xquik.searchTweets(
        customQuery:
            '(#Galatasaray OR #Fenerbahçe OR #Beşiktaş OR #SüperLig OR #transfer) lang:tr',
        limit: 10,
      );
      popularTweets.assignAll(tweets);
    } catch (e) {
      popularError.value = e.toString();
      popularTweets.clear();
    } finally {
      isLoadingPopular.value = false;
    }
  }

  Future<void> search(String query, {bool retry = false}) async {
    final q = query.trim();
    if (q == _lastQuery && !retry) return;
    _lastQuery = q;
    final generation = ++_searchGeneration;
    searchError.value = '';

    if (q.isEmpty) {
      searchResults.clear();
      isLoadingSearch.value = false;
      return;
    }

    isLoadingSearch.value = true;
    try {
      final tweets = await _xquik.searchTweets(
        customQuery: '$q lang:tr',
        limit: 20,
      );
      if (generation == _searchGeneration) searchResults.assignAll(tweets);
    } catch (e) {
      if (generation == _searchGeneration) {
        searchError.value = e.toString();
        searchResults.clear();
      }
    } finally {
      if (generation == _searchGeneration) isLoadingSearch.value = false;
    }
  }

  @override
  Future<void> refresh() async {
    _searchGeneration++;
    _lastQuery = '';
    searchResults.clear();
    searchError.value = '';
    isLoadingSearch.value = false;
    await Future.wait([loadTrends(), loadPopularTweets()]);
  }
}
