import 'package:sqflite/sqflite.dart';

import 'package:mycharacterlist/core/database/app_database.dart';
import 'package:mycharacterlist/features/characters/data/models/character_model.dart';

class CharacterLocalDataSource {
  const CharacterLocalDataSource({required AppDatabase appDatabase})
    : _appDatabase = appDatabase;

  final AppDatabase _appDatabase;

  Future<List<CharacterModel>> getCharacters() async {
    final database = await _appDatabase.database;
    final characters = await database.query(
      'characters',
      orderBy: 'name COLLATE NOCASE ASC',
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

  Future<void> saveCharacter(CharacterModel character) async {
    final database = await _appDatabase.database;

    await database.transaction((transaction) async {
      await transaction.insert(
        'characters',
        character.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

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
          'grade_key': entry.key,
          'grade_value': entry.value,
        });
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

    return CharacterModel.fromDatabase(
      character,
      galleryImagePaths: galleryImagePaths,
      grades: grades,
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
      columns: ['grade_key', 'grade_value'],
      where: 'character_id = ?',
      whereArgs: [characterId],
      orderBy: 'grade_key COLLATE NOCASE ASC',
    );

    return {
      for (final grade in grades)
        grade['grade_key']! as String: grade['grade_value']! as int,
    };
  }
}
