import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:atlas/widgets/pulse/tweet_card.dart';
import 'package:atlas/widgets/pulse/feed_states.dart';
import 'package:atlas/widgets/team/transfer_card.dart';

class TeamScreen extends StatefulWidget {
  final TeamModel team;
  const TeamScreen({super.key, required this.team});

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  bool _isFollowing = false;

  List<String> get _tabs => ['agenda_tab'.tr, 'tweets_tab'.tr, 'transfer_tab'.tr, 'matches_tab'.tr, 'players_tab'.tr];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  String _formatFollowers(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final team = widget.team;
    final c = Tc.of(context);
    return Scaffold(
      backgroundColor: c.bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            backgroundColor: c.bg,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: Icon(HugeIcons.strokeRoundedArrowLeft01, color: c.textPrimary, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(HugeIcons.strokeRoundedNotification01, color: c.textSecondary),
                onPressed: () {},
              ),
            ],
            title: Text('team_title'.tr, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 16, fontFamily: 'Gilroy')),
            expandedHeight: 210,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                color: c.bg,
                alignment: Alignment.center,
                padding: const EdgeInsets.fromLTRB(14, 60, 14, 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: c.card,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: c.divider, width: 0.8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: c.surfaceElevated,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.divider, width: 1.5),
                        ),
                        child: ClipOval(
                          child: team.logoAsset.isNotEmpty
                              ? Image.asset(
                                  team.logoAsset,
                                  width: 72,
                                  height: 72,
                                  fit: BoxFit.cover,
                                )
                              : Center(
                                  child: Text(
                                    team.shortName,
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 20, fontFamily: 'Gilroy'),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              team.name,
                              style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w900, fontSize: 20, fontFamily: 'Gilroy'),
                            ),
                            const SizedBox(height: 6),
                            // Color dots
                            if (team.colors.isNotEmpty)
                              Row(
                                children: team.colors
                                    .take(3)
                                    .map((c) => Container(
                                          width: 12,
                                          height: 12,
                                          margin: const EdgeInsets.only(right: 5),
                                          decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                                        ))
                                    .toList(),
                              ),
                            const SizedBox(height: 6),
                            Text(
                              '${_formatFollowers(team.followers)} ${'followers'.tr}',
                              style: TextStyle(color: c.textMuted, fontSize: 13, fontFamily: 'Gilroy'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Follow button
                      GestureDetector(
                        onTap: () => setState(() => _isFollowing = !_isFollowing),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            color: _isFollowing ? Colors.transparent : AppColors.primary,
                            borderRadius: BorderRadius.circular(24),
                            border: _isFollowing ? Border.all(color: c.divider) : null,
                          ),
                          child: Text(
                            _isFollowing ? 'following'.tr : 'follow'.tr,
                            style: TextStyle(
                              color: _isFollowing ? c.textSecondary : Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              fontFamily: 'Gilroy',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabCtrl,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: AppColors.primary,
              unselectedLabelColor: c.textMuted,
              indicatorColor: AppColors.primary,
              indicatorSize: TabBarIndicatorSize.label,
              dividerColor: c.divider,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Gilroy'),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, fontFamily: 'Gilroy'),
              tabs: _tabs.map((t) => Tab(text: t)).toList(),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabCtrl,
          children: [
            _AgendaTab(team: team),
            _TweetsTab(),
            _TransferTab(),
            _MatchesTab(),
            _PlayersTab(),
          ],
        ),
      ),
    );
  }
}

class _AgendaTab extends StatelessWidget {
  final TeamModel team;
  const _AgendaTab({required this.team});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    final tweets = MockData.homeFeed.where((t) => t.tags.contains(team.shortName)).toList();
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            children: [
              const Text('🔥', style: TextStyle(fontSize: 15)),
              const SizedBox(width: 6),
              Text('${team.name} ${'team_agenda'.tr}',
                  style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontSize: 16, fontFamily: 'Gilroy')),
            ],
          ),
        ),
        ...tweets.map((t) => TweetCard(
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
        if (tweets.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(child: Text('no_agenda'.tr, style: TextStyle(color: c.textMuted, fontFamily: 'Gilroy'))),
          ),
        FeedLoadMore(isLoading: false, onTap: () {}),
      ],
    );
  }
}

class _TweetsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 20),
      children: MockData.homeFeed
          .map((t) => TweetCard(
                username: t.username,
                handle: t.handle,
                content: t.content,
                timeAgo: t.timeAgo,
                replies: t.replies,
                retweets: t.retweets,
                likes: t.likes,
                tweetUrl: t.tweetUrl,
                isVerified: t.isVerified,
              ))
          .toList(),
    );
  }
}

class _TransferTab extends StatelessWidget {
  static const _transfers = [
    {'name': 'Victor Osimhen', 'from': 'Napoli', 'to': 'Galatasaray', 'fee': '50M€', 'status': 'Görüşmeler devam ediyor'},
    {'name': 'Mauro Icardi', 'from': 'Galatasaray', 'to': '?', 'fee': '-', 'status': 'Kontrakt sona eriyor'},
    {'name': 'Dries Mertens', 'from': 'Serbest', 'to': 'Galatasaray', 'fee': 'Serbest', 'status': 'Anlaşma sağlandı'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(14),
      children: _transfers.map((t) => TransferCard(data: t)).toList(),
    );
  }
}

class _MatchesTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Center(
      child: Text('matches_coming_soon'.tr, style: TextStyle(color: c.textMuted, fontFamily: 'Gilroy')),
    );
  }
}

class _PlayersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Center(
      child: Text('players_coming_soon'.tr, style: TextStyle(color: c.textMuted, fontFamily: 'Gilroy')),
    );
  }
}
