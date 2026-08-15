import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/patches/domain/entities/ranking_list_patch.dart';
import 'package:mycharacterlist/features/patches/domain/entities/ranking_list_patch_entry.dart';
import 'package:mycharacterlist/features/patches/data/repositories/patch_repository_providers.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/state/ranked_character_display_item.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/state/ranked_list_content.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_providers.dart';

final rankingListPatchesProvider =
    FutureProvider.autoDispose.family<List<RankingListPatch>, String>((
  ref,
  listId,
) {
  return ref.watch(patchRepositoryProvider).getPatchesForList(listId);
});

final rankingListPatchByIdProvider =
    FutureProvider.autoDispose.family<RankingListPatch?, String>((
  ref,
  patchId,
) {
  return ref.watch(patchRepositoryProvider).getPatchById(patchId);
});

final patchEntriesProvider =
    FutureProvider.autoDispose.family<List<RankingListPatchEntry>, String>((
  ref,
  patchId,
) {
  return ref.watch(patchRepositoryProvider).getPatchEntries(patchId);
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

      final libraryCharactersById = libraryAsync.maybeWhen(
        data: (characters) => {
          for (final character in characters) character.id: character,
        },
        orElse: () => null,
      );

      final items = entries
          .map(
            (entry) {
              final character = libraryCharactersById?[entry.characterId];

              return RankedCharacterDisplayItem(
                id: entry.id,
                characterId: entry.characterId,
                position: entry.position,
                title: _patchEntryTitle(entry, character),
                subtitle: _patchEntrySubtitle(entry, character),
                isCharacterAvailable:
                    libraryCharactersById?.containsKey(entry.characterId) ??
                        true,
              );
            },
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
