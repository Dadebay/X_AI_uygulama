import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconly/iconly.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:share_plus/share_plus.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:atlas/widgets/app_network_image.dart';
import 'package:atlas/modules/auth/controllers/auth_controller.dart';
import 'package:atlas/modules/auth/views/login_screen.dart';
import 'package:atlas/modules/saved/controllers/saved_controller.dart';
import 'package:atlas/shared/ad_overlay_screen.dart';

class TweetDetailScreen extends StatelessWidget {
  final TweetModel tweet;
  const TweetDetailScreen({super.key, required this.tweet});

  void _openOnX() {
    if (tweet.tweetUrl == null) return;
    Get.to(
      () => AdOverlayScreen(targetUrl: tweet.tweetUrl!),
      transition: Transition.fadeIn,
    );
  }

  void _share() {
    final url = tweet.tweetUrl ?? 'https://x.com/${tweet.handle}';
    Share.share('${tweet.content}\n\n— @${tweet.handle}\n$url');
  }

  String _cleanContent(String text) {
    if (tweet.media.isEmpty) return text;
    return text.replaceAll(RegExp(r'\s*https://t\.co/\S+\s*$'), '').trim();
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
        title: Text('Tweet',
            style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                fontFamily: 'Gilroy')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: c.divider, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.divider, width: 0.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ─────────────────────────────────────────
              Row(
                children: [
                  _Avatar(url: tweet.avatarUrl, name: tweet.username),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(tweet.username,
                                  style: TextStyle(
                                      color: c.textPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      fontFamily: 'Gilroy'),
                                  overflow: TextOverflow.ellipsis),
                            ),
                            if (tweet.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(HugeIcons.strokeRoundedTick02,
                                  color: AppColors.blue, size: 14),
                            ],
                          ],
                        ),
                        Text('@${tweet.handle}',
                            style: TextStyle(
                                color: c.textMuted,
                                fontSize: 13,
                                fontFamily: 'Gilroy')),
                      ],
                    ),
                  ),
                  // X'te Aç butonu
                  if (tweet.tweetUrl != null)
                    GestureDetector(
                      onTap: _openOnX,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          border: Border.all(color: c.divider),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('assets/icons/x_logo.png',
                                width: 12,
                                height: 12,
                                color: c.textSecondary,
                                errorBuilder: (_, __, ___) => Icon(
                                    HugeIcons.strokeRoundedLink01,
                                    size: 12,
                                    color: c.textSecondary)),
                            const SizedBox(width: 4),
                            Text("X'te Aç",
                                style: TextStyle(
                                    color: c.textSecondary,
                                    fontSize: 11,
                                    fontFamily: 'Gilroy')),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // ── İçerik ─────────────────────────────────────────
              const SizedBox(height: 14),
              Text(_cleanContent(tweet.content),
                  style: TextStyle(
                      color: c.textPrimary,
                      fontSize: 16,
                      fontFamily: 'Gilroy',
                      height: 1.55)),

              // ── Medya ──────────────────────────────────────────
              if (tweet.media.isNotEmpty) ...[
                const SizedBox(height: 12),
                _DetailMedia(media: tweet.media, onVideoTap: _openOnX),
              ],

              // ── Zaman ──────────────────────────────────────────
              if (tweet.timeAgo.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(tweet.timeAgo,
                    style: TextStyle(
                        color: c.textMuted,
                        fontSize: 13,
                        fontFamily: 'Gilroy')),
              ],

              // ── İstatistikler ───────────────────────────────────
              const SizedBox(height: 14),
              Divider(color: c.divider, height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  _BigStat(count: tweet.replies, label: 'Yanıt', c: c),
                  const SizedBox(width: 20),
                  _BigStat(count: tweet.retweets, label: 'Retweet', c: c),
                  const SizedBox(width: 20),
                  _BigStat(count: tweet.likes, label: 'Beğeni', c: c),
                ],
              ),

              // ── Aksiyon satırı: sadece bookmark + paylaş ───────
              const SizedBox(height: 12),
              Divider(color: c.divider, height: 1),
              const SizedBox(height: 4),
              Row(
                children: [
                  // Paylaş
                  GestureDetector(
                    onTap: _share,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Icon(HugeIcons.strokeRoundedShare01,
                          color: c.textMuted, size: 22),
                    ),
                  ),
                  const Spacer(),
                  // Bookmark
                  _BookmarkBtn(tweet: tweet),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Yardımcı widget'lar ────────────────────────────────────────────────────────

class _BigStat extends StatelessWidget {
  final int count;
  final String label;
  final dynamic c;
  const _BigStat({required this.count, required this.label, required this.c});

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(_fmt(count),
            style: TextStyle(
                color: c.textPrimary,
                fontWeight: FontWeight.w800,
                fontSize: 15,
                fontFamily: 'Gilroy')),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: c.textMuted, fontSize: 13, fontFamily: 'Gilroy')),
      ],
    );
  }
}

class _BookmarkBtn extends StatelessWidget {
  final TweetModel tweet;
  const _BookmarkBtn({required this.tweet});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    try {
      final auth = Get.find<AuthController>();
      final saved = Get.find<SavedController>();
      return Obx(() {
        final loggedIn = auth.user.value != null;
        final isSaved = loggedIn &&
            tweet.id.isNotEmpty &&
            saved.savedIds.contains(tweet.id);
        return GestureDetector(
          onTap: () {
            if (!loggedIn) {
              Get.to(() => const LoginScreen(),
                  transition: Transition.cupertino);
              return;
            }
            saved.toggleSave(tweet);
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              isSaved ? IconlyBold.bookmark : IconlyLight.bookmark,
              color: isSaved ? AppColors.primary : c.textMuted,
              size: 22,
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
      radius: 22,
      backgroundColor: c.surfaceElevated,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
            color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 16),
      ),
    );
    if (url.isEmpty) return fallback;
    return ClipOval(
      child: AppNetworkImage(
        url: url,
        width: 44,
        height: 44,
        fit: BoxFit.cover,
        errorWidget: fallback,
      ),
    );
  }
}

// ── Detay Medya ──────────────────────────────────────────────────────────────

class _DetailMedia extends StatelessWidget {
  final List<TweetMedia> media;
  final VoidCallback onVideoTap;
  const _DetailMedia({required this.media, required this.onVideoTap});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    final items = media.take(4).toList();
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: AspectRatio(
        aspectRatio: 16 / 10,
        child: items.length == 1
            ? _tile(c, items.first)
            : GridView.count(
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                children: items.map((m) => _tile(c, m)).toList(),
              ),
      ),
    );
  }

  Widget _tile(dynamic c, TweetMedia item) {
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
                    color: Colors.white, size: 48),
              ),
            ),
        ],
      ),
    );
  }
}
