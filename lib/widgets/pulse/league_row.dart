import 'package:flutter/material.dart';
import 'package:atlas/themes/colors.dart';
import 'package:atlas/themes/tc.dart';

class LeagueRow extends StatelessWidget {
  final String rank;
  final String team;
  final String matches;
  final String points;
  final bool isLead;

  const LeagueRow({
    super.key,
    required this.rank,
    required this.team,
    required this.matches,
    required this.points,
    this.isLead = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = Tc.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(rank,
                style: TextStyle(
                    color: isLead ? AppColors.primary : c.textMuted,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    fontFamily: 'Gilroy')),
          ),
          Expanded(
            child: Text(team, style: TextStyle(color: c.textPrimary, fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Gilroy')),
          ),
          Text('$matches Maç', style: TextStyle(color: c.textSecondary, fontSize: 12, fontFamily: 'Gilroy')),
          const SizedBox(width: 14),
          Text('$points Puan',
              style: TextStyle(
                  color: isLead ? AppColors.primary : c.textPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  fontFamily: 'Gilroy')),
        ],
      ),
    );
  }
}
