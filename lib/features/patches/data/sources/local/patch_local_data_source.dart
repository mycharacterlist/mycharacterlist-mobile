import 'package:sqflite/sqflite.dart';

import 'package:mycharacterlist/core/database/app_database.dart';
import 'package:mycharacterlist/features/patches/data/models/ranking_list_patch_entry_model.dart';
import 'package:mycharacterlist/features/patches/data/models/ranking_list_patch_model.dart';

class PatchLocalDataSource {
  const PatchLocalDataSource({
    required AppDatabase appDatabase,
  }) : _appDatabase = appDatabase;

  final AppDatabase _appDatabase;

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
