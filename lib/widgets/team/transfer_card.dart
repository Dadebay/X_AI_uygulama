import 'package:flutter/material.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:hugeicons/hugeicons.dart';

class TransferCard extends StatelessWidget {
  final Map<String, String> data;
  const TransferCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(data['name']!, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 15, fontFamily: 'Gilroy')),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(data['from']!, style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Gilroy')),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(HugeIcons.strokeRoundedArrowRight01, color: AppColors.primary, size: 16),
              ),
              Text(data['to']!, style: TextStyle(color: c.textSecondary, fontSize: 13, fontFamily: 'Gilroy')),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: AppColors.lightPrimary, borderRadius: BorderRadius.circular(6)),
                child: Text(data['fee']!, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Gilroy')),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(data['status']!, style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Gilroy')),
        ],
      ),
    );
  }
}
