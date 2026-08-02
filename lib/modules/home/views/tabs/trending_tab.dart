import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/widgets/pulse/tweet_card.dart';
import 'package:atlas/widgets/pulse/trend_card.dart';
import 'package:atlas/widgets/pulse/tweet_shimmer.dart';
import 'package:atlas/widgets/pulse/in_feed_banner_ad.dart';
import 'package:atlas/modules/home/controllers/home_controller.dart';
import 'package:atlas/modules/explore/views/trend_detail_screen.dart';

class TrendingTab extends StatelessWidget {
  final HomeController ctrl;
  const TrendingTab({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Obx(() {
      // See for_you_tab.dart for why this list is rendered via a lazy
      // SliverList rather than a plain ListView(children:) — mounting every
      // in-feed banner ad at once fires a burst of concurrent ad requests
      // that AdMob throttles.
      final feedItems = ctrl.isLoadingTrending.value &&
              ctrl.trendingTweets.isEmpty
          ? null
          : interleaveBannerAds(ctrl.trendingTweets
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
                    isVerified: t.isVerified,
                    tweetUrl: t.tweetUrl,
                    tags: t.tags,
                    media: t.media,
                  ))
              .toList());

      return RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: c.surface,
        onRefresh: ctrl.loadTrending,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Text('popular_agendas'.tr,
                    style: TextStyle(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        fontFamily: 'Gilroy')),
              ),
            ),
            if (ctrl.trendTopics.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  child: Column(
                    children: ctrl.trendTopics
                        .map((trend) => TrendCard(
                              topic: trend,
                              onTap: () => Get.to(
                                () => TrendDetailScreen(topic: trend),
                                transition: Transition.cupertino,
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            if (feedItems == null)
              const SliverToBoxAdapter(child: TweetShimmerList())
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => feedItems[i],
                  childCount: feedItems.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      );
    });
  }
}
