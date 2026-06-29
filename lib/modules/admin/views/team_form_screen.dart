import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:atlas/models/tweet_model.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/modules/admin/controllers/admin_controller.dart';

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

  void _addAccount() {
    final handle = _accountCtrl.text.trim().replaceAll('@', '');
    if (handle.isEmpty) return;
    if (_accounts.contains(handle)) return;
    setState(() {
      _accounts.add(handle);
      _accountCtrl.clear();
    });
  }

  void _removeAccount(String handle) {
    setState(() => _accounts.remove(handle));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
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

    final ctrl = Get.find<AdminController>();
    bool success;
    if (isEdit) {
      success = await ctrl.updateTeam(widget.team!.id, data);
    } else {
      success = await ctrl.addTeam(data);
    }

    setState(() => _isSaving = false);
    if (success) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
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
            TextButton(
              onPressed: _save,
              child: const Text('Kaydet', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontFamily: 'Gilroy', fontSize: 15)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionTitle('Temel Bilgiler'),
            const SizedBox(height: 10),
            _Field(controller: _nameCtrl, label: 'Takım Adı (örn: Galatasaray)', validator: _required),
            const SizedBox(height: 10),
            _Field(controller: _shortNameCtrl, label: 'Kısa Ad (örn: GS)', validator: _required),
            const SizedBox(height: 10),
            _Field(controller: _leagueCtrl, label: 'Lig (örn: Süper Lig)'),
            const SizedBox(height: 10),
            _Field(controller: _orderCtrl, label: 'Sıra (örn: 1)', keyboardType: TextInputType.number),
            const SizedBox(height: 20),

            _SectionTitle('Görsel'),
            const SizedBox(height: 10),
            _Field(controller: _logoUrlCtrl, label: 'Logo URL (https://...)'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: _Field(controller: _color1Ctrl, label: 'Renk 1 (örn: #E8231A)')),
                const SizedBox(width: 10),
                Expanded(child: _Field(controller: _color2Ctrl, label: 'Renk 2 (örn: #FFD700)')),
              ],
            ),
            const SizedBox(height: 20),

            _SectionTitle('Twitter Hesapları'),
            const SizedBox(height: 6),
            Text(
              'Bu takım için tweet çekilecek hesaplar (@olmadan)',
              style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Gilroy'),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: _accountCtrl,
                    label: 'Twitter kullanıcı adı (örn: FabrizioRomano)',
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
            const SizedBox(height: 10),
            if (_accounts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Henüz hesap eklenmedi',
                  style: TextStyle(color: c.textMuted, fontSize: 13, fontFamily: 'Gilroy'),
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
                            child: Icon(Icons.close, color: AppColors.red, size: 18),
                          ),
                        ),
                        if (i < _accounts.length - 1)
                          Divider(height: 1, color: c.divider),
                      ],
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 20),

            _SectionTitle('Yedek Arama (İsteğe Bağlı)'),
            const SizedBox(height: 6),
            Text(
              'Twitter hesabı yoksa bu hashtag sorgusu kullanılır',
              style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Gilroy'),
            ),
            const SizedBox(height: 10),
            _Field(controller: _searchQueryCtrl, label: 'örn: (#Galatasaray OR from:GalatasaraySK) lang:tr'),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Bu alan zorunlu' : null;
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Text(
      text,
      style: TextStyle(
        color: c.textSecondary,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        fontFamily: 'Gilroy',
        letterSpacing: 0.5,
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onSubmitted;

  const _Field({
    required this.controller,
    required this.label,
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
        labelText: label,
        labelStyle: TextStyle(color: c.textMuted, fontFamily: 'Gilroy', fontSize: 13),
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
