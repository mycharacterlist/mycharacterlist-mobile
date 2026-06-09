import 'package:mycharacterlist/features/characters/data/sources/local/character_reference_local_data_source.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_reference_repository.dart';
import 'package:mycharacterlist/features/characters/domain/entities/grade_definition.dart';

class CharacterReferenceRepositoryImpl implements CharacterReferenceRepository {
  const CharacterReferenceRepositoryImpl({required this.localDataSource});

  final CharacterReferenceLocalDataSource localDataSource;

  @override
  Future<List<String>> getAnimeTitles() => localDataSource.getAnimeTitles();

  @override
  Future<List<String>> getArchetypes() => localDataSource.getArchetypes();

  @override
  Future<List<GradeDefinition>> getGradeDefinitions() {
    return localDataSource.getGradeDefinitions();
  }

  @override
  Future<bool> containsArchetype(String name) {
    return localDataSource.containsArchetype(name);
  }

  @override
  Future<String> ensureAnimeTitle(String name) {
    if (name.trim().isEmpty) {
      throw StateError('Anime title cannot be empty.');
    }
    return localDataSource.ensureAnimeTitle(name);
  }

  @override
  Future<void> deleteUnusedAnimeTitles() {
    return localDataSource.deleteUnusedAnimeTitles();
  }

  @override
  Future<void> addArchetype(String name) {
    if (name.trim().isEmpty) {
      throw StateError('Archetype cannot be empty.');
    }
    return localDataSource.addArchetype(name);
  }

  @override
  Future<void> addGradeDefinition({
    required String name,
    required int maxValue,
  }) {
    if (name.trim().isEmpty) {
      throw StateError('Grade name cannot be empty.');
    }
    if (maxValue <= 0) {
      throw StateError('Grade maximum must be greater than zero.');
    }
    return localDataSource.addGradeDefinition(name: name, maxValue: maxValue);
  }
}
