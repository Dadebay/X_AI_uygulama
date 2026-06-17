import 'package:flutter/material.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:atlas/widgets/pulse/tweet_card.dart';
import 'package:atlas/widgets/pulse/feed_states.dart';

class DigestScreen extends StatefulWidget {
  const DigestScreen({super.key});

  @override
  State<DigestScreen> createState() => _DigestScreenState();
}

class _DigestScreenState extends State<DigestScreen> {
  int _selectedDay = 1;
  List<String> get _days => ['yesterday'.tr, 'today'.tr, '8 May', '7 May', '6 May'];

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(HugeIcons.strokeRoundedArrowLeft01, color: c.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('daily_digest'.tr, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Gilroy')),
        actions: [
          IconButton(
            icon: Icon(HugeIcons.strokeRoundedShare01, color: c.textSecondary, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              itemCount: _days.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final sel = _selectedDay == i;
                return GestureDetector(
                  onTap: () => setState(() => _selectedDay = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary : c.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? AppColors.primary : c.divider),
                    ),
                    child: Text(
                      _days[i],
                      style: TextStyle(
                        color: sel ? Colors.white : c.textSecondary,
                        fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(14, 12, 14, 4),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.lightPrimary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                        child: Text('ai_daily_digest_badge'.tr, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 11, fontFamily: 'Gilroy')),
                      ),
                      const SizedBox(height: 12),
                      Text(MockData.aiSummary, style: TextStyle(color: c.textPrimary, fontSize: 14, fontFamily: 'Gilroy', height: 1.55)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
                  child: Text('top_tweets'.tr, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontSize: 16, fontFamily: 'Gilroy')),
                ),
                ...MockData.homeFeed.take(3).map((t) => TweetCard(
                      username: t.username,
                      handle: t.handle,
                      content: t.content,
                      timeAgo: t.timeAgo,
                      replies: t.replies,
                      retweets: t.retweets,
                      likes: t.likes,
                      tweetUrl: t.tweetUrl,
                      isVerified: t.isVerified,
                    )),
                FeedLoadMore(isLoading: false, onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
