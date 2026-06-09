import 'package:mycharacterlist/core/storage/local_file_storage.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character_fact.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_repository.dart';
import 'package:mycharacterlist/features/characters/data/models/character_model.dart';
import 'package:mycharacterlist/features/characters/data/sources/local/character_local_data_source.dart';

class CharacterRepositoryImpl implements CharacterRepository {
  const CharacterRepositoryImpl({
    required CharacterLocalDataSource localDataSource,
    required LocalFileStorage localFileStorage,
  }) : _localDataSource = localDataSource,
       _localFileStorage = localFileStorage;

  final CharacterLocalDataSource _localDataSource;
  final LocalFileStorage _localFileStorage;

  @override
  Future<List<Character>> getCharacters() {
    return _localDataSource.getCharacters();
  }

  @override
  Future<List<Character>> getCharactersPage({
    required int offset,
    required int limit,
  }) {
    return _localDataSource.getCharactersPage(offset: offset, limit: limit);
  }

  @override
  Future<Character?> getCharacterById(String id) {
    return _localDataSource.getCharacterById(id);
  }

  @override
  Future<List<Character>> searchCharacters(String query) {
    if (query.trim().isEmpty) {
      return _localDataSource.getCharacters();
    }

    return _localDataSource.searchCharacters(query);
  }

  @override
  Future<List<Character>> searchCharactersPage(
    String query, {
    required int offset,
    required int limit,
  }) {
    if (query.trim().isEmpty) {
      return _localDataSource.getCharactersPage(offset: offset, limit: limit);
    }

    return _localDataSource.searchCharactersPage(
      query,
      offset: offset,
      limit: limit,
    );
  }

  @override
  Future<void> saveCharacter(Character character) async {
    _validateFacts(character);
    final previousCharacter = await _localDataSource.getCharacterById(
      character.id,
    );

    final mainImagePath = await _localFileStorage.saveOptionalFile(
      character.mainImagePath,
      folder: character.id,
    );
    final galleryImagePaths = await _localFileStorage.saveFiles(
      character.galleryImagePaths,
      folder: character.id,
    );

    final savedCharacter = CharacterModel(
      id: character.id,
      name: character.name,
      sourceTitle: character.sourceTitle,
      description: character.description,
      age: character.age,
      height: character.height,
      japaneseName: character.japaneseName,
      archetype: character.archetype,
      gender: character.gender,
      personalNotes: character.personalNotes,
      mainImagePath: mainImagePath,
      galleryImagePaths: galleryImagePaths,
      grades: character.grades,
      facts: character.facts,
      createdAt: character.createdAt,
      updatedAt: character.updatedAt,
    );

    await _localDataSource.saveCharacter(savedCharacter);

    if (previousCharacter != null) {
      final savedPaths = {
        mainImagePath,
        ...galleryImagePaths,
      }.whereType<String>().toSet();
      final previousPaths = {
        previousCharacter.mainImagePath,
        ...previousCharacter.galleryImagePaths,
      }.whereType<String>().toSet();

      await _localFileStorage.deleteFiles(
        previousPaths.difference(savedPaths).toList(),
      );
    }
  }

  void _validateFacts(Character character) {
    final keys = <String>{};

    for (final fact in character.facts) {
      final normalizedKey = fact.key.trim().toLowerCase();

      if (normalizedKey.isEmpty) {
        throw StateError('Fact name cannot be empty.');
      }

      if (!keys.add(normalizedKey)) {
        throw StateError('Fact names must be unique.');
      }

      switch (fact.type) {
        case CharacterFactType.text:
          if (fact.textValue == null) {
            throw StateError('Text fact must have a value.');
          }
          break;
        case CharacterFactType.grade:
          if (fact.numericValue == null ||
              fact.maxValue == null ||
              fact.maxValue! <= 0 ||
              fact.numericValue! < 0 ||
              fact.numericValue! > fact.maxValue!) {
            throw StateError('Fact grade must be between 0 and its maximum.');
          }
          break;
        default:
          throw StateError('Unsupported fact type.');
      }
    }
  }

  @override
  Future<void> deleteCharacter(String id) async {
    final character = await _localDataSource.getCharacterById(id);

    await _localDataSource.deleteCharacter(id);

    if (character == null) {
      return;
    }

    await _localFileStorage.deleteFile(character.mainImagePath);
    await _localFileStorage.deleteFiles(character.galleryImagePaths);
    await _localFileStorage.deleteFolder(character.id);
  }
}
