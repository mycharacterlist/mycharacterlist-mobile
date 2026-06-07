import 'package:mycharacterlist/features/characters/domain/entities/grade_definition.dart';

abstract interface class CharacterReferenceRepository {
  Future<List<String>> getAnimeTitles();

  Future<List<String>> getArchetypes();

  Future<List<GradeDefinition>> getGradeDefinitions();

  Future<bool> containsAnimeTitle(String name);

  Future<bool> containsArchetype(String name);

  Future<void> addAnimeTitle(String name);

  Future<void> addArchetype(String name);

  Future<void> addGradeDefinition({
    required String name,
    required int maxValue,
  });
}
