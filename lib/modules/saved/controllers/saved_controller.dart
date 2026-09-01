import 'dart:async';

import 'package:get/get.dart';
import 'package:atlas/core/services/auth_service.dart';
import 'package:atlas/models/tweet_model.dart';

class SavedController extends GetxController {
  static SavedController get to => Get.find();

  /// Ücretsiz kullanıcıların kaydedebileceği maksimum tweet sayısı —
  /// Premium kullanıcılar için sınır yok.
  static const int freeLimit = 10;

  final _service = AuthService();
  final savedTweets = <TweetModel>[].obs;
  final savedIds = RxSet<String>({});
  final isLoading = true.obs;

  /// Bir tweet daha kaydedilebilir mi? Premium kullanıcılar sınırsız,
  /// diğerleri [freeLimit] ile sınırlı.
  bool canSaveMore(bool isPremium) => isPremium || savedIds.length < freeLimit;

  StreamSubscription? _authSub;
  StreamSubscription? _savedSub;

  @override
  void onInit() {
    super.onInit();
    // SavedController uygulama açılışında (henüz giriş yapılmadan) oluşturulur.
    // O anda savedTweetsStream() kullanıcısız olduğu için hep boş bir stream
    // dönüyor ve isLoading sonsuza dek true kalıyordu. Login/logout ile
    // Firestore aboneliğini burada yeniden kuruyoruz.
    _authSub = _service.authStateChanges.listen((_) => _listenSaved());
  }

  void _listenSaved() {
    _savedSub?.cancel();
    if (!_service.isLoggedIn) {
      isLoading.value = false;
      savedTweets.clear();
      savedIds.clear();
      return;
    }
    isLoading.value = true;
    _savedSub = _service.savedTweetsStream().listen(
      (list) {
        isLoading.value = false;
        savedTweets.value = list.map(_fromMap).toList();
        savedIds.assignAll(list.map((m) => m['id']?.toString() ?? '').toSet());
      },
      onError: (_) => isLoading.value = false,
    );
  }

  @override
  void onClose() {
    _authSub?.cancel();
    _savedSub?.cancel();
    super.onClose();
  }

  bool isSaved(String tweetId) => savedIds.contains(tweetId);

  Future<void> toggleSave(TweetModel tweet) async {
    if (isSaved(tweet.id)) {
      savedIds.remove(tweet.id);
      await _service.unsaveTweet(tweet.id);
    } else {
      savedIds.add(tweet.id);
      await _service.saveTweet(_toMap(tweet));
    }
  }

  Map<String, dynamic> _toMap(TweetModel t) => {
        'id': t.id,
        'username': t.username,
        'handle': t.handle,
        'avatarUrl': t.avatarUrl,
        'content': t.content,
        'timeAgo': t.timeAgo,
        'replies': t.replies,
        'retweets': t.retweets,
        'likes': t.likes,
        'tweetUrl': t.tweetUrl,
        'isVerified': t.isVerified,
        'tags': t.tags,
      };

  TweetModel _fromMap(Map<String, dynamic> m) => TweetModel(
        id: m['id']?.toString() ?? '',
        username: m['username']?.toString() ?? '',
        handle: m['handle']?.toString() ?? '',
        avatarUrl: m['avatarUrl']?.toString() ?? '',
        content: m['content']?.toString() ?? '',
        timeAgo: m['timeAgo']?.toString() ?? '',
        replies: (m['replies'] as num?)?.toInt() ?? 0,
        retweets: (m['retweets'] as num?)?.toInt() ?? 0,
        likes: (m['likes'] as num?)?.toInt() ?? 0,
        tweetUrl: m['tweetUrl']?.toString(),
        isVerified: m['isVerified'] == true,
        tags: List<String>.from(m['tags'] ?? []),
      );
}
