import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/core/database/database_providers.dart';
import 'package:mycharacterlist/features/characters/character_providers.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/ranking_lists/data/repositories/ranking_list_repository_impl.dart';
import 'package:mycharacterlist/features/ranking_lists/data/sources/local/ranking_list_local_data_source.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/repositories/ranking_list_repository.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/controllers/lists_page_controller.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/controllers/ranking_list_controller.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/models/ranked_character_display_item.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/models/ranked_list_content.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/viewmodels/lists_view_model.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/viewmodels/ranking_characters_view_model.dart';

final rankingListLocalDataSourceProvider = Provider<RankingListLocalDataSource>(
  (ref) => RankingListLocalDataSource(
    appDatabase: ref.watch(appDatabaseProvider),
  ),
);

final rankingListRepositoryProvider = Provider<RankingListRepository>(
  (ref) => RankingListRepositoryImpl(
    localDataSource: ref.watch(rankingListLocalDataSourceProvider),
  ),
);

final libraryCharactersProvider = FutureProvider<List<Character>>((ref) {
  return ref.watch(characterRepositoryProvider).getCharacters();
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

final rankedListContentProvider = Provider.family<RankedListContent, String>((ref, listId) {
  final charactersState = ref.watch(rankingCharactersViewModelProvider(listId));
  final libraryAsync = ref.watch(libraryCharactersProvider);

  if (charactersState.isLoading) {
    return const RankedListContent(isLoadingCharacters: true);
  }

  if (charactersState.characters.isEmpty) {
    return const RankedListContent(isEmpty: true);
  }

  return libraryAsync.when(
    loading: () => const RankedListContent(isLoadingLibrary: true),
    error: (_, __) => const RankedListContent(libraryFailed: true),
    data: (libraryCharacters) {
      final charactersById = {
        for (final character in libraryCharacters) character.id: character,
      };

      final items = charactersState.characters.asMap().entries.map((entry) {
        final rankedCharacter = entry.value;
        final character = charactersById[rankedCharacter.characterId];

        return RankedCharacterDisplayItem(
          id: rankedCharacter.id,
          characterId: rankedCharacter.characterId,
          position: entry.key + 1,
          title: character?.name ?? rankedCharacter.characterId,
          subtitle: character?.sourceTitle ?? '',
        );
      }).toList();

      return RankedListContent(items: items);
    },
  );
});

final rankingListControllerProvider = Provider.autoDispose.family<RankingListController, String>(
  (ref, listId) => RankingListController(ref, listId),
);

final listsPageControllerProvider = Provider.autoDispose<ListsPageController>((ref) {
  final controller = ListsPageController(ref);
  ref.onDispose(controller.dispose);
  return controller;
});
