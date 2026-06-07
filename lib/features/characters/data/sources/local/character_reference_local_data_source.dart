import 'package:sqflite/sqflite.dart';

import 'package:mycharacterlist/core/database/app_database.dart';
import 'package:mycharacterlist/features/characters/domain/entities/grade_definition.dart';
import 'package:mycharacterlist/features/characters/data/models/grade_definition_model.dart';

class CharacterReferenceLocalDataSource {
  const CharacterReferenceLocalDataSource({required AppDatabase appDatabase})
    : _appDatabase = appDatabase;

  final AppDatabase _appDatabase;

  Future<List<String>> getAnimeTitles() => _getNames('anime_titles');

  Future<List<String>> getArchetypes() => _getNames('archetypes');

  Future<List<GradeDefinition>> getGradeDefinitions() async {
    final database = await _appDatabase.database;
    final rows = await database.query(
      'grade_definitions',
      orderBy: 'position ASC',
    );

    return rows.map(GradeDefinitionModel.fromDatabase).toList();
  }

  Future<bool> containsAnimeTitle(String name) =>
      _containsName('anime_titles', name);

  Future<bool> containsArchetype(String name) =>
      _containsName('archetypes', name);

  Future<void> addAnimeTitle(String name) => _addName('anime_titles', name);

  Future<void> addArchetype(String name) => _addName('archetypes', name);

  Future<void> addGradeDefinition({
    required String name,
    required int maxValue,
  }) async {
    final database = await _appDatabase.database;
    final positionResult = await database.rawQuery(
      'SELECT COALESCE(MAX(position), 0) + 1 AS next_position '
      'FROM grade_definitions',
    );
    final nextPosition = positionResult.first['next_position']! as int;

    try {
      await database.insert('grade_definitions', {
        'id': 'grade_${DateTime.now().microsecondsSinceEpoch}',
        'name': name.trim(),
        'max_value': maxValue,
        'position': nextPosition,
      });
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        throw StateError('${name.trim()} already exists.');
      }
      rethrow;
    }
  }

  Future<List<String>> _getNames(String table) async {
    final database = await _appDatabase.database;
    final rows = await database.query(
      table,
      columns: ['name'],
      orderBy: 'name',
    );
    return rows.map((row) => row['name']! as String).toList();
  }

  Future<void> _addName(String table, String name) async {
    final database = await _appDatabase.database;
    final normalizedName = name.trim();

    try {
      await database.insert(table, {
        'id': '${table}_${DateTime.now().microsecondsSinceEpoch}',
        'name': normalizedName,
        'created_at': DateTime.now().toIso8601String(),
      });
    } on DatabaseException catch (error) {
      if (error.isUniqueConstraintError()) {
        throw StateError('$normalizedName already exists.');
      }
      rethrow;
    }
  }

  Future<bool> _containsName(String table, String name) async {
    final database = await _appDatabase.database;
    final rows = await database.query(
      table,
      columns: ['id'],
      where: 'name = ? COLLATE NOCASE',
      whereArgs: [name.trim()],
      limit: 1,
    );
    return rows.isNotEmpty;
  }
}
