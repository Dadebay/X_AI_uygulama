import 'package:flutter/material.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:hugeicons/hugeicons.dart';

class SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? trailing;
  final VoidCallback onTap;

  const SettingsRow({super.key, required this.icon, required this.label, this.trailing, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Icon(icon, color: c.textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(child: Text(label, style: TextStyle(color: c.textPrimary, fontSize: 15, fontFamily: 'Gilroy'))),
            if (trailing != null) Text(trailing!, style: TextStyle(color: c.textMuted, fontSize: 13, fontFamily: 'Gilroy')),
            const SizedBox(width: 4),
            Icon(HugeIcons.strokeRoundedArrowRight01, color: c.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

class ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleRow({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: TextStyle(color: c.textPrimary, fontSize: 15, fontFamily: 'Gilroy'))),
          Switch(value: value, onChanged: onChanged, activeColor: AppColors.primary),
        ],
      ),
    );
  }
}
