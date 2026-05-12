import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranked_character.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list.dart';

abstract interface class RankingListRepository {
  Future<List<RankingList>> getLists();

  Future<RankingList?> getListById(String id);

  Future<void> saveList(RankingList list);

  Future<void> deleteList(String id);

  Future<List<RankedCharacter>> getRankedCharacters(String listId);

  Future<List<RankedCharacter>> getCharacterRankings(String characterId);

  Future<void> addCharacterToList({
    required String listId,
    required String characterId,
    int? position,
  });

  Future<void> removeCharacterFromList({
    required String listId,
    required String characterId,
  });

  Future<void> moveCharacter({
    required String listId,
    required String characterId,
    required int newPosition,
  });
}
