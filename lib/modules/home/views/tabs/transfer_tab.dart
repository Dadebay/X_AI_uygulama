import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/widgets/pulse/tweet_card.dart';
import 'package:atlas/widgets/pulse/feed_states.dart';
import 'package:atlas/modules/home/controllers/home_controller.dart';

class TransferTab extends StatelessWidget {
  final HomeController ctrl;
  const TransferTab({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Obx(() => RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: c.surface,
          onRefresh: ctrl.loadTransfer,
          child: ListView(
            children: [
              if (ctrl.isLoadingTransfer.value && ctrl.transferTweets.isEmpty)
                kFeedLoading
              else if (ctrl.transferError.value.isNotEmpty && ctrl.transferTweets.isEmpty)
                FeedErrorState(message: ctrl.transferError.value, onRetry: ctrl.loadTransfer)
              else if (ctrl.transferTweets.isEmpty)
                const FeedEmptyState()
              else
                ...ctrl.transferTweets.map((t) => TweetCard(
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
