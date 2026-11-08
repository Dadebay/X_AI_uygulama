import 'dart:async';

import 'package:atlas/core/api/xquik_service.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:atlas/modules/explore/controllers/explore_controller.dart';
import 'package:flutter_test/flutter_test.dart';

class FailingFeed extends XquikService {
  @override
  Future<List<TrendTopic>> getTrends() => Future.error(StateError('offline'));

  @override
  Future<List<TweetModel>> searchTweets({
    String category = '',
    String? customQuery,
    int limit = 20,
    String? cursor,
  }) =>
      Future.error(StateError('offline'));
}

class DeferredFeed extends XquikService {
  final requests = <String, Completer<List<TweetModel>>>{};

  @override
  Future<List<TweetModel>> searchTweets({
    String category = '',
    String? customQuery,
    int limit = 20,
    String? cursor,
  }) {
    final completer = Completer<List<TweetModel>>();
    requests[customQuery!] = completer;
    return completer.future;
  }
}

void main() {
  test('API errors leave Explore empty instead of presenting demo posts',
      () async {
    final controller = ExploreController(xquik: FailingFeed());

    await controller.loadTrends();
    await controller.loadPopularTweets();
    await controller.search('football');

    expect(controller.trendTopics, isEmpty);
    expect(controller.popularTweets, isEmpty);
    expect(controller.searchResults, isEmpty);
    expect(controller.trendsError.value, isNotEmpty);
    expect(controller.popularError.value, isNotEmpty);
    expect(controller.searchError.value, isNotEmpty);
  });

  test('an older search response cannot replace a newer query', () async {
    final feed = DeferredFeed();
    final controller = ExploreController(xquik: feed);

    final older = controller.search('first');
    final newer = controller.search('second');
    feed.requests['second lang:tr']!.complete([
      const TweetModel(
          id: '2',
          username: 'Reporter',
          handle: 'reporter',
          content: 'Second',
          timeAgo: 'now'),
    ]);
    await newer;
    feed.requests['first lang:tr']!.complete([
      const TweetModel(
          id: '1',
          username: 'Reporter',
          handle: 'reporter',
          content: 'First',
          timeAgo: 'now'),
    ]);
    await older;

    expect(controller.searchResults.single.id, '2');
    expect(controller.isLoadingSearch.value, isFalse);
  });
}
