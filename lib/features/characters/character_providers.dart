import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/core/database/database_providers.dart';
import 'package:mycharacterlist/core/storage/storage_providers.dart';
import 'package:mycharacterlist/features/characters/data/repositories/character_repository_impl.dart';
import 'package:mycharacterlist/features/characters/data/repositories/character_reference_repository_impl.dart';
import 'package:mycharacterlist/features/characters/data/sources/local/character_local_data_source.dart';
import 'package:mycharacterlist/features/characters/data/sources/local/character_reference_local_data_source.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/characters/domain/entities/grade_definition.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_repository.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_reference_repository.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character_ranking_display.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_repository_providers.dart';

final characterLocalDataSourceProvider = Provider<CharacterLocalDataSource>(
  (ref) =>
      CharacterLocalDataSource(appDatabase: ref.watch(appDatabaseProvider)),
);

final characterRepositoryProvider = Provider<CharacterRepository>(
  (ref) => CharacterRepositoryImpl(
    localDataSource: ref.watch(characterLocalDataSourceProvider),
    localFileStorage: ref.watch(localFileStorageProvider),
    rankingListRepository: ref.watch(rankingListRepositoryProvider),
  ),
);

final characterReferenceLocalDataSourceProvider =
    Provider<CharacterReferenceLocalDataSource>(
      (ref) => CharacterReferenceLocalDataSource(
        appDatabase: ref.watch(appDatabaseProvider),
      ),
    );

final characterReferenceRepositoryProvider =
    Provider<CharacterReferenceRepository>(
      (ref) => CharacterReferenceRepositoryImpl(
        localDataSource: ref.watch(characterReferenceLocalDataSourceProvider),
      ),
    );

final characterByIdProvider = FutureProvider.autoDispose.family<Character?, String>(
  (ref, characterId) {
    return ref.watch(characterRepositoryProvider).getCharacterById(characterId);
  },
);

final gradeDefinitionsProvider =
    FutureProvider.autoDispose<List<GradeDefinition>>((ref) {
  return ref.watch(characterReferenceRepositoryProvider).getGradeDefinitions();
});

final characterRankingDisplaysProvider = FutureProvider.autoDispose
    .family<List<CharacterRankingDisplay>, String>((ref, characterId) async {
  final repository = ref.watch(rankingListRepositoryProvider);
  final rankings = await repository.getCharacterRankings(characterId);

  if (rankings.isEmpty) {
    return const [];
  }

  final lists = await repository.getLists();
  final listNamesById = {for (final list in lists) list.id: list.name};

  final displays = rankings
      .map(
        (ranking) => CharacterRankingDisplay(
          listName: listNamesById[ranking.listId] ?? 'Unknown list',
          position: ranking.position,
        ),
      )
      .toList();

  displays.sort((left, right) {
    final byPosition = left.position.compareTo(right.position);
    if (byPosition != 0) {
      return byPosition;
    }

    return left.listName.compareTo(right.listName);
  });
  return displays;
});
