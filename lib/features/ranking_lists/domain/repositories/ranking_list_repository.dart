import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list_patch.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list_patch_entry.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranked_character.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list.dart';

abstract interface class RankingListRepository {
  Future<List<RankingList>> getLists();

  Future<RankingList?> getListById(String id);

  Future<void> saveList(RankingList list);

  Future<void> deleteList(String id);

  Future<List<RankedCharacter>> getRankedCharacters(String listId);

  Future<List<RankedCharacter>> getCharacterRankings(String characterId);

  Future<Map<String, List<RankedCharacter>>> getCharacterRankingsBatch(
    List<String> characterIds,
  );

  Future<void> addCharacterToList({
    required String listId,
    required String characterId,
    int? position,
  });

  Future<void> removeCharacterFromList({
    required String listId,
    required String characterId,
  });

  Future<void> removeCharacterFromAllLists(String characterId);

  Future<void> moveCharacter({
    required String listId,
    required String characterId,
    required int newPosition,
  });

  Future<void> replaceListCharacters({
    required String listId,
    required List<({String characterId, int position})> entries,
  });

  Future<String> getSuggestedPatchLabel(String listId);

  Future<RankingListPatch> createPatchFromCurrentList(
    String listId, {
    required String label,
  });

  Future<List<RankingListPatch>> getPatchesForList(String listId);

  Future<RankingListPatch?> getPatchById(String patchId);

  Future<List<RankingListPatchEntry>> getPatchEntries(String patchId);

  Future<void> deletePatch(String patchId);
}
