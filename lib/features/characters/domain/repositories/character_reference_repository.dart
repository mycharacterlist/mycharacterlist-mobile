import 'package:mycharacterlist/features/characters/domain/entities/grade_definition.dart';

abstract interface class CharacterReferenceRepository {
  Future<List<String>> getAnimeTitles();

  Future<List<String>> getArchetypes();

  Future<List<GradeDefinition>> getGradeDefinitions();

  Future<bool> containsArchetype(String name);

  Future<String> ensureAnimeTitle(String name);

  Future<String?> findAnimeTitle(String name);

  Future<void> deleteUnusedAnimeTitles();

  Future<void> addArchetype(String name);

  Future<void> addGradeDefinition({
    required String name,
    required int maxValue,
  });
}
