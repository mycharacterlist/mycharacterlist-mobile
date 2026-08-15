import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/characters/character_providers.dart';
import 'package:mycharacterlist/core/storage/storage_providers.dart';
import 'package:mycharacterlist/features/library/data/services/character_json_export_service.dart';
import 'package:mycharacterlist/features/library/data/services/character_json_import_service.dart';
import 'package:mycharacterlist/features/patches/data/repositories/patch_repository_providers.dart';
import 'package:mycharacterlist/features/ranking_lists/data/repositories/ranking_list_repository_providers.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_providers.dart';
import 'package:mycharacterlist/features/library/presentation/viewmodels/characters_view_model.dart';
import 'package:mycharacterlist/features/library/presentation/viewmodels/character_references_view_model.dart';
import 'package:mycharacterlist/features/library/presentation/viewmodels/create_character_view_model.dart';

final characterJsonImportServiceProvider = Provider<CharacterJsonImportService>(
  (ref) => CharacterJsonImportService(
    characterRepository: ref.watch(characterRepositoryProvider),
    referenceRepository: ref.watch(characterReferenceRepositoryProvider),
    rankingListRepository: ref.watch(rankingListRepositoryProvider),
    patchRepository: ref.watch(patchRepositoryProvider),
    localFileStorage: ref.watch(localFileStorageProvider),
  ),
);

final characterJsonExportServiceProvider = Provider<CharacterJsonExportService>(
  (ref) => CharacterJsonExportService(
    characterRepository: ref.watch(characterRepositoryProvider),
    rankingListRepository: ref.watch(rankingListRepositoryProvider),
    patchRepository: ref.watch(patchRepositoryProvider),
    localFileStorage: ref.watch(localFileStorageProvider),
  ),
);

final characterNameSuggestionsProvider = FutureProvider<List<String>>((
  ref,
) async {
  final characters = await ref
      .watch(characterRepositoryProvider)
      .getCharacterSummaries();
  final names = characters.map((character) => character.name).toSet().toList();
  names.sort((left, right) => _normalizedSortKey(left).compareTo(_normalizedSortKey(right)));
  return names;
});

String _normalizedSortKey(String value) {
  return value.toLowerCase().replaceAll('ё', 'е');
}

Future<void> refreshLibraryAfterCharacterMutation(
  WidgetRef ref, {
  String? characterId,
  bool includeRanking = true,
}) async {
  ref.invalidate(libraryCharactersProvider);
  ref.invalidate(characterNameSuggestionsProvider);

  if (characterId != null) {
    ref.invalidate(characterByIdProvider(characterId));
    ref.invalidate(characterRankingDisplaysProvider(characterId));
  }

  if (includeRanking) {
    ref.invalidate(rankingCharactersViewModelProvider);
    ref.invalidate(rankedListCharacterDetailsProvider);
  }

  await ref.read(characterReferencesViewModelProvider.notifier).load();
  await ref.read(charactersViewModelProvider.notifier).loadCharacters();
}

final charactersViewModelProvider =
    StateNotifierProvider<CharactersViewModel, CharactersState>(
      (ref) {
        ref.keepAlive();

        return CharactersViewModel(
          repository: ref.watch(characterRepositoryProvider),
          referenceRepository: ref.watch(characterReferenceRepositoryProvider),
          rankingListRepository: ref.watch(rankingListRepositoryProvider),
          importService: ref.watch(characterJsonImportServiceProvider),
          exportService: ref.watch(characterJsonExportServiceProvider),
        );
      },
    );

final createCharacterViewModelProvider =
    StateNotifierProvider.autoDispose<
      CreateCharacterViewModel,
      CreateCharacterState
    >(
      (ref) => CreateCharacterViewModel(
        repository: ref.watch(characterRepositoryProvider),
        referenceRepository: ref.watch(characterReferenceRepositoryProvider),
      ),
    );

final characterReferencesViewModelProvider =
    StateNotifierProvider<
      CharacterReferencesViewModel,
      CharacterReferencesState
    >(
      (ref) => CharacterReferencesViewModel(
        repository: ref.watch(characterReferenceRepositoryProvider),
      ),
    );
