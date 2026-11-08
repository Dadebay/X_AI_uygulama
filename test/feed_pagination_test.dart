import 'dart:async';

import 'package:atlas/core/api/xquik_service.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:atlas/modules/home/controllers/home_controller.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

TweetModel tweet(String id) => TweetModel(
      id: id,
      username: 'Reporter',
      handle: 'reporter',
      content: 'Post $id',
      timeAgo: 'now',
    );

class FakeFeed extends XquikService {
  final requestedCursors = <String?>[];
  final requestedCategories = <String>[];

  @override
  Future<TweetPage> searchTweetPage({
    String category = '',
    String? customQuery,
    int limit = 20,
    String? cursor,
  }) async {
    requestedCursors.add(cursor);
    requestedCategories.add(category);
    if (cursor == null) {
      return TweetPage(
          tweets: [tweet('1'), tweet('2')],
          nextCursor: 'page-2',
          hasMore: true);
    }
    return TweetPage(tweets: [tweet('2'), tweet('3')], hasMore: false);
  }
}

class DeferredFeed extends XquikService {
  final requests = <Completer<TweetPage>>[];

  @override
  Future<TweetPage> searchTweetPage({
    String category = '',
    String? customQuery,
    int limit = 20,
    String? cursor,
  }) {
    final request = Completer<TweetPage>();
    requests.add(request);
    return request.future;
  }
}

void main() {
  test('feed appends unique posts and stops when the server ends pagination',
      () async {
    final service = FakeFeed();
    final controller = HomeController(xquik: service);

    await controller.loadFeed();
    expect(controller.feedTweets.map((item) => item.id), ['1', '2']);
    expect(controller.hasMoreFeed.value, isTrue);

    await controller.loadFeed();
    expect(service.requestedCursors, [null, 'page-2']);
    expect(controller.feedTweets.map((item) => item.id), ['1', '2', '3']);
    expect(controller.hasMoreFeed.value, isFalse);
  });

  test('Load More keeps the selected category', () async {
    final service = FakeFeed();
    final controller = HomeController(xquik: service);

    await controller.loadFeed(category: 'GS', refresh: true);
    await controller.loadFeed();

    expect(service.requestedCategories, ['GS', 'GS']);
  });

  test('a previous feed response cannot replace a refreshed category',
      () async {
    final service = DeferredFeed();
    final controller = HomeController(xquik: service);

    final older = controller.loadFeed();
    final newer = controller.loadFeed(category: 'FB', refresh: true);
    service.requests[1]
        .complete(TweetPage(tweets: [tweet('new')], hasMore: false));
    await newer;
    service.requests[0]
        .complete(TweetPage(tweets: [tweet('old')], hasMore: false));
    await older;

    expect(controller.feedTweets.single.id, 'new');
    expect(controller.isLoadingFeed.value, isFalse);
  });

  test('search sends a cursor and honors has_more and next_cursor', () async {
    final requestedCursors = <dynamic>[];
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      requestedCursors.add(options.queryParameters['cursor']);
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'items': [
            {
              'id': '42',
              'text': 'A post',
              'author': {'name': 'Reporter'}
            }
          ],
          'has_more': true,
          'next_cursor': 'cursor-2',
        },
      ));
    }));

    final page =
        await XquikService(dio: dio).searchTweetPage(cursor: 'cursor-1');
    expect(requestedCursors, ['cursor-1']);
    expect(page.tweets.single.id, '42');
    expect(page.nextCursor, 'cursor-2');
    expect(page.hasMore, isTrue);
  });

  test('a repeated cursor cannot create an endless Load More loop', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {'items': [], 'has_more': true, 'next_cursor': 'cursor-1'},
      ));
    }));

    final page =
        await XquikService(dio: dio).searchTweetPage(cursor: 'cursor-1');
    expect(page.nextCursor, isNull);
    expect(page.hasMore, isFalse);
  });
}
