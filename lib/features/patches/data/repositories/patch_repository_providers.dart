import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/core/database/database_providers.dart';
import 'package:mycharacterlist/features/characters/character_providers.dart';
import 'package:mycharacterlist/features/patches/data/repositories/patch_repository_impl.dart';
import 'package:mycharacterlist/features/patches/data/sources/local/patch_local_data_source.dart';
import 'package:mycharacterlist/features/patches/domain/repositories/patch_repository.dart';
import 'package:mycharacterlist/features/ranking_lists/data/repositories/ranking_list_repository_providers.dart';

final patchLocalDataSourceProvider = Provider<PatchLocalDataSource>(
  (ref) => PatchLocalDataSource(
    appDatabase: ref.watch(appDatabaseProvider),
  ),
);

final patchRepositoryProvider = Provider<PatchRepository>(
  (ref) => PatchRepositoryImpl(
    localDataSource: ref.watch(patchLocalDataSourceProvider),
    rankingListRepository: ref.watch(rankingListRepositoryProvider),
    characterLocalDataSource: ref.watch(characterLocalDataSourceProvider),
  ),
);
