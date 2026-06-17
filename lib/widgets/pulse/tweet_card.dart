import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:share_plus/share_plus.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/shared/ad_overlay_screen.dart';
import 'package:atlas/modules/auth/controllers/auth_controller.dart';
import 'package:atlas/modules/auth/views/login_screen.dart';
import 'package:atlas/modules/saved/controllers/saved_controller.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:atlas/widgets/app_network_image.dart';
import 'package:atlas/modules/post_detail/views/tweet_detail_screen.dart';

class TweetCard extends StatelessWidget {
  final String tweetId;
  final String username;
  final String handle;
  final String avatarUrl;
  final String content;
  final String timeAgo;
  final int replies;
  final int retweets;
  final int likes;
  final String? tweetUrl;
  final bool isVerified;
  final bool showAiBadge;
  final VoidCallback? onTap;
  final VoidCallback? onClose;
  final List<String> tags;
  final List<TweetMedia> media;

  const TweetCard({
    super.key,
    this.tweetId = '',
    required this.username,
    required this.handle,
    required this.content,
    required this.timeAgo,
    this.avatarUrl = '',
    this.replies = 0,
    this.retweets = 0,
    this.likes = 0,
    this.tweetUrl,
    this.isVerified = false,
    this.showAiBadge = false,
    this.onTap,
    this.onClose,
    this.tags = const [],
    this.media = const [],
  });

