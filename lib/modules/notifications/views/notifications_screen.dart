import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/core/services/notification_storage_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _storage = NotificationStorageService();
  late List<Map<String, dynamic>> _items;

  @override
  void initState() {
    super.initState();
    _items = _storage.getAll();
  }

  void _refresh() => setState(() => _items = _storage.getAll());

  String _formatTime(String isoTime) {
    try {
      final dt = DateTime.parse(isoTime);
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return 'now'.tr;
      if (diff.inMinutes < 60) return '${diff.inMinutes} ${'minutes_ago'.tr}';
      if (diff.inHours < 24) return '${diff.inHours} ${'hours_ago'.tr}';
      return '${diff.inDays} ${'days_ago'.tr}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    final unread = _items.where((n) => n['read'] != true).length;
    return Scaffold(
      backgroundColor: c.bg,
      body: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          SliverAppBar(
            backgroundColor: c.bg,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            centerTitle: true,
            elevation: 0,
            toolbarHeight: 56,
            leading: IconButton(
              icon: Icon(HugeIcons.strokeRoundedArrowLeft01, color: c.textPrimary, size: 24),
              onPressed: () => Get.back(),
            ),
            titleSpacing: 0,
            title: Row(
              children: [
                Text(
                  'notifications_title'.tr,
                  style: TextStyle(
                    color: c.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Gilroy',
                  ),
                ),
                if (unread > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.lightPrimary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$unread',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              if (unread > 0)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: TextButton(
                    onPressed: () {
                      _storage.markAllRead();
                      _refresh();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      minimumSize: const Size(0, 36),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'mark_all_read'.tr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Gilroy',
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
        body: _items.isEmpty
            ? _EmptyState(c: c)
            : ListView.builder(
                padding: const EdgeInsets.only(top: 4, bottom: 24),
                itemCount: _items.length,
                itemBuilder: (context, i) {
                  final item = _items[i];
                  return _NotifCard(
                    key: Key(item['id'] as String),
                    item: item,
                    formatTime: _formatTime,
                    onTap: () {
                      _storage.markRead(item['id'] as String);
                      _refresh();
                      Get.to(
                        () => _NotifDetailScreen(item: item),
                        transition: Transition.cupertino,
                      );
                    },
                    onDelete: () {
                      _storage.delete(item['id'] as String);
                      _refresh();
                    },
                  );
                },
              ),
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String Function(String) formatTime;

  const _NotifCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.formatTime,
  });

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    final bool read = item['read'] == true;
    final String timeStr = item['time'] is String ? formatTime(item['time'] as String) : '';
    final String title = (item['title'] as String?) ?? '';
    final String body = (item['body'] as String?) ?? '';

    return Dismissible(
      key: Key('dis_${item['id']}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        padding: const EdgeInsets.only(right: 22),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(HugeIcons.strokeRoundedDelete02, color: AppColors.red, size: 20),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: read ? c.divider : AppColors.primary.withValues(alpha: 0.45),
              width: 0.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBubble(read: read, c: c),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              fontFamily: 'Gilroy',
                              height: 1.3,
                            ),
                          ),
                        ),
                        if (!read) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 7,
                            height: 7,
                            margin: const EdgeInsets.only(top: 5),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (body.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        body,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: c.textSecondary,
                          fontSize: 13,
                          fontFamily: 'Gilroy',
                          height: 1.45,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(HugeIcons.strokeRoundedClock01, color: c.textMuted, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          timeStr,
                          style: TextStyle(
                            color: c.textMuted,
                            fontSize: 12,
                            fontFamily: 'Gilroy',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final bool read;
  final Tc c;
  const _IconBubble({required this.read, required this.c});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: read ? c.surfaceElevated : AppColors.lightPrimary,
      child: Icon(
        HugeIcons.strokeRoundedNotification01,
        size: 20,
        color: read ? c.textMuted : AppColors.primary,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Tc c;
  const _EmptyState({required this.c});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: c.surfaceElevated,
            child: Icon(HugeIcons.strokeRoundedNotificationOff01, size: 32, color: c.textMuted),
          ),
          const SizedBox(height: 16),
          Text(
            'notif_empty_title'.tr,
            style: TextStyle(
              color: c.textPrimary,
              fontFamily: 'Gilroy',
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'notif_empty_sub'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(color: c.textMuted, fontFamily: 'Gilroy', fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _NotifDetailScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  const _NotifDetailScreen({required this.item});

  String _fullTime(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      String two(int n) => n.toString().padLeft(2, '0');
      return '${two(dt.day)}.${two(dt.month)}.${dt.year} · ${two(dt.hour)}:${two(dt.minute)}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    final String title = (item['title'] as String?) ?? '';
    final String body = (item['body'] as String?) ?? '';
    final String timeStr = item['time'] is String ? _fullTime(item['time'] as String) : '';

    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 56,
        leading: IconButton(
          icon: Icon(HugeIcons.strokeRoundedArrowLeft01, color: c.textPrimary, size: 24),
          onPressed: () => Get.back(),
        ),
        titleSpacing: 0,
        title: Text(
          'notif_detail_title'.tr,
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 17,
            fontFamily: 'Gilroy',
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
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
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.lightPrimary,
                    child: Icon(
                      HugeIcons.strokeRoundedNotification01,
                      size: 24,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (timeStr.isNotEmpty)
                    Expanded(
                      child: Row(
                        children: [
                          Icon(HugeIcons.strokeRoundedClock01, color: c.textMuted, size: 13),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              timeStr,
                              style: TextStyle(
                                color: c.textMuted,
                                fontSize: 12,
                                fontFamily: 'Gilroy',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  color: c.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                  fontFamily: 'Gilroy',
                  height: 1.35,
                ),
              ),
              if (body.isNotEmpty) ...[
                const SizedBox(height: 14),
                Divider(color: c.divider, height: 1),
                const SizedBox(height: 14),
                Text(
                  body,
                  style: TextStyle(
                    color: c.textSecondary,
                    fontSize: 15,
                    fontFamily: 'Gilroy',
                    height: 1.65,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
