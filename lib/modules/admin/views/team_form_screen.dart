import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/modules/admin/controllers/admin_controller.dart';
import 'package:atlas/modules/admin/controllers/web_admin_controller.dart';

class TeamFormScreen extends StatefulWidget {
  final TeamModel? team;
  const TeamFormScreen({super.key, this.team});

  @override
  State<TeamFormScreen> createState() => _TeamFormScreenState();
}

class _TeamFormScreenState extends State<TeamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _shortNameCtrl = TextEditingController();
  final _logoUrlCtrl = TextEditingController();
  final _leagueCtrl = TextEditingController();
  final _orderCtrl = TextEditingController();
  final _color1Ctrl = TextEditingController();
  final _color2Ctrl = TextEditingController();
  final _searchQueryCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();

  final _accounts = <String>[];
  bool _isSaving = false;

  bool get isEdit => widget.team != null;

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      final t = widget.team!;
      _nameCtrl.text = t.name;
      _shortNameCtrl.text = t.shortName;
      _logoUrlCtrl.text = t.logoUrl;
      _leagueCtrl.text = t.league;
      _orderCtrl.text = t.order.toString();
      _searchQueryCtrl.text = t.searchQuery;
      _accounts.addAll(t.twitterAccounts);
      if (t.colors.isNotEmpty) {
        _color1Ctrl.text = _colorToHex(t.colors[0]);
      }
      if (t.colors.length > 1) {
        _color2Ctrl.text = _colorToHex(t.colors[1]);
      }
    }
    _logoUrlCtrl.addListener(() => setState(() {}));
    _color1Ctrl.addListener(() => setState(() {}));
    _color2Ctrl.addListener(() => setState(() {}));
    _nameCtrl.addListener(() => setState(() {}));
    _shortNameCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _shortNameCtrl.dispose();
    _logoUrlCtrl.dispose();
    _leagueCtrl.dispose();
    _orderCtrl.dispose();
    _color1Ctrl.dispose();
    _color2Ctrl.dispose();
    _searchQueryCtrl.dispose();
    _accountCtrl.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }

  Color? _hexToColor(String hex) {
    var h = hex.trim().replaceAll('#', '');
    if (h.length != 6 && h.length != 8) return null;
    if (h.length == 6) h = 'FF$h';
    final value = int.tryParse(h, radix: 16);
    if (value == null) return null;
    return Color(value);
  }

  void _addAccount() {
    final handle = _accountCtrl.text.trim().replaceAll('@', '');
    if (handle.isEmpty) return;
    if (_accounts.contains(handle)) {
      Get.snackbar('Zaten eklendi', '@$handle zaten listede',
          backgroundColor: const Color(0xFF1A1A1A), colorText: Colors.white);
      return;
    }
    setState(() {
      _accounts.add(handle);
      _accountCtrl.clear();
    });
  }

  void _removeAccount(String handle) {
    setState(() => _accounts.remove(handle));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      Get.snackbar('Eksik bilgi', 'Lütfen kırmızı ile işaretli zorunlu alanları doldurun',
          backgroundColor: const Color(0xFF1A1A1A), colorText: Colors.white);
      return;
    }
    if (_accounts.isEmpty && _searchQueryCtrl.text.trim().isEmpty) {
      Get.snackbar(
        'Kaynak eksik',
        'En az bir Twitter hesabı ekleyin veya yedek arama sorgusu yazın',
        backgroundColor: const Color(0xFF1A1A1A),
        colorText: Colors.white,
      );
      return;
    }
    setState(() => _isSaving = true);

    final colors = <String>[];
    if (_color1Ctrl.text.trim().isNotEmpty) colors.add(_color1Ctrl.text.trim());
    if (_color2Ctrl.text.trim().isNotEmpty) colors.add(_color2Ctrl.text.trim());

    final data = {
      'name': _nameCtrl.text.trim(),
      'shortName': _shortNameCtrl.text.trim(),
      'logoUrl': _logoUrlCtrl.text.trim(),
      'league': _leagueCtrl.text.trim(),
      'order': int.tryParse(_orderCtrl.text.trim()) ?? 99,
      'colors': colors,
      'twitterAccounts': List<String>.from(_accounts),
      'searchQuery': _searchQueryCtrl.text.trim(),
      'followers': 0,
    };

    bool success;
    if (Get.isRegistered<WebAdminController>()) {
      final ctrl = Get.find<WebAdminController>();
      success = isEdit ? await ctrl.updateTeam(widget.team!.id, data) : await ctrl.addTeam(data);
    } else {
      final ctrl = Get.find<AdminController>();
      success = isEdit ? await ctrl.updateTeam(widget.team!.id, data) : await ctrl.addTeam(data);
    }

    setState(() => _isSaving = false);
    if (success) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    final previewColor = _hexToColor(_color1Ctrl.text) ?? AppColors.primary;
    return Scaffold(
      backgroundColor: c.bg,
      appBar: AppBar(
        backgroundColor: c.bg,
        elevation: 0,
        title: Text(
          isEdit ? 'Takımı Düzenle' : 'Yeni Takım Ekle',
          style: TextStyle(
            color: c.textPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 18,
            fontFamily: 'Gilroy',
          ),
        ),
        iconTheme: IconThemeData(color: c.textPrimary),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
            )
          else
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: TextButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check, color: AppColors.primary, size: 18),
                label: const Text('Kaydet', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontFamily: 'Gilroy', fontSize: 15)),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Canlı önizleme kartı
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.divider),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: previewColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: _logoUrlCtrl.text.trim().isNotEmpty
                        ? ClipOval(
                            child: Image.network(
                              _logoUrlCtrl.text.trim(),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Center(
                                child: Text(
                                  _shortNameCtrl.text.isNotEmpty ? _shortNameCtrl.text[0].toUpperCase() : '?',
                                  style: TextStyle(color: previewColor, fontWeight: FontWeight.w800, fontSize: 18, fontFamily: 'Gilroy'),
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              _shortNameCtrl.text.isNotEmpty ? _shortNameCtrl.text[0].toUpperCase() : '?',
                              style: TextStyle(color: previewColor, fontWeight: FontWeight.w800, fontSize: 18, fontFamily: 'Gilroy'),
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameCtrl.text.trim().isNotEmpty ? _nameCtrl.text.trim() : 'Takım önizlemesi',
                          style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Gilroy'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Aşağıdaki alanları doldurdukça burası güncellenir',
                          style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Gilroy'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _SectionTitle(icon: Icons.info_outline, text: 'Temel Bilgiler'),
            const SizedBox(height: 4),
            _SectionHint('Takımın adı, kısa adı ve hangi ligde oynadığı bilgisi'),
            const SizedBox(height: 12),
            _Field(
              controller: _nameCtrl,
              label: 'Takım Adı',
              hint: 'örn: Galatasaray',
              icon: Icons.groups_outlined,
              validator: _required,
            ),
            const SizedBox(height: 10),
            _Field(
              controller: _shortNameCtrl,
              label: 'Kısa Ad',
              hint: 'örn: GS  —  listelerde rozet olarak görünür',
              icon: Icons.sell_outlined,
              validator: _required,
            ),
            const SizedBox(height: 10),
            _Field(
              controller: _leagueCtrl,
              label: 'Lig',
              hint: 'örn: Süper Lig',
              icon: Icons.emoji_events_outlined,
            ),
            const SizedBox(height: 10),
            _Field(
              controller: _orderCtrl,
              label: 'Sıralama Numarası',
              hint: 'Küçük sayı önce listelenir, örn: 1',
              icon: Icons.sort,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),

            _SectionTitle(icon: Icons.image_outlined, text: 'Görsel ve Renkler'),
            const SizedBox(height: 4),
            _SectionHint('Takımın logosu ve marka renkleri — uygulamada rozet ve vurgu rengi olarak kullanılır'),
            const SizedBox(height: 12),
            _Field(
              controller: _logoUrlCtrl,
              label: 'Logo Görsel Linki',
              hint: 'https://... ile başlayan bir görsel adresi yapıştırın',
              icon: Icons.link,
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _ColorField(
                    controller: _color1Ctrl,
                    label: 'Ana Renk',
                    hint: '#E8231A',
                    color: _hexToColor(_color1Ctrl.text),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ColorField(
                    controller: _color2Ctrl,
                    label: 'İkincil Renk (opsiyonel)',
                    hint: '#FFD700',
                    color: _hexToColor(_color2Ctrl.text),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _SectionTitle(icon: Icons.alternate_email, text: 'Twitter Hesapları'),
            const SizedBox(height: 4),
            _SectionHint(
              'Bu takım hakkında tweet çekilecek Twitter/X hesapları. "@" işareti yazmanıza gerek yok, birden fazla hesap ekleyebilirsiniz.',
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: _accountCtrl,
                    label: 'Kullanıcı Adı',
                    hint: 'örn: FabrizioRomano',
                    icon: Icons.alternate_email,
                    onSubmitted: (_) => _addAccount(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _addAccount,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_accounts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20),
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.divider, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Icon(Icons.alternate_email, color: c.textMuted, size: 22),
                    const SizedBox(height: 6),
                    Text(
                      'Henüz hesap eklenmedi',
                      style: TextStyle(color: c.textMuted, fontSize: 13, fontFamily: 'Gilroy', fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Yukarıdan bir kullanıcı adı ekleyin',
                      style: TextStyle(color: c.textMuted, fontSize: 11, fontFamily: 'Gilroy'),
                    ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: c.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: c.divider),
                ),
                child: Column(
                  children: _accounts.asMap().entries.map((entry) {
                    final i = entry.key;
                    final handle = entry.value;
                    return Column(
                      children: [
                        ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          leading: Icon(Icons.alternate_email, color: c.textMuted, size: 18),
                          title: Text(
                            handle,
                            style: TextStyle(color: c.textPrimary, fontFamily: 'Gilroy', fontWeight: FontWeight.w600),
                          ),
                          trailing: GestureDetector(
                            onTap: () => _removeAccount(handle),
                            child: const Icon(Icons.close, color: AppColors.red, size: 18),
                          ),
                        ),
                        if (i < _accounts.length - 1)
                          Divider(height: 1, color: c.divider),
                      ],
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 24),

            _SectionTitle(icon: Icons.search, text: 'Yedek Arama (İsteğe Bağlı)'),
            const SizedBox(height: 4),
            _SectionHint(
              'Takıma özel Twitter hesabı bulunmuyorsa, tweetler bu arama sorgusuyla toplanır. Boş bırakabilirsiniz, ancak yukarıda en az bir hesap veya bu sorgu dolu olmalı.',
            ),
            const SizedBox(height: 12),
            _Field(
              controller: _searchQueryCtrl,
              label: 'Arama Sorgusu',
              hint: '(#Galatasaray OR from:GalatasaraySK) lang:tr',
              icon: Icons.search,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Bu alan zorunlu' : null;
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String text;
  const _SectionTitle({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: c.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            fontFamily: 'Gilroy',
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _SectionHint extends StatelessWidget {
  final String text;
  const _SectionHint(this.text);

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Text(
      text,
      style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Gilroy', height: 1.4),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;

  const _Field({
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.validator,
    this.keyboardType,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      onFieldSubmitted: onSubmitted,
      style: TextStyle(color: c.textPrimary, fontFamily: 'Gilroy', fontSize: 14),
      decoration: InputDecoration(
        labelText: validator != null ? '$label *' : label,
        hintText: hint,
        hintStyle: TextStyle(color: c.textMuted.withValues(alpha: 0.6), fontFamily: 'Gilroy', fontSize: 13),
        labelStyle: TextStyle(color: c.textMuted, fontFamily: 'Gilroy', fontSize: 13),
        prefixIcon: icon != null ? Icon(icon, color: c.textMuted, size: 18) : null,
        filled: true,
        fillColor: c.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class _ColorField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Color? color;

  const _ColorField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return TextFormField(
      controller: controller,
      style: TextStyle(color: c.textPrimary, fontFamily: 'Gilroy', fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: c.textMuted.withValues(alpha: 0.6), fontFamily: 'Gilroy', fontSize: 13),
        labelStyle: TextStyle(color: c.textMuted, fontFamily: 'Gilroy', fontSize: 13),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color ?? c.divider,
              shape: BoxShape.circle,
              border: Border.all(color: c.divider),
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44, minHeight: 20),
        filled: true,
        fillColor: c.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}
