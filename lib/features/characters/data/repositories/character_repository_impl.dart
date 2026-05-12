import 'package:mycharacterlist/core/storage/local_file_storage.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
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
  Future<Character?> getCharacterById(String id) {
    return _localDataSource.getCharacterById(id);
  }

  @override
  Future<List<Character>> searchCharacters(String query) async {
    final characters = await _localDataSource.getCharacters();
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty) {
      return characters;
    }

    return characters.where((character) {
      final name = character.name.toLowerCase();
      final sourceTitle = character.sourceTitle.toLowerCase();

      return name.contains(normalizedQuery) ||
          sourceTitle.contains(normalizedQuery);
    }).toList();
  }

  @override
  Future<void> saveCharacter(Character character) {
    return _localDataSource.saveCharacter(CharacterModel.fromEntity(character));
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
  }
}
