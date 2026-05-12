import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranked_character.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/repositories/ranking_list_repository.dart';
import 'package:mycharacterlist/features/ranking_lists/data/models/ranked_character_model.dart';
import 'package:mycharacterlist/features/ranking_lists/data/models/ranking_list_model.dart';
import 'package:mycharacterlist/features/ranking_lists/data/sources/local/ranking_list_local_data_source.dart';

class RankingListRepositoryImpl implements RankingListRepository {
  const RankingListRepositoryImpl({
    required RankingListLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  final RankingListLocalDataSource _localDataSource;

  @override
  Future<List<RankingList>> getLists() {
    return _localDataSource.getLists();
  }

  @override
  Future<RankingList?> getListById(String id) {
    return _localDataSource.getListById(id);
  }

  @override
  Future<void> saveList(RankingList list) async {
    final lists = await _localDataSource.getLists();
    final duplicateNameExists = lists.any(
      (item) =>
          item.id != list.id &&
          item.name.trim().toLowerCase() == list.name.trim().toLowerCase(),
    );

    if (duplicateNameExists) {
      throw StateError('Ranking list with this name already exists.');
    }

    await _localDataSource.saveList(RankingListModel.fromEntity(list));
  }

  @override
  Future<void> deleteList(String id) {
    return _localDataSource.deleteList(id);
  }

  @override
  Future<List<RankedCharacter>> getRankedCharacters(String listId) {
    return _localDataSource.getRankedCharacters(listId);
  }

  @override
  Future<List<RankedCharacter>> getCharacterRankings(String characterId) {
    return _localDataSource.getCharacterRankings(characterId);
  }

  @override
  Future<void> addCharacterToList({
    required String listId,
    required String characterId,
    int? position,
  }) async {
    final rankedCharacters = await _localDataSource.getAllRankedCharacters();
    final listCharacters = rankedCharacters
        .where((rankedCharacter) => rankedCharacter.listId == listId)
        .toList();
    final alreadyInList = listCharacters.any(
      (rankedCharacter) => rankedCharacter.characterId == characterId,
    );

    if (alreadyInList) {
      throw StateError('Character is already in this list.');
    }

    final insertPosition = _normalizeInsertPosition(
      position: position,
      listLength: listCharacters.length,
    );
    final shiftedCharacters = rankedCharacters.map((rankedCharacter) {
      if (rankedCharacter.listId != listId ||
          rankedCharacter.position < insertPosition) {
        return rankedCharacter;
      }

      return RankedCharacterModel.fromEntity(
        rankedCharacter.copyWith(position: rankedCharacter.position + 1),
      );
    }).toList();

    shiftedCharacters.add(
      RankedCharacterModel(
        id: _createRankingId(listId: listId, characterId: characterId),
        listId: listId,
        characterId: characterId,
        position: insertPosition,
        addedAt: DateTime.now(),
      ),
    );

    await _localDataSource.saveRankedCharacters(shiftedCharacters);
  }

  @override
  Future<void> removeCharacterFromList({
    required String listId,
    required String characterId,
  }) async {
    final rankedCharacters = await _localDataSource.getAllRankedCharacters();
    final removingCharacter = _firstOrNull(
      rankedCharacters.where(
        (rankedCharacter) =>
            rankedCharacter.listId == listId &&
            rankedCharacter.characterId == characterId,
      ),
    );

    if (removingCharacter == null) {
      return;
    }

    final updatedCharacters = rankedCharacters
        .where((rankedCharacter) => rankedCharacter.id != removingCharacter.id)
        .map((rankedCharacter) {
          if (rankedCharacter.listId != listId ||
              rankedCharacter.position <= removingCharacter.position) {
            return rankedCharacter;
          }

          return RankedCharacterModel.fromEntity(
            rankedCharacter.copyWith(position: rankedCharacter.position - 1),
          );
        })
        .toList();

    await _localDataSource.saveRankedCharacters(updatedCharacters);
  }

  @override
  Future<void> moveCharacter({
    required String listId,
    required String characterId,
    required int newPosition,
  }) async {
    final rankedCharacters = await _localDataSource.getAllRankedCharacters();
    final listCharacters = rankedCharacters
        .where((rankedCharacter) => rankedCharacter.listId == listId)
        .toList();
    final movingCharacter = _firstOrNull(
      listCharacters.where(
        (rankedCharacter) => rankedCharacter.characterId == characterId,
      ),
    );

    if (movingCharacter == null) {
      throw StateError('Character is not in this list.');
    }

    final targetPosition = _normalizeMovePosition(
      position: newPosition,
      listLength: listCharacters.length,
    );

    if (targetPosition == movingCharacter.position) {
      return;
    }

    final updatedCharacters = rankedCharacters.map((rankedCharacter) {
      if (rankedCharacter.listId != listId) {
        return rankedCharacter;
      }

      if (rankedCharacter.characterId == characterId) {
        return RankedCharacterModel.fromEntity(
          rankedCharacter.copyWith(position: targetPosition),
        );
      }

      final oldPosition = movingCharacter.position;
      final currentPosition = rankedCharacter.position;

      if (oldPosition < targetPosition &&
          currentPosition > oldPosition &&
          currentPosition <= targetPosition) {
        return RankedCharacterModel.fromEntity(
          rankedCharacter.copyWith(position: currentPosition - 1),
        );
      }

      if (oldPosition > targetPosition &&
          currentPosition >= targetPosition &&
          currentPosition < oldPosition) {
        return RankedCharacterModel.fromEntity(
          rankedCharacter.copyWith(position: currentPosition + 1),
        );
      }

      return rankedCharacter;
    }).toList();

    await _localDataSource.saveRankedCharacters(updatedCharacters);
  }

  int _normalizeInsertPosition({
    required int? position,
    required int listLength,
  }) {
    if (position == null) {
      return listLength + 1;
    }

    if (position < 1) {
      return 1;
    }

    if (position > listLength + 1) {
      return listLength + 1;
    }

    return position;
  }

  int _normalizeMovePosition({required int position, required int listLength}) {
    if (position < 1) {
      return 1;
    }

    if (position > listLength) {
      return listLength;
    }

    return position;
  }

  String _createRankingId({
    required String listId,
    required String characterId,
  }) {
    return '${listId}_${characterId}_${DateTime.now().microsecondsSinceEpoch}';
  }

  T? _firstOrNull<T>(Iterable<T> items) {
    for (final item in items) {
      return item;
    }

    return null;
  }
}
