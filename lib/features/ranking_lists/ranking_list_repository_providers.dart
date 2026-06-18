import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/core/database/database_providers.dart';
import 'package:mycharacterlist/features/characters/character_providers.dart';
import 'package:mycharacterlist/features/ranking_lists/data/repositories/ranking_list_repository_impl.dart';
import 'package:mycharacterlist/features/ranking_lists/data/sources/local/ranking_list_local_data_source.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/repositories/ranking_list_repository.dart';

final rankingListLocalDataSourceProvider = Provider<RankingListLocalDataSource>(
  (ref) => RankingListLocalDataSource(
    appDatabase: ref.watch(appDatabaseProvider),
  ),
);

final rankingListRepositoryProvider = Provider<RankingListRepository>(
  (ref) => RankingListRepositoryImpl(
    localDataSource: ref.watch(rankingListLocalDataSourceProvider),
    characterRepository: ref.watch(characterRepositoryProvider),
  ),
);
