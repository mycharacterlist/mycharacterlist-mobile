import 'package:sqflite/sqflite.dart';

import 'package:mycharacterlist/core/database/app_database.dart';
import 'package:mycharacterlist/features/ranking_lists/data/models/ranked_character_model.dart';
import 'package:mycharacterlist/features/ranking_lists/data/models/ranking_list_model.dart';

class RankingListLocalDataSource {
  const RankingListLocalDataSource({required AppDatabase appDatabase})
    : _appDatabase = appDatabase;

  final AppDatabase _appDatabase;

  Future<List<RankingListModel>> getLists() async {
    final database = await _appDatabase.database;
    final lists = await database.query(
      'ranking_lists',
      orderBy: 'list_order ASC, created_at ASC',
    );

    return lists.map(RankingListModel.fromDatabase).toList();
  }

  Future<RankingListModel?> getListById(String id) async {
    final database = await _appDatabase.database;
    final lists = await database.query(
      'ranking_lists',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (lists.isEmpty) {
      return null;
    }

    return RankingListModel.fromDatabase(lists.first);
  }

  Future<void> saveList(RankingListModel list) async {
    final database = await _appDatabase.database;
    final data = list.toDatabase();

    final updatedRows = await database.update(
      'ranking_lists',
      data,
      where: 'id = ?',
      whereArgs: [list.id],
    );

    if (updatedRows == 0) {
      await database.insert('ranking_lists', data);
    }
  }

  Future<void> deleteList(String id) async {
    final database = await _appDatabase.database;

    await database.delete('ranking_lists', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateListOrder(List<String> orderedListIds) async {
    final database = await _appDatabase.database;

    await database.transaction((transaction) async {
      for (var index = 0; index < orderedListIds.length; index++) {
        await transaction.update(
          'ranking_lists',
          {
            'list_order': index + 1,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [orderedListIds[index]],
        );
      }
    });
  }

  Future<List<RankedCharacterModel>> getRankedCharacters(String listId) async {
    final database = await _appDatabase.database;
    final rankedCharacters = await database.query(
      'ranked_characters',
      where: 'list_id = ?',
      whereArgs: [listId],
      orderBy: 'position ASC',
    );

    return rankedCharacters.map(RankedCharacterModel.fromDatabase).toList();
  }

  Future<List<RankedCharacterModel>> getCharacterRankings(
    String characterId,
  ) async {
    final rankingsByCharacterId = await getCharacterRankingsBatch([characterId]);
    return rankingsByCharacterId[characterId] ?? const [];
  }

  Future<Map<String, List<RankedCharacterModel>>> getCharacterRankingsBatch(
    List<String> characterIds,
  ) async {
    if (characterIds.isEmpty) {
      return const {};
    }

    final database = await _appDatabase.database;
    final placeholders = List.filled(characterIds.length, '?').join(', ');
    final rankedCharacters = await database.query(
      'ranked_characters',
      where: 'character_id IN ($placeholders)',
      whereArgs: characterIds,
      orderBy: 'character_id ASC, position ASC',
    );

    final rankingsByCharacterId = <String, List<RankedCharacterModel>>{};

    for (final rankedCharacter in rankedCharacters) {
      final characterId = rankedCharacter['character_id']! as String;
      rankingsByCharacterId
          .putIfAbsent(characterId, () => [])
          .add(RankedCharacterModel.fromDatabase(rankedCharacter));
    }

    return rankingsByCharacterId;
  }

  Future<List<RankedCharacterModel>> getAllRankedCharacters() async {
    final database = await _appDatabase.database;
    final rankedCharacters = await database.query(
      'ranked_characters',
      orderBy: 'list_id ASC, position ASC',
    );

    return rankedCharacters.map(RankedCharacterModel.fromDatabase).toList();
  }

  Future<void> saveRankedCharacters(
    List<RankedCharacterModel> rankedCharacters,
  ) async {
    final database = await _appDatabase.database;

    await database.transaction((transaction) async {
      await transaction.delete('ranked_characters');

      for (final rankedCharacter in rankedCharacters) {
        await transaction.insert(
          'ranked_characters',
          rankedCharacter.toDatabase(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> replaceRankedCharactersForList(
    String listId,
    List<RankedCharacterModel> rankedCharacters,
  ) async {
    final database = await _appDatabase.database;

    await database.transaction((transaction) async {
      await transaction.delete(
        'ranked_characters',
        where: 'list_id = ?',
        whereArgs: [listId],
      );

      for (final rankedCharacter in rankedCharacters) {
        await transaction.insert(
          'ranked_characters',
          rankedCharacter.toDatabase(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
