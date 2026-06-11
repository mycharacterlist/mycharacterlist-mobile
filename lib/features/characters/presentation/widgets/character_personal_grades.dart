import 'package:flutter/material.dart';

import 'package:mycharacterlist/features/characters/domain/entities/grade_definition.dart';
import 'package:mycharacterlist/features/characters/domain/services/character_grade_service.dart';

class CharacterPersonalGrades extends StatelessWidget {
  const CharacterPersonalGrades({
    super.key,
    required this.definitions,
    required this.grades,
  });

  final List<GradeDefinition> definitions;
  final Map<String, int> grades;

  @override
  Widget build(BuildContext context) {
    final sortedDefinitions = [...definitions]
      ..sort((left, right) => left.position.compareTo(right.position));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: Color(0xFFECEBEB),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal grades:',
            style: TextStyle(
              fontSize: 32,
              color: Colors.black,
              fontFamily: 'Joan',
            ),
          ),
          const SizedBox(height: 10),
          if (sortedDefinitions.isEmpty)
            const Text(
              'No grades yet',
              style: TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontFamily: 'Joan',
              ),
            )
          else ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var index = 0; index < sortedDefinitions.length; index++) ...[
                  if (index > 0) const SizedBox(height: 10),
                  _GradeRow(
                    title: sortedDefinitions[index].name,
                    grade:
                        '${grades[sortedDefinitions[index].id] ?? 0}/${sortedDefinitions[index].maxValue}',
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            _OverallRow(
              grade: CharacterGradeService.formatOverall(
                CharacterGradeService.calculateOverall(
                      definitions: sortedDefinitions,
                      grades: grades,
                    ) ??
                    0,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _OverallRow extends StatelessWidget {
  const _OverallRow({required this.grade});

  final String grade;

  static const _underline = TextDecoration.underline;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: 'Overall',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontFamily: 'JockeyOne',
              fontWeight: FontWeight.bold,
              decoration: _underline,
            ),
          ),
          TextSpan(
            text: ': ',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontFamily: 'JockeyOne',
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: grade,
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

class _GradeRow extends StatelessWidget {
  const _GradeRow({
    required this.title,
    required this.grade,
  });

  final String title;
  final String grade;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$title: ',
            style: const TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontFamily: 'JockeyOne',
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: grade,
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
