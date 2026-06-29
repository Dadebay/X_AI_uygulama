import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/widgets/pulse/tweet_card.dart';
import 'package:atlas/widgets/pulse/feed_states.dart';
import 'package:atlas/modules/home/controllers/home_controller.dart';

class TeamsTab extends StatelessWidget {
  final HomeController ctrl;
  const TeamsTab({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Obx(() {
      if (ctrl.isLoadingTeams.value && ctrl.dynamicTeams.isEmpty) {
        return kFeedLoading;
      }
      if (ctrl.dynamicTeams.isEmpty) {
        return const FeedEmptyState();
      }
      return RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: c.surface,
        onRefresh: () => ctrl.loadTeam(ctrl.selectedTeam.value),
        child: ListView(
          padding: const EdgeInsets.only(top: 8, bottom: 20),
          children: [
            _TeamPicker(ctrl: ctrl),
            const SizedBox(height: 4),
            if (ctrl.isLoadingTeam.value && ctrl.teamTweets.isEmpty)
              kFeedLoading
            else if (ctrl.teamError.value.isNotEmpty && ctrl.teamTweets.isEmpty)
              FeedErrorState(
                message: ctrl.teamError.value,
                onRetry: () => ctrl.loadTeam(ctrl.selectedTeam.value),
              )
            else if (ctrl.teamTweets.isEmpty)
              const FeedEmptyState()
            else
              ...ctrl.teamTweets.map((t) => TweetCard(
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
          ],
        ),
      );
    });
  }
}

class _TeamPicker extends StatelessWidget {
  final HomeController ctrl;
  const _TeamPicker({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: ctrl.dynamicTeams.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final team = ctrl.dynamicTeams[i];
          return Obx(() {
            final isSelected = ctrl.selectedTeam.value == i;
            return GestureDetector(
              onTap: () => ctrl.loadTeam(i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 58,
                    height: 58,
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: team.colors.isNotEmpty
                            ? team.colors.first.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.1),
                      ),
                      child: Center(child: _buildLogo(team)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    team.shortName,
                    style: TextStyle(
                      color: isSelected
                          ? Tc.of(context).textPrimary
                          : Tc.of(context).textSecondary,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 12,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildLogo(TeamModel team) {
    if (team.logoUrl.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: team.logoUrl,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorWidget: (_, __, ___) => _fallbackLogo(team),
        ),
      );
    }
    if (team.logoAsset.isNotEmpty) {
      return ClipOval(
        child: Image.asset(
          team.logoAsset,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackLogo(team),
        ),
      );
    }
    return _fallbackLogo(team);
  }

  Widget _fallbackLogo(TeamModel team) {
    return Text(
      team.shortName.isNotEmpty ? team.shortName[0] : '⚽',
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        fontFamily: 'Gilroy',
        color: Colors.white,
      ),
    );
  }
}
