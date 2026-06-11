import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/characters/domain/entities/grade_definition.dart';
import 'package:mycharacterlist/features/characters/domain/services/character_grade_service.dart';
import 'package:mycharacterlist/features/library/domain/entities/character_filters.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranked_character.dart';

class CharacterFilterService {
  const CharacterFilterService._();

  static bool matches({
    required Character character,
    required CharacterFilters filters,
    required List<GradeDefinition> gradeDefinitions,
    required List<RankedCharacter> rankings,
  }) {
    if (filters.animeTitles.isNotEmpty &&
        !filters.animeTitles.contains(character.sourceTitle)) {
      return false;
    }

    if (filters.archetypes.isNotEmpty &&
        !filters.archetypes.contains(character.archetype)) {
      return false;
    }

    if (filters.genders.isNotEmpty &&
        !filters.genders.contains(character.gender)) {
      return false;
    }

    if (filters.hasGradeFilter &&
        !_matchesOverallGrade(character, filters, gradeDefinitions)) {
      return false;
    }

    return _matchesPosition(filters.positions, rankings);
  }

  static bool _matchesOverallGrade(
    Character character,
    CharacterFilters filters,
    List<GradeDefinition> definitions,
  ) {
    final overallGrade = CharacterGradeService.calculateOverall(
      definitions: definitions,
      grades: character.grades,
    );

    if (overallGrade == null) {
      return false;
    }

    return overallGrade >= filters.minOverallGrade &&
        overallGrade <= filters.maxOverallGrade;
  }

  static bool _matchesPosition(
    Set<String> positions,
    List<RankedCharacter> rankings,
  ) {
    if (positions.isEmpty) {
      return true;
    }

    return (positions.contains('#1') &&
            rankings.any((ranking) => ranking.position == 1)) ||
        (positions.contains('Podium') &&
            rankings.any((ranking) => ranking.position <= 3)) ||
        (positions.contains('In lists') && rankings.isNotEmpty) ||
        (positions.contains('Out of lists') && rankings.isEmpty);
  }
}
