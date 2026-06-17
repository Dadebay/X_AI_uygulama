import 'package:flutter/material.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/models/tweet_model.dart';

class TrendCard extends StatelessWidget {
  final TrendTopic topic;
  final VoidCallback? onTap;

  const TrendCard({super.key, required this.topic, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.divider, width: 0.5),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text('${topic.rank}', style: TextStyle(color: c.textMuted, fontWeight: FontWeight.w700, fontSize: 13, fontFamily: 'Gilroy')),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('#${topic.name}', style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Gilroy')),
                if (topic.postCount.isNotEmpty)
                  Text(topic.postCount, style: TextStyle(color: c.textMuted, fontSize: 12, fontFamily: 'Gilroy')),
              ],
            ),
          ),
          if (onTap != null)
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.lightPrimary, borderRadius: BorderRadius.circular(8)),
                child: const Text('Gör', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600, fontFamily: 'Gilroy')),
              ),
            ),
        ],
      ),
    ),
    );
  }
}
