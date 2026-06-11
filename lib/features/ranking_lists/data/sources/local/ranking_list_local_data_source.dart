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
      orderBy: 'created_at ASC',
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
    final database = await _appDatabase.database;
    final rankedCharacters = await database.query(
      'ranked_characters',
      where: 'character_id = ?',
      whereArgs: [characterId],
      orderBy: 'position ASC',
    );

    return rankedCharacters.map(RankedCharacterModel.fromDatabase).toList();
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
