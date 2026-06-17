import 'package:atlas/core/api/xquik_client.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:dio/dio.dart';

class XquikService {
  final Dio _dio = XquikClient.instance;

  // Futbol hesapları — tweet kaynakları
  static const List<String> footballAccounts = [
    'FabrizioRomano',
    'yagiz_sabuncuoglu',
    'GalatasaraySK',
    'Fenerbahce',
    'BJK',
    'NicoSchira',
    'DisclosedTR',
    'TrollFootball',
  ];

  // Kategori → X arama sorgusu eşleşmesi
  static const Map<String, String> categoryQueries = {
    '': '(#Galatasaray OR #Fenerbahçe OR #Beşiktaş OR #SüperLig OR #transfer) lang:tr',
    'GS': '(#Galatasaray OR #GalatasaraySK OR from:GalatasaraySK) lang:tr',
    'FB': '(#Fenerbahçe OR #Fenerbahce OR from:Fenerbahce) lang:tr',
    'BJK': '(#Beşiktaş OR #Besiktas OR from:BJK) lang:tr',
    'Süper Lig': '#SüperLig OR #SuperLig lang:tr',
    'UCL': '#ChampionsLeague OR #UCL',
    'Transfer': '#transfer OR #TransferHaberleri lang:tr',
    'Trending': '',
  };

  /// Tweet arama — kategori veya özel sorgu ile
  Future<List<TweetModel>> searchTweets({
    String category = '',
    String? customQuery,
    int limit = 20,
    String? cursor,
  }) async {
    final query = customQuery ?? categoryQueries[category] ?? categoryQueries['']!;

    final Map<String, dynamic> params = {
      'q': query,
      'limit': limit,
      'retweets': false,
    };
    if (cursor != null) params['after'] = cursor;

    final response = await _dio.get('/x/tweets/search', queryParameters: params);
    return _parseTweetList(response.data);
  }

  /// Belirli bir hesabın timeline'ı
  Future<List<TweetModel>> getUserTimeline(String username, {int limit = 10}) async {
    final response = await _dio.get(
      '/x/users/$username/tweets',
      queryParameters: {'limit': limit, 'replies': false},
    );
    return _parseTweetList(response.data);
  }

  /// Birden fazla hesabın tweetlerini çek, likes'a göre sırala
  Future<List<TweetModel>> getMultiAccountFeed({int perAccount = 5}) async {
    final futures = footballAccounts.map((u) => getUserTimeline(u, limit: perAccount).catchError((_) => <TweetModel>[]));
    final results = await Future.wait(futures);
    final merged = results.expand((list) => list).toList();
    merged.sort((a, b) => b.likes.compareTo(a.likes));
    return merged;
  }

  /// Türkiye trend konuları (woeid: 23424969)
  Future<List<TrendTopic>> getTrends() async {
    final response = await _dio.get('/x/trends', queryParameters: {'woeid': 23424969});
    final data = response.data;
    final List items = data is List ? data : (data['trends'] ?? data['data'] ?? []);
    return items.asMap().entries.map((e) {
      final item = e.value as Map<String, dynamic>;
      return TrendTopic(
        rank: e.key + 1,
        name: item['name']?.toString().replaceAll('#', '') ?? '',
        postCount: _formatCount(item['tweet_volume'] ?? item['tweetVolume'] ?? 0),
      );
    }).toList();
  }

  /// Tweet beğen
  Future<void> likeTweet(String tweetId) async {
    await _dio.post('/x/tweets/$tweetId/like');
  }

  /// Tweet beğeniyi geri al
  Future<void> unlikeTweet(String tweetId) async {
    await _dio.delete('/x/tweets/$tweetId/like');
  }

  /// Tweet retweet et
  Future<void> retweetTweet(String tweetId) async {
    await _dio.post('/x/tweets/$tweetId/retweet');
  }

  /// Retweet geri al
  Future<void> unretweetTweet(String tweetId) async {
    await _dio.delete('/x/tweets/$tweetId/retweet');
  }

  /// Tweet yanıtla
  Future<void> replyTweet(String tweetId, String text) async {
    await _dio.post('/x/tweets', data: {
      'text': text,
      'reply': {'in_reply_to_tweet_id': tweetId},
    });
  }

  /// Tweet yanıtlarını getir
  Future<List<TweetModel>> getReplies(String tweetId, {int limit = 20}) async {
    final response = await _dio.get(
      '/x/tweets/search',
      queryParameters: {'q': 'conversation_id:$tweetId', 'limit': limit},
    );
    return _parseTweetList(response.data);
  }

  /// Belirli bir hesabı monitör et (real-time)
  Future<String> createAccountMonitor(String username) async {
    final response = await _dio.post('/monitors', data: {
      'username': username,
      'eventTypes': ['tweet.new'],
    });
    return response.data['id']?.toString() ?? '';
  }

  /// Keyword monitörü oluştur
  Future<String> createKeywordMonitor(String query) async {
    final response = await _dio.post('/monitors/keyword', data: {
      'query': query,
      'eventTypes': ['tweet.new'],
    });
    return response.data['id']?.toString() ?? '';
  }

  /// Monitör event'lerini getir
  Future<List<TweetModel>> getMonitorEvents(String monitorId, {int limit = 20}) async {
    final response = await _dio.get('/events', queryParameters: {
      'monitorId': monitorId,
      'limit': limit,
    });
    final data = response.data;
    final List items = data is List ? data : (data['items'] ?? data['data'] ?? []);
    return items
        .map((e) {
          final tweet = e['tweet'] ?? e['data'] ?? e;
          return _parseSingleTweet(tweet as Map<String, dynamic>);
        })
        .whereType<TweetModel>()
        .toList();
  }

