import 'package:atlas/core/api/xquik_service.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:get/get.dart';

class ExploreController extends GetxController {
  final XquikService _xquik = XquikService();

  final trendTopics = <TrendTopic>[].obs;
  final popularTweets = <TweetModel>[].obs;
  final searchResults = <TweetModel>[].obs;

  final isLoadingTrends = false.obs;
  final isLoadingPopular = false.obs;
  final isLoadingSearch = false.obs;

  final trendsError = ''.obs;
  final popularError = ''.obs;

  String _lastQuery = '';

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
      trendTopics.assignAll(MockData.trendTopics);
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
      popularTweets.assignAll(MockData.homeFeed);
    } finally {
      isLoadingPopular.value = false;
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
    await Future.wait([loadTrends(), loadPopularTweets()]);
  }
}
