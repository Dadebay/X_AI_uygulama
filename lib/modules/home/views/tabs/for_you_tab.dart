import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/widgets/pulse/tweet_card.dart';
import 'package:atlas/widgets/pulse/feed_states.dart';
import 'package:atlas/modules/home/controllers/home_controller.dart';
import 'category_chips.dart';

class ForYouTab extends StatelessWidget {
  final HomeController ctrl;
  final List<Map<String, String>> categories;
  final int selectedCategory;
  final void Function(int, String) onCategoryChange;

  const ForYouTab({
    super.key,
    required this.ctrl,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChange,
  });

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Obx(() => RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: c.surface,
          onRefresh: ctrl.refreshAll,
          child: ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            children: [
              CategoryChips(
                categories: categories,
                selected: selectedCategory,
                onSelect: (i) {
                  final tag = categories[i]['tag']!;
                  onCategoryChange(i, tag);
                },
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text('trending_header'.tr, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontSize: 17, fontFamily: 'Gilroy')),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => DefaultTabController.of(context).animateTo(1),
                      child: Text('see_all'.tr, style: const TextStyle(color: AppColors.primary, fontSize: 13, fontFamily: 'Gilroy', fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
              if (ctrl.isLoadingFeed.value && ctrl.feedTweets.isEmpty)
                kFeedLoading
              else if (ctrl.feedError.value.isNotEmpty && ctrl.feedTweets.isEmpty)
                FeedErrorState(message: ctrl.feedError.value, onRetry: () => ctrl.loadFeed(refresh: true))
              else if (ctrl.feedTweets.isEmpty)
                const FeedEmptyState()
              else ...[
                ...ctrl.feedTweets.map((t) => TweetCard(
                      tweetId: t.id,
                      username: t.username,
                      handle: t.handle,
                      avatarUrl: t.avatarUrl,
                      content: t.content,
                      timeAgo: t.timeAgo,
                      replies: t.replies,
                      retweets: t.retweets,
                      likes: t.likes,
                      tweetUrl: t.tweetUrl,
                      isVerified: t.isVerified,
                      tags: t.tags,
                      media: t.media,
                    )),
                if (ctrl.hasMoreFeed.value)
                  FeedLoadMore(isLoading: ctrl.isLoadingFeed.value, onTap: () => ctrl.loadFeed()),
              ],
            ],
          ),
        ));
  }
}
