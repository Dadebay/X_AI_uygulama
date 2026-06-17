import 'package:flutter/material.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:hugeicons/hugeicons.dart';

class CategoryChips extends StatelessWidget {
  final List<Map<String, String>> categories;
  final int selected;
  final ValueChanged<int> onSelect;

  const CategoryChips({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return SizedBox(
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final isSelected = selected == i;
          final label = categories[i]['label']!;
          return GestureDetector(
            onTap: () => onSelect(i),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 58, height: 58,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: _gradient(label),
                      color: _color(label),
                    ),
                    child: Center(child: _logo(label)),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? c.textPrimary : c.textSecondary,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12,
                    fontFamily: 'Gilroy',
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Gradient? _gradient(String label) {
    if (label == 'UCL') return const RadialGradient(colors: [Color(0xFF001A4E), Color(0xFF080D1A)], radius: 0.8);
    return null;
  }

  Color _color(String label) {
    if (label == 'Tümü') return const Color(0xFF13281E);
    if (label == 'Süper Lig') return const Color(0xFF1F1F1F);
    if (label == 'GS' || label == 'FB' || label == 'BJK') return Colors.transparent;
    return const Color(0xFF242424);
  }

  Widget _logo(String label) {
    if (label == 'Tümü') return const Icon(HugeIcons.strokeRoundedPulse01, color: AppColors.primary, size: 24);
    if (label == 'GS') return ClipOval(child: Image.asset('assets/images/Galatasaray_SK_football_logo.png', width: 52, height: 52, fit: BoxFit.cover));
    if (label == 'FB') return ClipOval(child: Image.asset('assets/images/Fenerbah.png', width: 52, height: 52, fit: BoxFit.cover));
    if (label == 'BJK') return ClipOval(child: Image.asset('assets/images/kartal.png', width: 52, height: 52, fit: BoxFit.cover));
    if (label == 'Süper Lig') return const Icon(HugeIcons.strokeRoundedAward01, color: Color(0xFFFFD700), size: 24);
    if (label == 'UCL') return const Icon(HugeIcons.strokeRoundedGlobe, color: Color(0xFF1D9BF0), size: 24);
    return const SizedBox.shrink();
  }
}
