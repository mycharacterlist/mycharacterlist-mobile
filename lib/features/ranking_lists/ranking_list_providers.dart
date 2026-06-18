import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/characters/character_providers.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list_patch.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list_patch_entry.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/controllers/lists_page_controller.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/controllers/ranking_list_controller.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/state/ranked_character_display_item.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/state/ranked_list_content.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/viewmodels/lists_view_model.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/viewmodels/ranking_characters_view_model.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_repository_providers.dart';

final libraryCharactersProvider = FutureProvider<List<Character>>((ref) {
  ref.keepAlive();
  return ref.watch(characterRepositoryProvider).getCharacterSummaries();
});

final listsViewModelProvider = StateNotifierProvider<ListsViewModel, ListsState>(
  (ref) => ListsViewModel(repository: ref.watch(rankingListRepositoryProvider)),
);

final rankingCharactersViewModelProvider = StateNotifierProvider.family<
  RankingCharactersViewModel,
  RankingCharactersState,
  String
>(
  (ref, listId) => RankingCharactersViewModel(
    repository: ref.watch(rankingListRepositoryProvider),
    listId: listId,
  ),
);

final rankingListByIdProvider = Provider.family<RankingList?, String>((ref, listId) {
  return ref.watch(listsViewModelProvider).findById(listId);
});

final rankedListCharacterDetailsProvider =
    FutureProvider.family<Map<String, Character>, String>((ref, listId) async {
  ref.keepAlive();

  final characterIds = ref
      .watch(
        rankingCharactersViewModelProvider(listId).select(
          (state) => state.characters
              .map((rankedCharacter) => rankedCharacter.characterId)
              .toSet(),
        ),
      )
      .toList();

  if (characterIds.isEmpty) {
    return const {};
  }

  final characters = await ref
      .read(characterRepositoryProvider)
      .getCharactersByIds(characterIds);

  return {for (final character in characters) character.id: character};
});

bool _hasResolvedCharacterDetails(
  Set<String> requiredCharacterIds,
  Map<String, Character> charactersById,
) {
  if (requiredCharacterIds.isEmpty) {
    return true;
  }

  return requiredCharacterIds.every(charactersById.containsKey);
}

Map<String, Character> _mergeCharacterDetails(
  Map<String, Character>? rankedCharactersById,
  List<Character>? libraryCharacters,
) {
  final mergedCharacters = <String, Character>{};

  if (libraryCharacters != null) {
    for (final character in libraryCharacters) {
      mergedCharacters[character.id] = character;
    }
  }

  if (rankedCharactersById != null) {
    mergedCharacters.addAll(rankedCharactersById);
  }

  return mergedCharacters;
}

final rankedListContentProvider = Provider.family<RankedListContent, String>((ref, listId) {
  final charactersState = ref.watch(rankingCharactersViewModelProvider(listId));
  final characterDetailsAsync = ref.watch(rankedListCharacterDetailsProvider(listId));
  final libraryCharacters = ref.watch(libraryCharactersProvider).valueOrNull;

  if (charactersState.isInitialLoading && charactersState.characters.isEmpty) {
    return const RankedListContent(isLoadingCharacters: true);
  }

  if (charactersState.characters.isEmpty) {
    return const RankedListContent(isEmpty: true);
  }

  final requiredCharacterIds = charactersState.characters
      .map((rankedCharacter) => rankedCharacter.characterId)
      .toSet();
  final rankedCharactersById = characterDetailsAsync.valueOrNull;
  final charactersById = _mergeCharacterDetails(
    rankedCharactersById,
    libraryCharacters,
  );

  final isWaitingForDetails =
      characterDetailsAsync.isLoading &&
      !_hasResolvedCharacterDetails(requiredCharacterIds, charactersById);

  if (isWaitingForDetails) {
    return const RankedListContent(isLoadingCharacters: true);
  }

  if (!_hasResolvedCharacterDetails(requiredCharacterIds, charactersById) &&
      libraryCharacters == null &&
      rankedCharactersById == null) {
    return const RankedListContent(isLoadingCharacters: true);
  }

  final items = charactersState.characters.asMap().entries.map((entry) {
    final rankedCharacter = entry.value;
    final character = charactersById[rankedCharacter.characterId];

    return RankedCharacterDisplayItem(
      id: rankedCharacter.id,
      characterId: rankedCharacter.characterId,
      position: entry.key + 1,
      title: character?.name ?? 'Unknown character',
      subtitle: character?.sourceTitle ?? '',
    );
  }).toList();

  return RankedListContent(items: items);
});

final rankingListPatchesProvider =
    FutureProvider.autoDispose.family<List<RankingListPatch>, String>((
  ref,
  listId,
) {
  return ref.watch(rankingListRepositoryProvider).getPatchesForList(listId);
});

final rankingListPatchByIdProvider =
    FutureProvider.autoDispose.family<RankingListPatch?, String>((
  ref,
  patchId,
) {
  return ref.watch(rankingListRepositoryProvider).getPatchById(patchId);
});

final patchEntriesProvider =
    FutureProvider.autoDispose.family<List<RankingListPatchEntry>, String>((
  ref,
  patchId,
) {
  return ref.watch(rankingListRepositoryProvider).getPatchEntries(patchId);
});

final patchDisplayContentProvider =
    Provider.autoDispose.family<RankedListContent, String>((ref, patchId) {
  final entriesAsync = ref.watch(patchEntriesProvider(patchId));
  final libraryAsync = ref.watch(libraryCharactersProvider);

  return entriesAsync.when(
    loading: () => const RankedListContent(isLoadingCharacters: true),
    error: (_, __) => const RankedListContent(isEmpty: true),
    data: (entries) {
      if (entries.isEmpty) {
        return const RankedListContent(isEmpty: true);
      }

      final libraryIds = libraryAsync.maybeWhen(
        data: (characters) => characters.map((character) => character.id).toSet(),
        orElse: () => null,
      );

      final items = entries
          .map(
            (entry) => RankedCharacterDisplayItem(
              id: entry.id,
              characterId: entry.characterId,
              position: entry.position,
              title: _patchEntryTitle(entry, null),
              subtitle: _patchEntrySubtitle(entry, null),
              isCharacterAvailable:
                  libraryIds?.contains(entry.characterId) ?? true,
            ),
          )
          .toList();

      return RankedListContent(items: items);
    },
  );
});

String _patchEntryTitle(
  RankingListPatchEntry entry,
  Character? character,
) {
  if (entry.characterName.trim().isNotEmpty) {
    return entry.characterName;
  }

  return character?.name ?? 'Unknown character';
}

String _patchEntrySubtitle(
  RankingListPatchEntry entry,
  Character? character,
) {
  if (entry.sourceTitle.trim().isNotEmpty) {
    return entry.sourceTitle;
  }

  return character?.sourceTitle ?? '';
}

final rankingListControllerProvider = Provider.autoDispose.family<RankingListController, String>(
  (ref, listId) => RankingListController(ref, listId),
);

final listsPageControllerProvider = Provider.autoDispose<ListsPageController>((ref) {
  final controller = ListsPageController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});
