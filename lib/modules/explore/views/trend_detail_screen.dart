import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:atlas/core/api/xquik_service.dart';
import 'package:atlas/widgets/pulse/tweet_card.dart';

class TrendDetailScreen extends StatefulWidget {
  final TrendTopic topic;
  const TrendDetailScreen({super.key, required this.topic});

  @override
  State<TrendDetailScreen> createState() => _TrendDetailScreenState();
}

class _TrendDetailScreenState extends State<TrendDetailScreen> {
  final _xquik = XquikService();
  final _tweets = <TweetModel>[].obs;
  final _isLoading = true.obs;
  final _error = ''.obs;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _isLoading.value = true;
    _error.value = '';
    try {
      final results = await _xquik.searchTweets(
        customQuery: '#${widget.topic.name} OR "${widget.topic.name}"',
        limit: 30,
      );
      _tweets.assignAll(results);
    } catch (e) {
      _error.value = e.toString();
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(HugeIcons.strokeRoundedArrowLeft01,
              color: c.textPrimary, size: 22),
        ),
        title: Column(
          children: [
            Text(
              '#${widget.topic.name}',
              style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                fontFamily: 'Gilroy',
              ),
            ),
            if (widget.topic.postCount.isNotEmpty)
              Text(
                widget.topic.postCount,
                style: TextStyle(
                  color: c.textMuted,
                  fontSize: 12,
                  fontFamily: 'Gilroy',
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '#${widget.topic.rank}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  fontFamily: 'Gilroy',
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: c.divider, height: 1),
        ),
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return _LoadingShimmer(c: c);
        }
        if (_error.value.isNotEmpty) {
          return _ErrorView(onRetry: _load, c: c);
        }
        if (_tweets.isEmpty) {
          return Center(
            child: Text('no_results'.tr,
                style: TextStyle(color: c.textMuted, fontFamily: 'Gilroy')),
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _load,
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: _tweets.length,
            itemBuilder: (_, i) {
              final t = _tweets[i];
              return TweetCard(
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
              );
            },
          ),
        );
      }),
    );
  }
}

class _LoadingShimmer extends StatelessWidget {
  final dynamic c;
  const _LoadingShimmer({required this.c});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      itemBuilder: (_, __) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.divider, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Avatar
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: c.surface,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 13, decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(6))),
                    const SizedBox(height: 6),
                    Container(width: 80, height: 11, decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(6))),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(width: double.infinity, height: 12, decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 6),
            Container(width: double.infinity, height: 12, decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(6))),
            const SizedBox(height: 6),
            Container(width: 180, height: 12, decoration: BoxDecoration(color: c.surface, borderRadius: BorderRadius.circular(6))),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final VoidCallback onRetry;
  final dynamic c;
  const _ErrorView({required this.onRetry, required this.c});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(HugeIcons.strokeRoundedAlertCircle, color: c.textMuted, size: 40),
          const SizedBox(height: 12),
          Text('Bir hata oluştu',
              style: TextStyle(color: c.textMuted, fontFamily: 'Gilroy')),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('Tekrar Dene',
                  style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Gilroy',
                      fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
