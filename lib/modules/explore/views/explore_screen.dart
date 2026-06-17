import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/models/tweet_model.dart' show TrendTopic;
import 'package:atlas/widgets/pulse/tweet_card.dart';
import 'package:atlas/modules/explore/controllers/explore_controller.dart';
import 'package:atlas/modules/explore/views/all_trends_screen.dart';
import 'package:atlas/modules/explore/views/trend_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final ExploreController _ctrl;
  final _searchCtrl = TextEditingController();
  final _hasText = false.obs;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.isRegistered<ExploreController>()
        ? Get.find<ExploreController>()
        : Get.put(ExploreController());
    _searchCtrl.addListener(() {
      _hasText.value = _searchCtrl.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Text('explore_title'.tr,
                  style: TextStyle(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      fontFamily: 'Gilroy')),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.divider),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: _ctrl.search,
                  style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 14,
                      fontFamily: 'Gilroy'),
                  decoration: InputDecoration(
                    hintText: 'search_hint'.tr,
                    hintStyle: TextStyle(
                        color: c.textMuted, fontSize: 14, fontFamily: 'Gilroy'),
                    prefixIcon: Icon(HugeIcons.strokeRoundedSearch01,
                        color: c.textMuted, size: 20),
                    suffixIcon: Obx(() => _hasText.value
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                color: c.textMuted, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              _ctrl.search('');
                            },
                          )
                        : const SizedBox.shrink()),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(() => _hasText.value
                  ? _SearchResults(ctrl: _ctrl)
                  : _DefaultContent(ctrl: _ctrl)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Default (no search) ────────────────────────────────────────────────────────

class _DefaultContent extends StatelessWidget {
  final ExploreController ctrl;
  const _DefaultContent({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: ctrl.refresh,
      child: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          // ── Trend Konular ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('trend_topics'.tr,
                    style: TextStyle(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        fontFamily: 'Gilroy')),
                GestureDetector(
                  onTap: () => Get.to(
                    () => const AllTrendsScreen(),
                    transition: Transition.cupertino,
                  ),
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
          Obx(() {
            if (ctrl.isLoadingTrends.value) {
              return const _ShimmerList(count: 5, height: 56);
            }
            if (ctrl.trendTopics.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: ctrl.trendTopics
                  .map((t) => _TrendRow(topic: t))
                  .toList(),
            );
          }),

          const SizedBox(height: 20),

          // ── Popüler Tweetler ──
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text('popular_tweets'.tr,
                style: TextStyle(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    fontFamily: 'Gilroy')),
          ),
          Obx(() {
            if (ctrl.isLoadingPopular.value) {
              return const _ShimmerList(count: 3, height: 100);
            }
            if (ctrl.popularTweets.isEmpty) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text('no_results'.tr,
                      style: TextStyle(
                          color: c.textMuted, fontFamily: 'Gilroy')),
                ),
              );
            }
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: ctrl.popularTweets
                  .map((t) => TweetCard(
                        tweetId: t.id,
                        username: t.username,
                        handle: t.handle,
                        content: t.content,
                        timeAgo: t.timeAgo,
                        replies: t.replies,
                        retweets: t.retweets,
                        likes: t.likes,
                        tweetUrl: t.tweetUrl,
                        isVerified: t.isVerified,
                        avatarUrl: t.avatarUrl,
                        tags: t.tags,
                        media: t.media,
                      ))
                  .toList(),
            );
          }),
        ],
      ),
    );
  }
}

// ── Search Results ─────────────────────────────────────────────────────────────

class _SearchResults extends StatelessWidget {
  final ExploreController ctrl;
  const _SearchResults({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Obx(() {
      if (ctrl.isLoadingSearch.value) {
        return const _ShimmerList(count: 5, height: 100);
      }
      if (ctrl.searchResults.isEmpty) {
        return Center(
          child: Text('no_results'.tr,
              style: TextStyle(color: c.textMuted, fontFamily: 'Gilroy')),
        );
      }
      return ListView(
        children: ctrl.searchResults
            .map((t) => TweetCard(
                  tweetId: t.id,
                  username: t.username,
                  handle: t.handle,
                  content: t.content,
                  timeAgo: t.timeAgo,
                  replies: t.replies,
                  retweets: t.retweets,
                  likes: t.likes,
                  isVerified: t.isVerified,
                  tweetUrl: t.tweetUrl,
                  avatarUrl: t.avatarUrl,
                  tags: t.tags,
                  media: t.media,
                ))
            .toList(),
      );
    });
  }
}

// ── Trend Row ──────────────────────────────────────────────────────────────────

class _TrendRow extends StatelessWidget {
  final TrendTopic topic;
  const _TrendRow({required this.topic});

  Color get _rankColor {
    if (topic.rank <= 3) return const Color(0xFFFF4500);
    if (topic.rank <= 6) return const Color(0xFFFF8C00);
    return AppColors.primary;
  }

  // Trend adından basit kategori tahmini
  String get _category {
    final n = topic.name.toLowerCase();
    if (n.contains('galatasaray') || n.contains(' gs')) return 'Galatasaray';
    if (n.contains('fenerbahçe') || n.contains('fenerbahce')) return 'Fenerbahçe';
    if (n.contains('beşiktaş') || n.contains('besiktas')) return 'Beşiktaş';
    if (n.contains('trabzon')) return 'Trabzonspor';
    if (n.contains('transfer')) return 'Transfer';
    if (n.contains('champions') || n.contains('ucl')) return 'UCL';
    if (n.contains('süper lig') || n.contains('superlig')) return 'Süper Lig';
    if (n.contains('messi') || n.contains('ronaldo') || n.contains('mbappe')) return 'Dünya Futbolu';
    return 'Gündem';
  }

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return InkWell(
      onTap: () => Get.to(
        () => TrendDetailScreen(topic: topic),
        transition: Transition.cupertino,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Rank
            SizedBox(
              width: 24,
              child: Text(
                '${topic.rank}',
                style: TextStyle(
                  color: _rankColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  fontFamily: 'Gilroy',
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori etiketi
                  Text(
                    _category,
                    style: TextStyle(
                      color: c.textMuted,
                      fontSize: 11,
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Trend adı
                  Text(
                    '#${topic.name}',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Alt satır: gönderi sayısı
                  if (topic.postCount.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.local_fire_department_rounded,
                            size: 12, color: _rankColor),
                        const SizedBox(width: 3),
                        Text(
                          topic.postCount,
                          style: TextStyle(
                            color: c.textMuted,
                            fontSize: 11,
                            fontFamily: 'Gilroy',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            Icon(HugeIcons.strokeRoundedArrowRight01,
                color: c.textMuted, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer placeholder ────────────────────────────────────────────────────────

class _ShimmerList extends StatelessWidget {
  final int count;
  final double height;
  const _ShimmerList({required this.count, required this.height});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Container(
            height: height,
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}
