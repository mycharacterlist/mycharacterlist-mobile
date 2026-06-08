class CharacterFilters {
  const CharacterFilters({
    this.animeTitles = const {},
    this.archetypes = const {},
    this.genders = const {},
    this.positions = const {},
    this.minOverallGrade = 0,
    this.maxOverallGrade = 10,
  });

  final Set<String> animeTitles;
  final Set<String> archetypes;
  final Set<String> genders;
  final Set<String> positions;
  final double minOverallGrade;
  final double maxOverallGrade;

  bool get hasGradeFilter => minOverallGrade > 0 || maxOverallGrade < 10;
}
