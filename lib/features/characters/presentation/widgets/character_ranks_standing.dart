import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/widgets/character/character_section_panel.dart';
import 'package:mycharacterlist/core/theme/app_typography.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character_ranking_display.dart';

class CharacterRanksStanding extends StatelessWidget {
  const CharacterRanksStanding({
    super.key,
    required this.rankings,
  });

  final List<CharacterRankingDisplay> rankings;

  @override
  Widget build(BuildContext context) {
    return CharacterSectionPanel(
      title: 'Ranks standing (positions):',
      child: rankings.isEmpty
          ? const Text(
              'Not ranked in any list',
              style: AppTypography.characterSectionEmpty,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < rankings.length; index++) ...[
                  if (index > 0) const SizedBox(height: 10),
                  _RankingRow(ranking: rankings[index]),
                ],
              ],
            ),
    );
  }
}

class _RankingRow extends StatelessWidget {
  const _RankingRow({required this.ranking});

  final CharacterRankingDisplay ranking;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '▪ ${ranking.listName}: ',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontFamily: 'JockeyOne',
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: '#${ranking.position}',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontFamily: 'JimNightshade',
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
