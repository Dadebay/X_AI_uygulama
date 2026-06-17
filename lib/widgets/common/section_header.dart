import 'package:flutter/material.dart';
import 'package:atlas/themes/tc.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader(this.title, {super.key, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    if (action == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
        child: Text(
          title,
          style: TextStyle(color: c.textMuted, fontSize: 12, fontWeight: FontWeight.w700, fontFamily: 'Gilroy', letterSpacing: 0.5),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w800, fontSize: 16, fontFamily: 'Gilroy')),
          GestureDetector(
            onTap: onAction,
            child: Text(action!, style: const TextStyle(color: Color(0xFF22B241), fontSize: 13, fontFamily: 'Gilroy', fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
