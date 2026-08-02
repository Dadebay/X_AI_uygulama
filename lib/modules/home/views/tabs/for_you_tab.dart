import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/widgets/pulse/tweet_card.dart';
import 'package:atlas/widgets/pulse/tweet_shimmer.dart';
import 'package:atlas/widgets/pulse/feed_states.dart';
import 'package:atlas/widgets/pulse/in_feed_banner_ad.dart';
import 'package:atlas/modules/home/controllers/home_controller.dart';
import 'category_chips.dart';

class ForYouTab extends StatelessWidget {
  final HomeController ctrl;
  final List<Map<String, String>> categories;
  final int selectedCategory;
  final void Function(int, String) onCategoryChange;
  final VoidCallback onSeeAllTrending;

  const ForYouTab({
    super.key,
    required this.ctrl,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChange,
    required this.onSeeAllTrending,
  });

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.pixels >=
            notification.metrics.maxScrollExtent - 300 &&
        ctrl.hasMoreFeed.value &&
        !ctrl.isLoadingFeed.value &&
        ctrl.feedTweets.isNotEmpty) {
      // Şu an seçili kategoriyi koru — yoksa sayfalama her zaman "Tümü"
      // akışını yükleyip seçili kategorinin listesinin sonuna ekliyordu.
      final tag = categories[selectedCategory]['tag']!;
      ctrl.loadFeed(category: tag);
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Obx(() {
      // Built once per rebuild and rendered lazily via SliverList below, so
      // only the in-feed banner ads that actually scroll into view request
      // an ad — mounting all of them eagerly (as a plain ListView(children:)
      // did before) fired a burst of concurrent BannerAd.load() calls to the
      // same ad unit id, which AdMob throttles ("too many recently failed
      // requests").
      final feedItems = ctrl.isLoadingFeed.value && ctrl.feedTweets.isEmpty
          ? null
          : ctrl.feedError.value.isNotEmpty && ctrl.feedTweets.isEmpty
              ? null
              : ctrl.feedTweets.isEmpty
                  ? null
                  : interleaveBannerAds(ctrl.feedTweets
                      .map((t) => TweetCard(
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
                          ))
                      .toList());

      return RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: c.surface,
          onRefresh: ctrl.refreshAll,
          child: NotificationListener<ScrollNotification>(
            onNotification: _onScroll,
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
                SliverToBoxAdapter(
                  child: CategoryChips(
                    categories: categories,
                    selected: selectedCategory,
                    onSelect: (i) {
                      final tag = categories[i]['tag']!;
                      onCategoryChange(i, tag);
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
                    child: Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text('trending_header'.tr,
                            style: TextStyle(
                                color: c.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 17,
                                fontFamily: 'Gilroy')),
                        const Spacer(),
                        GestureDetector(
                          onTap: onSeeAllTrending,
                          child: Text('see_all'.tr,
                              style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 13,
                                  fontFamily: 'Gilroy',
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ),
                if (feedItems == null)
                  SliverToBoxAdapter(
                    child: ctrl.isLoadingFeed.value && ctrl.feedTweets.isEmpty
                        ? const TweetShimmerList()
                        : ctrl.feedError.value.isNotEmpty &&
                                ctrl.feedTweets.isEmpty
                            ? FeedErrorState(
                                message: ctrl.feedError.value,
                                onRetry: () => ctrl.loadFeed(refresh: true))
                            : const FeedEmptyState(),
                  )
                else ...[
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => feedItems[i],
                      childCount: feedItems.length,
                    ),
                  ),
                  if (ctrl.hasMoreFeed.value && ctrl.isLoadingFeed.value)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.primary)),
                      ),
                    ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
              ],
            ),
          ));
    });
  }
}