  void _openOnX() {
    if (tweetUrl == null) return;
    Get.to(
      () => AdOverlayScreen(targetUrl: tweetUrl!),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 250),
    );
  }

  void _share() {
    final url = tweetUrl ?? 'https://x.com/$handle';
    Share.share('$content\n\n— @$handle\n$url');
  }

  // Sondaki t.co medya linkini gizle (medya zaten kart içinde gösteriliyor)
  String _cleanContent(String text) {
    if (media.isEmpty) return text;
    return text.replaceAll(RegExp(r'\s*https://t\.co/\S+\s*$'), '').trim();
  }

  void _openDetail() {
    if (tweetId.isEmpty) return;
    Get.to(
      () => TweetDetailScreen(
        tweet: TweetModel(
          id: tweetId,
          username: username,
          handle: handle,
          avatarUrl: avatarUrl,
          content: content,
          timeAgo: timeAgo,
          replies: replies,
          retweets: retweets,
          likes: likes,
          tweetUrl: tweetUrl,
          isVerified: isVerified,
          tags: tags,
          media: media,
        ),
      ),
      transition: Transition.cupertino,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);

    return GestureDetector(
      onTap: onTap ?? (tweetId.isNotEmpty ? _openDetail : null),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: c.divider, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ───────────────────────────────────────────
            Row(
              children: [
                _Avatar(url: avatarUrl, name: username),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              username,
                              style: TextStyle(
                                color: c.textPrimary,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                                fontFamily: 'Gilroy',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified) ...[
                            const SizedBox(width: 3),
                            const Icon(HugeIcons.strokeRoundedTick02, color: AppColors.blue, size: 13),
                          ],
                          if (showAiBadge) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.lightPrimary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '🤖 AI Özet',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Gilroy',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            '@$handle',
                            style: TextStyle(
                              color: c.textMuted,
                              fontSize: 12,
                              fontFamily: 'Gilroy',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          if (timeAgo.isNotEmpty) ...[
                            Text(' · ', style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Gilroy')),
                            Flexible(
                              child: Text(
                                timeAgo,
                                style: TextStyle(
                                  color: c.textMuted,
                                  fontSize: 12,
                                  fontFamily: 'Gilroy',
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (onClose != null)
                  GestureDetector(
                    onTap: onClose,
                    child: Icon(HugeIcons.strokeRoundedCancel01, color: c.textMuted, size: 18),
                  ),
              ],
            ),

            // ── Content ──────────────────────────────────────────
            const SizedBox(height: 10),
            Text(
              _cleanContent(content),
              style: TextStyle(color: c.textPrimary, fontSize: 14, fontFamily: 'Gilroy', height: 1.45),
            ),

            // ── Medya ────────────────────────────────────────────
            if (media.isNotEmpty) ...[
              const SizedBox(height: 10),
              _MediaPreview(media: media, onVideoTap: _openOnX),
            ],

            // ── Stats + Actions ───────────────────────────────────
            const SizedBox(height: 10),
            Divider(color: c.divider, height: 1),
            const SizedBox(height: 8),
            Row(
              children: [
                // Yorum sayısı (read-only)
                _StatChip(
                  icon: HugeIcons.strokeRoundedComment01,
                  count: replies,
                  color: c.textMuted,
                ),
                const SizedBox(width: 14),
                // Retweet sayısı (read-only)
                _StatChip(
                  icon: HugeIcons.strokeRoundedReload,
                  count: retweets,
                  color: c.textMuted,
                ),
                const SizedBox(width: 14),
                // Beğeni sayısı (read-only)
                _StatChip(
                  icon: IconlyLight.heart,
                  count: likes,
                  color: c.textMuted,
                ),
                const Spacer(),
                // Bookmark
                _BookmarkButton(tweetId: tweetId, tweet: this),
                const SizedBox(width: 2),
                // Paylaş
                GestureDetector(
                  onTap: _share,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(HugeIcons.strokeRoundedShare01, color: c.textMuted, size: 18),
                  ),
                ),
                const SizedBox(width: 8),
                // X'te Aç
                if (tweetUrl != null)
                  GestureDetector(
                    onTap: _openOnX,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: c.divider),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/icons/x_logo.png',
                            width: 12,
                            height: 12,
                            color: c.textSecondary,
                            errorBuilder: (_, __, ___) => Icon(
                              HugeIcons.strokeRoundedLink01,
                              size: 12,
                              color: c.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "X'te Aç",
                            style: TextStyle(color: c.textSecondary, fontSize: 11, fontFamily: 'Gilroy'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkButton extends StatelessWidget {
  final String tweetId;
  final TweetCard tweet;
  const _BookmarkButton({required this.tweetId, required this.tweet});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    try {
      final auth = Get.find<AuthController>();
      final saved = Get.find<SavedController>();
      return Obx(() {
        final loggedIn = auth.user.value != null;
        final isSaved = loggedIn && tweetId.isNotEmpty && saved.savedIds.contains(tweetId);
        return GestureDetector(
          onTap: () {
            if (!loggedIn) {
              Get.to(() => const LoginScreen(), transition: Transition.cupertino);
              return;
            }
            if (tweetId.isEmpty) return;
            saved.toggleSave(TweetModel(
              id: tweetId,
              username: tweet.username,
              handle: tweet.handle,
              avatarUrl: tweet.avatarUrl,
              content: tweet.content,
              timeAgo: tweet.timeAgo,
              replies: tweet.replies,
              retweets: tweet.retweets,
              likes: tweet.likes,
              tweetUrl: tweet.tweetUrl,
              isVerified: tweet.isVerified,
              tags: tweet.tags,
            ));
          },
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Icon(
              isSaved ? IconlyBold.bookmark : IconlyLight.bookmark,
              color: isSaved ? AppColors.primary : c.textMuted,
              size: 19,
            ),
          ),
        );
      });
    } catch (_) {
      return const SizedBox.shrink();
    }
  }
}

class _Avatar extends StatelessWidget {
  final String url;
  final String name;
  const _Avatar({required this.url, required this.name});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    final fallback = CircleAvatar(
      radius: 20,
      backgroundColor: c.surfaceElevated,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
      ),
    );
    if (url.isEmpty) return fallback;
    return ClipOval(
      child: AppNetworkImage(
        url: url,
        width: 40,
        height: 40,
        fit: BoxFit.cover,
        errorWidget: fallback,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final int count;
  final Color color;
  const _StatChip({
    required this.icon,
    required this.count,
    required this.color,
  });

  String _format(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 17),
        const SizedBox(width: 4),
        Text(
          _format(count),
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontFamily: 'Gilroy',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ── Medya Önizleme ───────────────────────────────────────────────────────────

class _MediaPreview extends StatelessWidget {
  final List<TweetMedia> media;
  final VoidCallback onVideoTap;
  const _MediaPreview({required this.media, required this.onVideoTap});

  @override
  Widget build(BuildContext context) {
    final items = media.take(4).toList();
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: items.length == 1
            ? _MediaTile(item: items.first, onVideoTap: onVideoTap)
            : GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                children: items
                    .map((m) =>
                        _MediaTile(item: m, onVideoTap: onVideoTap))
                    .toList(),
              ),
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  final TweetMedia item;
  final VoidCallback onVideoTap;
  const _MediaTile({required this.item, required this.onVideoTap});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return GestureDetector(
      onTap: item.isVideo ? onVideoTap : null,
      child: Stack(
        fit: StackFit.expand,
        children: [
          AppNetworkImage(
            url: item.url,
            fit: BoxFit.cover,
            backgroundColor: c.surface,
          ),
          if (item.isVideo)
            Container(
              color: Colors.black.withValues(alpha: 0.25),
              child: const Center(
                child: Icon(Icons.play_circle_fill_rounded,
                    color: Colors.white, size: 44),
              ),
            ),
        ],
      ),
    );
  }
}
