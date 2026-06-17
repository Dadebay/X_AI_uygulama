import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/modules/home/controllers/home_controller.dart';
import 'package:atlas/modules/notifications/views/notifications_screen.dart';
import 'package:atlas/widgets/pulse/tweet_card.dart';
import 'tabs/for_you_tab.dart';
import 'tabs/trending_tab.dart';
import 'tabs/teams_tab.dart';
import 'tabs/transfer_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final HomeController _ctrl;
  AnimationController? _searchAnim;
  Animation<double>? _fadeAnim;
  Animation<Offset>? _slideAnim;

  final _searchCtrl = TextEditingController();
  final _searchFocus = FocusNode();
  bool _searchOpen = false;
  bool _hasSearched = false;
  int _selectedCategory = 0;

  final List<Map<String, String>> _categories = const [
    {'label': 'Tümü', 'tag': ''},
    {'label': 'GS', 'tag': 'GS'},
    {'label': 'FB', 'tag': 'FB'},
    {'label': 'BJK', 'tag': 'BJK'},
    {'label': 'Süper Lig', 'tag': 'Süper Lig'},
    {'label': 'UCL', 'tag': 'UCL'},
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(HomeController());
    _initSearchAnim();
  }

  void _initSearchAnim() {
    final anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _searchAnim = anim;
    _fadeAnim = CurvedAnimation(parent: anim, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _searchAnim?.dispose();
    _searchCtrl.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _openSearch() {
    if (_searchAnim == null) _initSearchAnim();
    setState(() => _searchOpen = true);
    _searchAnim!.forward();
    Future.delayed(const Duration(milliseconds: 80), () {
      if (mounted) _searchFocus.requestFocus();
    });
  }

  void _closeSearch() {
    _searchFocus.unfocus();
    _searchAnim?.reverse().then((_) {
      if (mounted) {
        setState(() {
          _searchOpen = false;
          _hasSearched = false;
          _searchCtrl.clear();
        });
        _ctrl.searchResults.clear();
      }
    });
  }

  void _onSearchSubmit(String query) {
    if (query.trim().isEmpty) return;
    setState(() => _hasSearched = true);
    _searchFocus.unfocus();
    _ctrl.search(query);
  }

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: c.bg,
        appBar: AppBar(
          backgroundColor: c.bg,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 56,
          title: _searchOpen
              ? SlideTransition(
                  position: _slideAnim!,
                  child: FadeTransition(
                    opacity: _fadeAnim!,
                    child: _SearchBar(
                      ctrl: _searchCtrl,
                      focus: _searchFocus,
                      onClose: _closeSearch,
                      onSubmit: _onSearchSubmit,
                    ),
                  ),
                )
              : Row(
                  children: [
                    const Icon(HugeIcons.strokeRoundedPulse01,
                        color: AppColors.primary, size: 28),
                    const SizedBox(width: 8),
                    Text('Pulse',
                        style: TextStyle(
                            color: c.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Gilroy')),
                  ],
                ),
          actions: _searchOpen
              ? []
              : [
                  IconButton(
                    icon: Icon(HugeIcons.strokeRoundedSearch01,
                        color: c.textSecondary),
                    onPressed: _openSearch,
                  ),
                  IconButton(
                    icon: Icon(HugeIcons.strokeRoundedNotification01,
                        color: c.textSecondary),
                    onPressed: () => Get.to(
                      () => const NotificationsScreen(),
                      transition: Transition.cupertino,
                    ),
                  ),
                ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(49),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TabBar(
                  isScrollable: false,
                  dividerColor: Colors.transparent,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: const UnderlineTabIndicator(
                    borderSide:
                        BorderSide(color: AppColors.primary, width: 3),
                    insets: EdgeInsets.symmetric(horizontal: 6),
                  ),
                  labelColor: AppColors.primary,
                  unselectedLabelColor: c.textSecondary,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      fontFamily: 'Gilroy'),
                  unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      fontFamily: 'Gilroy'),
                  tabs: [
                    Tab(text: 'for_you'.tr),
                    Tab(text: 'trending'.tr),
                    Tab(text: 'teams'.tr),
                    Tab(text: 'transfer'.tr),
                  ],
                ),
                Divider(color: c.divider, height: 1),
              ],
            ),
          ),
        ),
        body: Stack(
          children: [
            // ── Normal tab içeriği ──────────────────────────────
            TabBarView(
              physics: const BouncingScrollPhysics(),
              children: [
                ForYouTab(
                  ctrl: _ctrl,
                  categories: _categories,
                  selectedCategory: _selectedCategory,
                  onCategoryChange: (i, tag) {
                    setState(() => _selectedCategory = i);
                    _ctrl.onCategorySelected(i, tag);
                  },
                ),
                TrendingTab(ctrl: _ctrl),
                TeamsTab(ctrl: _ctrl),
                TransferTab(ctrl: _ctrl),
              ],
            ),

            // ── Search sonuçları overlay ────────────────────────
            if (_searchOpen)
              AnimatedOpacity(
                opacity: _hasSearched ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: _SearchOverlay(ctrl: _ctrl, query: _searchCtrl.text),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Search Bar ─────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final TextEditingController ctrl;
  final FocusNode focus;
  final VoidCallback onClose;
  final ValueChanged<String> onSubmit;

  const _SearchBar({
    required this.ctrl,
    required this.focus,
    required this.onClose,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.divider),
              ),
              child: TextField(
                controller: ctrl,
                focusNode: focus,
                style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 14,
                    fontFamily: 'Gilroy'),
                decoration: InputDecoration(
                  hintText: 'Ara...',
                  hintStyle: TextStyle(
                      color: c.textMuted,
                      fontSize: 14,
                      fontFamily: 'Gilroy'),
                  prefixIcon: Icon(HugeIcons.strokeRoundedSearch01,
                      color: c.textMuted, size: 18),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: onSubmit,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onClose,
            child: const Text('İptal',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Gilroy')),
          ),
        ],
      ),
    );
  }
}

// ── Search Overlay ─────────────────────────────────────────────────────────────

class _SearchOverlay extends StatelessWidget {
  final HomeController ctrl;
  final String query;

  const _SearchOverlay({required this.ctrl, required this.query});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Container(
      color: c.bg,
      child: Obx(() {
        if (ctrl.isLoadingSearch.value) {
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12),
            itemCount: 5,
            itemBuilder: (_, __) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              height: 100,
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          );
        }

        if (ctrl.searchResults.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(HugeIcons.strokeRoundedSearch01,
                    color: c.textMuted, size: 48),
                const SizedBox(height: 12),
                Text(
                  '"$query" için sonuç bulunamadı',
                  style: TextStyle(
                      color: c.textMuted,
                      fontSize: 14,
                      fontFamily: 'Gilroy'),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 20),
          itemCount: ctrl.searchResults.length,
          itemBuilder: (_, i) {
            final t = ctrl.searchResults[i];
            return TweetCard(
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
            );
          },
        );
      }),
    );
  }
}
