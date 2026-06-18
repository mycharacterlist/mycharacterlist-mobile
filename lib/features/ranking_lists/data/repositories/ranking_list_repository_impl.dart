import 'package:mycharacterlist/features/characters/data/sources/local/character_local_data_source.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranked_character.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/repositories/ranking_list_repository.dart';
import 'package:mycharacterlist/features/ranking_lists/data/models/ranking_list_patch_entry_model.dart';
import 'package:mycharacterlist/features/ranking_lists/data/models/ranking_list_patch_model.dart';
import 'package:mycharacterlist/features/ranking_lists/data/models/ranked_character_model.dart';
import 'package:mycharacterlist/features/ranking_lists/data/models/ranking_list_model.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list_patch.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list_patch_entry.dart';
import 'package:mycharacterlist/features/ranking_lists/data/sources/local/ranking_list_local_data_source.dart';

class RankingListRepositoryImpl implements RankingListRepository {
  const RankingListRepositoryImpl({
    required RankingListLocalDataSource localDataSource,
    required CharacterLocalDataSource characterLocalDataSource,
  }) : _localDataSource = localDataSource,
       _characterLocalDataSource = characterLocalDataSource;

  final RankingListLocalDataSource _localDataSource;
  final CharacterLocalDataSource _characterLocalDataSource;

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
  Future<Map<String, List<RankedCharacter>>> getCharacterRankingsBatch(
    List<String> characterIds,
  ) {
    return _localDataSource.getCharacterRankingsBatch(characterIds);
  }

  @override
  Future<void> addCharacterToList({
    required String listId,
    required String characterId,
    int? position,
  }) async {
    final listCharacters = await _loadListCharacters(listId);
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

    final updatedCharacters = listCharacters
        .map((rankedCharacter) {
          if (rankedCharacter.position < insertPosition) {
            return rankedCharacter;
          }

          return RankedCharacterModel.fromEntity(
            rankedCharacter.copyWith(position: rankedCharacter.position + 1),
          );
        })
        .toList();

    updatedCharacters.add(
      RankedCharacterModel(
        id: _createRankingId(listId: listId, characterId: characterId),
        listId: listId,
        characterId: characterId,
        position: insertPosition,
        addedAt: DateTime.now(),
      ),
    );

    await _localDataSource.replaceRankedCharactersForList(
      listId,
      updatedCharacters,
    );
  }

  @override
  Future<void> removeCharacterFromList({
    required String listId,
    required String characterId,
  }) async {
    final listCharacters = await _loadListCharacters(listId);
    final removingCharacter = _firstOrNull(
      listCharacters.where(
        (rankedCharacter) => rankedCharacter.characterId == characterId,
      ),
    );

    if (removingCharacter == null) {
      return;
    }

    final updatedCharacters = listCharacters
        .where((rankedCharacter) => rankedCharacter.id != removingCharacter.id)
        .map((rankedCharacter) {
          if (rankedCharacter.position <= removingCharacter.position) {
            return rankedCharacter;
          }

          return RankedCharacterModel.fromEntity(
            rankedCharacter.copyWith(position: rankedCharacter.position - 1),
          );
        })
        .toList();

    await _localDataSource.replaceRankedCharactersForList(
      listId,
      updatedCharacters,
    );
  }

  @override
  Future<void> removeCharacterFromAllLists(String characterId) async {
    final rankings = await _localDataSource.getCharacterRankings(characterId);

    for (final ranking in rankings) {
      await removeCharacterFromList(
        listId: ranking.listId,
        characterId: characterId,
      );
    }
  }

