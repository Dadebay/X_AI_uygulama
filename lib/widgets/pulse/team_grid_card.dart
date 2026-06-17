import 'package:flutter/material.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';
import 'package:atlas/models/tweet_model.dart';

class TeamGridCard extends StatelessWidget {
  final TeamModel team;
  final VoidCallback onTap;

  const TeamGridCard({super.key, required this.team, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.divider, width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: c.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: c.divider, width: 1),
              ),
              child: ClipOval(
                child: team.logoAsset.isNotEmpty
                    ? Image.asset(team.logoAsset, width: 52, height: 52, fit: BoxFit.cover)
                    : Center(
                        child: Text(
                          team.shortName,
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 14, fontFamily: 'Gilroy'),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                team.name,
                style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 12, fontFamily: 'Gilroy'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            if (team.colors.isNotEmpty) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: team.colors
                    .take(2)
                    .map((col) => Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(color: col, shape: BoxShape.circle),
                        ))
                    .toList(),
              ),
            ] else ...[
              const SizedBox(height: 2),
              Text(team.league, style: TextStyle(color: c.textMuted, fontSize: 10, fontFamily: 'Gilroy'), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ],
        ),
      ),
    );
  }
}
