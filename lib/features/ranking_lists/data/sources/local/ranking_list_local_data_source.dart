import 'package:sqflite/sqflite.dart';

import 'package:mycharacterlist/core/database/app_database.dart';
import 'package:mycharacterlist/features/ranking_lists/data/models/ranking_list_patch_entry_model.dart';
import 'package:mycharacterlist/features/ranking_lists/data/models/ranking_list_patch_model.dart';
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

  Future<List<RankingListPatchModel>> getPatchesForList(String listId) async {
    final database = await _appDatabase.database;
    final patches = await database.query(
      'ranking_list_patches',
      where: 'list_id = ?',
      whereArgs: [listId],
      orderBy: 'created_at DESC',
    );

    return patches.map(RankingListPatchModel.fromDatabase).toList();
  }

  Future<RankingListPatchModel?> getPatchById(String patchId) async {
    final database = await _appDatabase.database;
    final patches = await database.query(
      'ranking_list_patches',
      where: 'id = ?',
      whereArgs: [patchId],
      limit: 1,
    );

    if (patches.isEmpty) {
      return null;
    }

    return RankingListPatchModel.fromDatabase(patches.first);
  }

  Future<List<RankingListPatchEntryModel>> getPatchEntries(String patchId) async {
    final database = await _appDatabase.database;
    final entries = await database.query(
      'ranking_list_patch_entries',
      where: 'patch_id = ?',
      whereArgs: [patchId],
      orderBy: 'position ASC',
    );

    return entries.map(RankingListPatchEntryModel.fromDatabase).toList();
  }

  Future<void> savePatch(
    RankingListPatchModel patch,
    List<RankingListPatchEntryModel> entries,
  ) async {
    final database = await _appDatabase.database;

    await database.transaction((transaction) async {
      await transaction.insert(
        'ranking_list_patches',
        patch.toDatabase(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await transaction.delete(
        'ranking_list_patch_entries',
        where: 'patch_id = ?',
        whereArgs: [patch.id],
      );

      for (final entry in entries) {
        await transaction.insert(
          'ranking_list_patch_entries',
          entry.toDatabase(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<void> deletePatch(String patchId) async {
    final database = await _appDatabase.database;

    await database.delete(
      'ranking_list_patches',
      where: 'id = ?',
      whereArgs: [patchId],
    );
  }
}