  @override
  Future<void> moveCharacter({
    required String listId,
    required String characterId,
    required int newPosition,
  }) async {
    final listCharacters = await _loadListCharacters(listId);
    final movingIndex = listCharacters.indexWhere(
      (rankedCharacter) => rankedCharacter.characterId == characterId,
    );

    if (movingIndex == -1) {
      throw StateError('Character is not in this list.');
    }

    final targetPosition = _normalizeMovePosition(
      position: newPosition,
      listLength: listCharacters.length,
    );
    final targetIndex = targetPosition - 1;

    if (movingIndex == targetIndex) {
      return;
    }

    final reorderedCharacters = List<RankedCharacterModel>.from(listCharacters);
    final movedCharacter = reorderedCharacters.removeAt(movingIndex);
    reorderedCharacters.insert(targetIndex, movedCharacter);

    final updatedCharacters = reorderedCharacters
        .asMap()
        .entries
        .map(
          (entry) => RankedCharacterModel.fromEntity(
            entry.value.copyWith(position: entry.key + 1),
          ),
        )
        .toList();

    await _localDataSource.replaceRankedCharactersForList(
      listId,
      updatedCharacters,
    );
  }

  Future<List<RankedCharacterModel>> _loadListCharacters(String listId) async {
    final listCharacters = await _localDataSource.getRankedCharacters(listId);
    return listCharacters
        .map(RankedCharacterModel.fromEntity)
        .toList(growable: true);
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

  @override
  Future<void> replaceListCharacters({
    required String listId,
    required List<({String characterId, int position})> entries,
  }) async {
    final now = DateTime.now();
    final rankedCharacters = entries
        .asMap()
        .entries
        .map(
          (entry) => RankedCharacterModel(
            id:
                '${listId}_${entry.value.characterId}_${now.microsecondsSinceEpoch}_${entry.key}',
            listId: listId,
            characterId: entry.value.characterId,
            position: entry.value.position,
            addedAt: now,
          ),
        )
        .toList();

    await _localDataSource.replaceRankedCharactersForList(
      listId,
      rankedCharacters,
    );
  }

  @override
  Future<String> getSuggestedPatchLabel(String listId) async {
    final existingPatches = await _localDataSource.getPatchesForList(listId);
    return 'Patch ${existingPatches.length + 1}';
  }

  @override
  Future<RankingListPatch> createPatchFromCurrentList(
    String listId, {
    required String label,
  }) async {
    final listCharacters = await _loadListCharacters(listId);

    if (listCharacters.isEmpty) {
      throw StateError('Cannot save a patch for an empty list.');
    }

    final trimmedLabel = label.trim();
    if (trimmedLabel.isEmpty) {
      throw StateError('Patch name cannot be empty.');
    }

    final now = DateTime.now();
    final patch = RankingListPatchModel(
      id: 'patch_${listId}_${now.microsecondsSinceEpoch}',
      listId: listId,
      label: trimmedLabel,
      createdAt: now,
    );

    final characterIds = listCharacters
        .map((rankedCharacter) => rankedCharacter.characterId)
        .toList();
    final characters = await _characterLocalDataSource.getCharactersByIds(
      characterIds,
    );
    final charactersById = {
      for (final character in characters) character.id: character,
    };

    final entries = listCharacters.asMap().entries.map((entry) {
      final rankedCharacter = entry.value;
      final character = charactersById[rankedCharacter.characterId];

      return RankingListPatchEntryModel(
        id: '${patch.id}_${rankedCharacter.characterId}',
        patchId: patch.id,
        characterId: rankedCharacter.characterId,
        characterName: character?.name ?? 'Unknown character',
        sourceTitle: character?.sourceTitle ?? '',
        position: entry.key + 1,
      );
    }).toList();

    await _localDataSource.savePatch(patch, entries);
    return patch;
  }

  @override
  Future<List<RankingListPatch>> getPatchesForList(String listId) {
    return _localDataSource.getPatchesForList(listId);
  }

  @override
  Future<RankingListPatch?> getPatchById(String patchId) {
    return _localDataSource.getPatchById(patchId);
  }

  @override
  Future<List<RankingListPatchEntry>> getPatchEntries(String patchId) {
    return _localDataSource.getPatchEntries(patchId);
  }

  @override
  Future<void> deletePatch(String patchId) {
    return _localDataSource.deletePatch(patchId);
  }

  T? _firstOrNull<T>(Iterable<T> items) {
    for (final item in items) {
      return item;
    }

    return null;
  }
}