  // ─── Parse Helpers ────────────────────────────────────────────────────────

  List<TweetModel> _parseTweetList(dynamic data) {
    List items = [];
    if (data is List) {
      items = data;
    } else if (data is Map) {
      items = data['tweets'] ?? data['data'] ?? data['results'] ?? data['items'] ?? [];
    }
    return items.map((e) => _parseSingleTweet(e as Map<String, dynamic>)).whereType<TweetModel>().toList();
  }

  TweetModel? _parseSingleTweet(Map<String, dynamic> t) {
    try {
      final author = t['author'] ?? t['user'] ?? {};
      final metrics = t['publicMetrics'] ?? t['public_metrics'] ?? t['metrics'] ?? {};

      final id = t['id']?.toString() ?? t['tweetId']?.toString() ?? '';
      final username = author['name']?.toString() ?? author['displayName']?.toString() ?? '';
      final handle = author['userName']?.toString() ?? author['username']?.toString() ?? author['screen_name']?.toString() ?? '';
      final avatarUrl = author['profilePicture']?.toString() ?? author['profile_image_url']?.toString() ?? '';
      final content = t['text']?.toString() ?? t['full_text']?.toString() ?? '';
      final createdAt = t['createdAt']?.toString() ?? t['created_at']?.toString() ?? '';
      final isVerified = author['isBlueVerified'] == true || author['verified'] == true;
      final likes = _parseInt(metrics['likeCount'] ?? metrics['favorite_count'] ?? metrics['likes'] ?? 0);
      final retweets = _parseInt(metrics['retweetCount'] ?? metrics['retweet_count'] ?? metrics['retweets'] ?? 0);
      final replies = _parseInt(metrics['replyCount'] ?? metrics['reply_count'] ?? metrics['replies'] ?? 0);
      final tweetUrl = t['url']?.toString() ?? (handle.isNotEmpty && id.isNotEmpty ? 'https://x.com/$handle/status/$id' : null);

      if (id.isEmpty || content.isEmpty) return null;

      return TweetModel(
        id: id,
        username: username,
        handle: handle,
        avatarUrl: avatarUrl,
        content: content,
        timeAgo: _timeAgo(createdAt),
        likes: likes,
        retweets: retweets,
        replies: replies,
        tweetUrl: tweetUrl,
        isVerified: isVerified,
        tags: _inferTags(content, handle),
        media: _parseMedia(t['media']),
      );
    } catch (_) {
      return null;
    }
  }

  List<TweetMedia> _parseMedia(dynamic raw) {
    if (raw is! List || raw.isEmpty) return const [];
    final result = <TweetMedia>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final type = item['type']?.toString() ?? 'photo';
      final url = item['media_url_https']?.toString() ??
          item['url']?.toString() ??
          '';
      if (url.isEmpty) continue;
      // metin içindeki t.co linkleri görsel değil, sadece gerçek media_url'leri al
      if (!url.contains('pbs.twimg.com') && !url.contains('twimg.com')) {
        continue;
      }
      result.add(TweetMedia(
        url: url,
        isVideo: type == 'video' || type == 'animated_gif',
      ));
    }
    return result;
  }

  List<String> _inferTags(String text, String handle) {
    final lower = text.toLowerCase();
    final tags = <String>[];
    if (lower.contains('galatasaray') || lower.contains(' gs ') || handle.toLowerCase().contains('galatasaray')) tags.add('GS');
    if (lower.contains('fenerbahçe') || lower.contains('fenerbahce') || lower.contains(' fb ') || handle.toLowerCase().contains('fenerbahce')) tags.add('FB');
    if (lower.contains('beşiktaş') || lower.contains('besiktas') || lower.contains(' bjk ') || handle.toLowerCase() == 'bjk') tags.add('BJK');
    if (lower.contains('transfer')) tags.add('Transfer');
    if (lower.contains('champions') || lower.contains(' ucl ')) tags.add('UCL');
    if (lower.contains('süper lig') || lower.contains('superlig')) tags.add('Süper Lig');
    return tags;
  }

  int _parseInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }

  String _formatCount(dynamic v) {
    final n = _parseInt(v);
    if (n == 0) return '';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K gönderi';
    return '$n gönderi';
  }

  String _timeAgo(String createdAt) {
    if (createdAt.isEmpty) return '';
    try {
      final dt = _parseDate(createdAt).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 1) return 'şimdi';
      if (diff.inMinutes < 60) return '${diff.inMinutes}dk';
      if (diff.inHours < 24) return '${diff.inHours}s';
      // 24 saatten eskiyse: gün ay saat:dakika
      final months = ['Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz', 'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'];
      final month = months[dt.month - 1];
      final hour = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} $month · $hour:$min';
    } catch (_) {
      return '';
    }
  }

  // "Wed Jun 17 08:18:41 +0000 2026" → DateTime
  DateTime _parseDate(String raw) {
    // ISO 8601 formatını önce dene
    try {
      return DateTime.parse(raw);
    } catch (_) {}

    // Twitter formatı: "Wed Jun 17 08:18:41 +0000 2026"
    final months = {
      'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
      'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
    };
    final parts = raw.split(' ');
    // parts: [Wed, Jun, 17, 08:18:41, +0000, 2026]
    if (parts.length >= 6) {
      final month = months[parts[1]] ?? 1;
      final day = int.parse(parts[2]);
      final year = int.parse(parts[5]);
      final time = parts[3].split(':');
      final hour = int.parse(time[0]);
      final min = int.parse(time[1]);
      final sec = int.parse(time[2]);
      return DateTime.utc(year, month, day, hour, min, sec);
    }
    throw FormatException('unknown date: $raw');
  }
}
