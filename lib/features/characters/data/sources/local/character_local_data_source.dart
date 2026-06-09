import 'package:sqflite/sqflite.dart';

import 'package:mycharacterlist/core/database/app_database.dart';
import 'package:mycharacterlist/features/characters/data/models/character_model.dart';
import 'package:mycharacterlist/features/characters/data/models/character_fact_model.dart';

class CharacterLocalDataSource {
  const CharacterLocalDataSource({required AppDatabase appDatabase})
    : _appDatabase = appDatabase;

  final AppDatabase _appDatabase;

  Future<List<CharacterModel>> getCharacters() async {
    return _getCharacters();
  }

  Future<List<CharacterModel>> getCharactersPage({
    required int offset,
    required int limit,
  }) {
    return _getCharacters(offset: offset, limit: limit);
  }

  Future<List<CharacterModel>> _getCharacters({int? offset, int? limit}) async {
    final database = await _appDatabase.database;
    final characters = await database.query(
      'characters',
      orderBy: 'name COLLATE NOCASE ASC',
      offset: offset,
      limit: limit,
    );

    final models = <CharacterModel>[];

    for (final character in characters) {
      models.add(await _mapCharacter(database, character));
    }

    return models;
  }

  Future<CharacterModel?> getCharacterById(String id) async {
    final database = await _appDatabase.database;
    final characters = await database.query(
      'characters',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (characters.isEmpty) {
      return null;
    }

    return _mapCharacter(database, characters.first);
  }

  Future<List<CharacterModel>> searchCharacters(String query) async {
    return _searchCharacters(query);
  }

  Future<List<CharacterModel>> searchCharactersPage(
    String query, {
    required int offset,
    required int limit,
  }) {
    return _searchCharacters(query, offset: offset, limit: limit);
  }

  Future<List<CharacterModel>> _searchCharacters(
    String query, {
    int? offset,
    int? limit,
  }) async {
    final database = await _appDatabase.database;
    final normalizedQuery = '%${query.trim()}%';
    final characters = await database.query(
      'characters',
      where: 'name LIKE ? COLLATE NOCASE OR source_title LIKE ? COLLATE NOCASE',
      whereArgs: [normalizedQuery, normalizedQuery],
      orderBy: 'name COLLATE NOCASE ASC',
      offset: offset,
      limit: limit,
    );

    final models = <CharacterModel>[];
    for (final character in characters) {
      models.add(await _mapCharacter(database, character));
    }
    return models;
  }

  Future<void> saveCharacter(CharacterModel character) async {
    final database = await _appDatabase.database;

    await database.transaction((transaction) async {
      final updatedRows = await transaction.update(
        'characters',
        character.toDatabase(),
        where: 'id = ?',
        whereArgs: [character.id],
      );

      if (updatedRows == 0) {
        await transaction.insert('characters', character.toDatabase());
      }

      await transaction.delete(
        'character_gallery_images',
        where: 'character_id = ?',
        whereArgs: [character.id],
      );
      await transaction.delete(
        'character_grades',
        where: 'character_id = ?',
        whereArgs: [character.id],
      );
      await transaction.delete(
        'character_facts',
        where: 'character_id = ?',
        whereArgs: [character.id],
      );

      for (var index = 0; index < character.galleryImagePaths.length; index++) {
        await transaction.insert('character_gallery_images', {
          'id': '${character.id}_gallery_$index',
          'character_id': character.id,
          'image_path': character.galleryImagePaths[index],
          'position': index + 1,
        });
      }

      for (final entry in character.grades.entries) {
        await transaction.insert('character_grades', {
          'id': '${character.id}_grade_${entry.key}',
          'character_id': character.id,
          'grade_definition_id': entry.key,
          'grade_value': entry.value,
        });
      }

      for (var index = 0; index < character.facts.length; index++) {
        final fact = CharacterFactModel.fromEntity(character.facts[index]);
        await transaction.insert(
          'character_facts',
          fact.toDatabase(
            id: '${character.id}_fact_$index',
            characterId: character.id,
          ),
        );
      }
    });
  }

  Future<void> deleteCharacter(String id) async {
    final database = await _appDatabase.database;

    await database.delete('characters', where: 'id = ?', whereArgs: [id]);
  }

  Future<CharacterModel> _mapCharacter(
    DatabaseExecutor database,
    Map<String, Object?> character,
  ) async {
    final characterId = character['id']! as String;
    final galleryImagePaths = await _getGalleryImagePaths(
      database,
      characterId,
    );
    final grades = await _getGrades(database, characterId);
    final facts = await _getFacts(database, characterId);

    return CharacterModel.fromDatabase(
      character,
      galleryImagePaths: galleryImagePaths,
      grades: grades,
      facts: facts,
    );
  }

  Future<List<String>> _getGalleryImagePaths(
    DatabaseExecutor database,
    String characterId,
  ) async {
    final images = await database.query(
      'character_gallery_images',
      columns: ['image_path'],
      where: 'character_id = ?',
      whereArgs: [characterId],
      orderBy: 'position ASC',
    );

    return images.map((image) => image['image_path']! as String).toList();
  }

  Future<Map<String, int>> _getGrades(
    DatabaseExecutor database,
    String characterId,
  ) async {
    final grades = await database.query(
      'character_grades',
      columns: ['grade_definition_id', 'grade_value'],
      where: 'character_id = ?',
      whereArgs: [characterId],
      orderBy: 'grade_definition_id COLLATE NOCASE ASC',
    );

    return {
      for (final grade in grades)
        grade['grade_definition_id']! as String: grade['grade_value']! as int,
    };
  }

  Future<List<CharacterFactModel>> _getFacts(
    DatabaseExecutor database,
    String characterId,
  ) async {
    final facts = await database.query(
      'character_facts',
      where: 'character_id = ?',
      whereArgs: [characterId],
      orderBy: 'fact_key COLLATE NOCASE ASC',
    );

    return facts.map(CharacterFactModel.fromDatabase).toList();
  }
}
