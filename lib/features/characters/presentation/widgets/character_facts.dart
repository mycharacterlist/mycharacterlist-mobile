import 'package:flutter/material.dart';

import 'package:mycharacterlist/app/widgets/character/character_section_panel.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character_fact.dart';

class CharacterFacts extends StatelessWidget {
  const CharacterFacts({
    super.key,
    required this.facts,
  });

  final List<CharacterFact> facts;

  @override
  Widget build(BuildContext context) {
    if (facts.isEmpty) {
      return const SizedBox.shrink();
    }

    return CharacterSectionPanel(
      title: 'Facts:',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var index = 0; index < facts.length; index++) ...[
            if (index > 0) const SizedBox(height: 10),
            _FactRow(fact: facts[index]),
          ],
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  const _FactRow({required this.fact});

  final CharacterFact fact;

  String get _value {
    if (fact.type == CharacterFactType.grade) {
      return '${fact.numericValue ?? 0}/${fact.maxValue ?? 0}';
    }

    return fact.textValue?.trim().isNotEmpty == true
        ? fact.textValue!.trim()
        : '—';
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '${fact.key}: ',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontFamily: 'JockeyOne',
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: _value,
            style: const TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontFamily: 'JimNightshade',
            ),
          ),
        ],
      ),
    );
  }
}
