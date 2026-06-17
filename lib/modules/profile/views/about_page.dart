import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:atlas/core/services/firestore_service.dart';
import 'package:atlas/modules/profile/controllers/language_controller.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final _fs = FirestoreService();
  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _fs.getDocument('app_content', 'about');
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = true;
        _loading = false;
      });
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
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(HugeIcons.strokeRoundedArrowLeft01, color: c.textPrimary, size: 22),
          onPressed: () => Get.back(),
        ),
        title: Text('about_app'.tr, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontSize: 20, fontFamily: 'Gilroy')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(color: c.divider, height: 0.5),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error || _data == null
              ? _EmptyState(c: c, onRetry: _load)
              : _Content(data: _data!, c: c),
    );
  }
}

// ─── Privacy Page ─────────────────────────────────────────────────────────────

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  final _fs = FirestoreService();
  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _fs.getDocument('app_content', 'privacy');
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = true;
        _loading = false;
      });
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
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(HugeIcons.strokeRoundedArrowLeft01, color: c.textPrimary, size: 22),
          onPressed: () => Get.back(),
        ),
        title: Text('privacy_policy'.tr, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontSize: 20, fontFamily: 'Gilroy')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(color: c.divider, height: 0.5),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error || _data == null
              ? _EmptyState(c: c, onRetry: _load)
              : _Content(data: _data!, c: c),
    );
  }
}

// ─── Terms Page ───────────────────────────────────────────────────────────────

class TermsPage extends StatefulWidget {
  const TermsPage({super.key});

  @override
  State<TermsPage> createState() => _TermsPageState();
}

class _TermsPageState extends State<TermsPage> {
  final _fs = FirestoreService();
  Map<String, dynamic>? _data;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final data = await _fs.getDocument('app_content', 'terms');
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = true;
        _loading = false;
      });
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
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(HugeIcons.strokeRoundedArrowLeft01, color: c.textPrimary, size: 22),
          onPressed: () => Get.back(),
        ),
        title: Text('terms_of_use'.tr, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontSize: 20, fontFamily: 'Gilroy')),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(color: c.divider, height: 0.5),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _error || _data == null
              ? _EmptyState(c: c, onRetry: _load)
              : _Content(data: _data!, c: c),
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _Content extends StatelessWidget {
  final Map<String, dynamic> data;
  final Tc c;
  const _Content({required this.data, required this.c});

  @override
  Widget build(BuildContext context) {
    final lang = Get.find<LanguageController>().selectedLanguage.value;
    final title = (data['title_$lang'] ?? data['title_tr'] ?? data['title'] ?? '') as String;
    final body = (data['body_$lang'] ?? data['body_tr'] ?? data['body'] ?? '') as String;
    final updatedAt = data['updated_at'] as String?;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title.isNotEmpty) ...[
            Text(title, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontSize: 20, fontFamily: 'Gilroy')),
            const SizedBox(height: 12),
          ],
          if (updatedAt != null) ...[
            Text('${'last_updated'.tr}: $updatedAt', style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Gilroy')),
            const SizedBox(height: 16),
          ],
          Text(body, style: TextStyle(color: c.textPrimary, fontFamily: 'Gilroy', fontSize: 15, height: 1.75)),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final Tc c;
  final VoidCallback onRetry;
  const _EmptyState({required this.c, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(HugeIcons.strokeRoundedFileNotFound, size: 48, color: c.textMuted),
          const SizedBox(height: 12),
          Text('content_load_error'.tr, style: TextStyle(color: c.textSecondary, fontFamily: 'Gilroy', fontSize: 15)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: Text('retry'.tr, style: TextStyle(color: AppColors.primary, fontFamily: 'Gilroy', fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
