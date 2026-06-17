import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/widgets/pulse/tweet_card.dart';
import 'package:atlas/widgets/pulse/feed_states.dart';
import 'package:atlas/modules/home/controllers/home_controller.dart';

const _teamLogos = [
  _TeamLogo(
    bgColor: Colors.transparent,
    asset: 'assets/images/Galatasaray_SK_football_logo.png',
  ),
  _TeamLogo(
    bgColor: Colors.transparent,
    asset: 'assets/images/Fenerbah.png',
  ),
  _TeamLogo(
    bgColor: Color(0xFF1A1A1A),
    asset: 'assets/images/kartal.png',
  ),
  _TeamLogo(bgColor: Color(0xFF7B1C1C), emoji: '⚡'),
  _TeamLogo(bgColor: Color(0xFFE30A17), emoji: '🇹🇷'),
];

class _TeamLogo {
  final Color bgColor;
  final String? asset;
  final String? emoji;
  const _TeamLogo({required this.bgColor, this.asset, this.emoji});
}

class TeamsTab extends StatelessWidget {
  final HomeController ctrl;
  const TeamsTab({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Obx(() => RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: c.surface,
          onRefresh: () => ctrl.loadTeam(ctrl.selectedTeam.value),
          child: ListView(
            padding: const EdgeInsets.only(top: 8, bottom: 20),
            children: [
              // ── Takım seçici ─────────────────────────────────────
              _TeamPicker(ctrl: ctrl),
              const SizedBox(height: 4),

              // ── İçerik ───────────────────────────────────────────
              if (ctrl.isLoadingTeam.value && ctrl.teamTweets.isEmpty)
                kFeedLoading
              else if (ctrl.teamError.value.isNotEmpty &&
                  ctrl.teamTweets.isEmpty)
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
        ));
  }
}

// ── Takım seçici (CategoryChips stili) ───────────────────────────────────────
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
        itemCount: HomeController.teams.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, i) {
          final team = HomeController.teams[i];
          final logo = _teamLogos[i];
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
                        color: isSelected
                            ? AppColors.primary
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: logo.bgColor,
                      ),
                      child: Center(child: _buildLogo(logo)),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    team.label,
                    style: TextStyle(
                      color: isSelected
                          ? Tc.of(context).textPrimary
                          : Tc.of(context).textSecondary,
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.w600,
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

  Widget _buildLogo(_TeamLogo logo) {
    if (logo.asset != null) {
      return ClipOval(
        child: Image.asset(
          logo.asset!,
          width: 52,
          height: 52,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Text(
            logo.emoji ?? '⚽',
            style: const TextStyle(fontSize: 26),
          ),
        ),
      );
    }
    return Text(logo.emoji ?? '⚽', style: const TextStyle(fontSize: 26));
  }
}
