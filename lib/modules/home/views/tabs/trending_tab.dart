import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/widgets/pulse/tweet_card.dart';
import 'package:atlas/widgets/pulse/trend_card.dart';
import 'package:atlas/widgets/pulse/feed_states.dart';
import 'package:atlas/modules/home/controllers/home_controller.dart';
import 'package:atlas/modules/explore/views/trend_detail_screen.dart';

class TrendingTab extends StatelessWidget {
  final HomeController ctrl;
  const TrendingTab({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Obx(() => RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: c.surface,
          onRefresh: ctrl.loadTrending,
          child: ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Text('popular_agendas'.tr,
                    style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontSize: 18, fontFamily: 'Gilroy')),
              ),
              if (ctrl.trendTopics.isNotEmpty)
                Padding(
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
              if (ctrl.isLoadingTrending.value && ctrl.trendingTweets.isEmpty)
                kFeedLoading
              else
                ...ctrl.trendingTweets.map((t) => TweetCard(
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
                    )),
            ],
          ),
        ));
  }
}
