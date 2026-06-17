import 'package:get/get.dart';
import 'package:atlas/core/services/auth_service.dart';
import 'package:atlas/models/tweet_model.dart';

class SavedController extends GetxController {
  static SavedController get to => Get.find();

  final _service = AuthService();
  final savedTweets = <TweetModel>[].obs;
  final savedIds = RxSet<String>({});
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _listenSaved();
  }

  void _listenSaved() {
    _service.savedTweetsStream().listen(
      (list) {
        isLoading.value = false;
        savedTweets.value = list.map(_fromMap).toList();
        savedIds.assignAll(list.map((m) => m['id']?.toString() ?? '').toSet());
      },
      onError: (_) => isLoading.value = false,
    );
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
