import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:atlas/core/api/xquik_service.dart';
import 'package:atlas/modules/explore/views/trend_detail_screen.dart';

class AllTrendsScreen extends StatefulWidget {
  const AllTrendsScreen({super.key});

  @override
  State<AllTrendsScreen> createState() => _AllTrendsScreenState();
}

class _AllTrendsScreenState extends State<AllTrendsScreen> {
  final _xquik = XquikService();
  final _trends = <TrendTopic>[].obs;
  final _isLoading = true.obs;

  static const _fallback = [
    TrendTopic(rank: 1, name: 'Galatasaray', postCount: ''),
    TrendTopic(rank: 2, name: 'Fenerbahçe', postCount: ''),
    TrendTopic(rank: 3, name: 'Beşiktaş', postCount: ''),
    TrendTopic(rank: 4, name: 'Trabzonspor', postCount: ''),
    TrendTopic(rank: 5, name: 'SüperLig', postCount: ''),
    TrendTopic(rank: 6, name: 'Transfer', postCount: ''),
    TrendTopic(rank: 7, name: 'ŞampiyonlarLigi', postCount: ''),
    TrendTopic(rank: 8, name: 'Mourinho', postCount: ''),
    TrendTopic(rank: 9, name: 'Osimhen', postCount: ''),
    TrendTopic(rank: 10, name: 'MHPFootball', postCount: ''),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _isLoading.value = true;
    try {
      final result = await _xquik.getTrends();
      // API'den gelenin tamamını göster, en az 10 satır için fallback ile tamamla
      if (result.length >= 10) {
        _trends.assignAll(result);
      } else {
        final combined = [...result];
        for (final fb in _fallback) {
          final alreadyIn = combined.any(
            (t) => t.name.toLowerCase() == fb.name.toLowerCase(),
          );
          if (!alreadyIn) combined.add(fb);
          if (combined.length >= 10) break;
        }
        // rank'ları yeniden numaralandır
        _trends.assignAll(combined
            .asMap()
            .entries
            .map((e) => TrendTopic(
                  rank: e.key + 1,
                  name: e.value.name,
                  postCount: e.value.postCount,
                ))
            .toList());
      }
    } catch (_) {
      _trends.assignAll(_fallback);
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
          icon: Icon(HugeIcons.strokeRoundedArrowLeft01, color: c.textPrimary, size: 22),
        ),
        title: Text(
          'trend_topics'.tr,
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            fontFamily: 'Gilroy',
          ),
        ),
        actions: [
          Obx(() => _isLoading.value
              ? const Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
                )
              : IconButton(
                  onPressed: _load,
                  icon: const Icon(HugeIcons.strokeRoundedRefresh, color: AppColors.primary, size: 20),
                )),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(color: c.divider, height: 1),
        ),
      ),
      body: Obx(() {
        if (_isLoading.value && _trends.isEmpty) {
          return _LoadingShimmer(c: c);
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _load,
          child: ListView.separated(
            padding: const EdgeInsets.only(bottom: 20),
            itemCount: _trends.length,
            separatorBuilder: (_, __) => Divider(color: c.divider, height: 1, indent: 16),
            itemBuilder: (_, i) => _TrendTile(topic: _trends[i], c: c),
          ),
        );
      }),
    );
  }
}

class _TrendTile extends StatelessWidget {
  final TrendTopic topic;
  final dynamic c;
  const _TrendTile({required this.topic, required this.c});

  // Sıralamaya göre "sıcaklık" rengi
  Color get _rankColor {
    if (topic.rank <= 3) return const Color(0xFFFF4500);
    if (topic.rank <= 6) return const Color(0xFFFF8C00);
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.to(
        () => TrendDetailScreen(topic: topic),
        transition: Transition.cupertino,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Rank badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _rankColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${topic.rank}',
                style: TextStyle(
                  color: _rankColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  fontFamily: 'Gilroy',
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Trend adı
                  Text(
                    '#${topic.name}',
                    style: TextStyle(
                      color: c.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      fontFamily: 'Gilroy',
                    ),
                  ),
                  if (topic.postCount.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department_rounded,
                            size: 13, color: _rankColor),
                        const SizedBox(width: 3),
                        Text(
                          topic.postCount,
                          style: TextStyle(
                            color: c.textMuted,
                            fontSize: 12,
                            fontFamily: 'Gilroy',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
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

class _LoadingShimmer extends StatelessWidget {
  final dynamic c;
  const _LoadingShimmer({required this.c});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10,
      padding: const EdgeInsets.all(16),
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
