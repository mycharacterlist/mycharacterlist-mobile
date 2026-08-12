import 'package:mycharacterlist/features/characters/data/sources/local/character_local_data_source.dart';
import 'package:mycharacterlist/features/patches/data/models/ranking_list_patch_entry_model.dart';
import 'package:mycharacterlist/features/patches/data/models/ranking_list_patch_model.dart';
import 'package:mycharacterlist/features/patches/data/sources/local/patch_local_data_source.dart';
import 'package:mycharacterlist/features/patches/domain/entities/ranking_list_patch.dart';
import 'package:mycharacterlist/features/patches/domain/entities/ranking_list_patch_entry.dart';
import 'package:mycharacterlist/features/patches/domain/repositories/patch_repository.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/repositories/ranking_list_repository.dart';

class PatchRepositoryImpl implements PatchRepository {
  const PatchRepositoryImpl({
    required PatchLocalDataSource localDataSource,
    required RankingListRepository rankingListRepository,
    required CharacterLocalDataSource characterLocalDataSource,
  }) : _localDataSource = localDataSource,
       _rankingListRepository = rankingListRepository,
       _characterLocalDataSource = characterLocalDataSource;

  final PatchLocalDataSource _localDataSource;
  final RankingListRepository _rankingListRepository;
  final CharacterLocalDataSource _characterLocalDataSource;

  @override
  Future<String> getSuggestedPatchLabel(String listId) async {
    final existingPatches = await _localDataSource.getPatchesForList(listId);
    return 'Patch ${existingPatches.length + 1}';
  }

  @override
  Future<RankingListPatch> createPatchFromCurrentList(
    String listId, {
    required String label,
    DateTime? createdAt,
  }) async {
    final listCharacters = await _rankingListRepository.getRankedCharacters(listId);

    if (listCharacters.isEmpty) {
      throw StateError('Cannot save a patch for an empty list.');
    }

    final trimmedLabel = label.trim();
    if (trimmedLabel.isEmpty) {
      throw StateError('Patch name cannot be empty.');
    }

    final now = DateTime.now();
    final patchCreatedAt = createdAt ?? now;
    final patch = RankingListPatchModel(
      id: 'patch_${listId}_${now.microsecondsSinceEpoch}',
      listId: listId,
      label: trimmedLabel,
      createdAt: patchCreatedAt,
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

  @override
  Future<void> updatePatch(RankingListPatch patch) {
    return _localDataSource.updatePatch(
      RankingListPatchModel.fromEntity(patch),
    );
  }

  @override
  Future<void> saveImportedPatch(
    RankingListPatch patch,
    List<RankingListPatchEntry> entries,
  ) {
    return _localDataSource.savePatch(
      RankingListPatchModel.fromEntity(patch),
      entries
          .map(RankingListPatchEntryModel.fromEntity)
          .toList(growable: false),
    );
  }
}
