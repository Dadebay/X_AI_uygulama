import 'package:atlas/models/tweet_model.dart';

/// Öncelikli hesaplar (ve varsa ek muaf hesaplar, örn. bir takımın kendi resmi
/// hesapları) her zaman gösterilir; diğer tüm tweetler admin panelde
/// tanımlanan minimum görüntülenme (yoksa beğeni) eşiğini geçmek zorundadır.
List<TweetModel> filterByEngagement(
  List<TweetModel> tweets, {
  required List<String> priorityAccounts,
  required int minEngagementThreshold,
  List<String> extraExempt = const [],
}) {
  if (tweets.isEmpty) return tweets;

  final exempt = {
    for (final a in priorityAccounts) a.toLowerCase(),
    for (final a in extraExempt) a.toLowerCase(),
  };

  bool passesThreshold(TweetModel t) {
    if (t.views >= minEngagementThreshold) return true;
    if (t.views == 0 && t.likes >= minEngagementThreshold) return true;
    return false;
  }

  return tweets.where((t) => exempt.contains(t.handle.toLowerCase()) || passesThreshold(t)).toList();
}
