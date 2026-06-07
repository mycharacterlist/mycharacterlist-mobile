import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/core/database/database_providers.dart';
import 'package:mycharacterlist/core/storage/storage_providers.dart';
import 'package:mycharacterlist/features/characters/data/repositories/character_repository_impl.dart';
import 'package:mycharacterlist/features/characters/data/repositories/character_reference_repository_impl.dart';
import 'package:mycharacterlist/features/characters/data/sources/local/character_local_data_source.dart';
import 'package:mycharacterlist/features/characters/data/sources/local/character_reference_local_data_source.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_repository.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_reference_repository.dart';

final characterLocalDataSourceProvider = Provider<CharacterLocalDataSource>(
  (ref) =>
      CharacterLocalDataSource(appDatabase: ref.watch(appDatabaseProvider)),
);

final characterRepositoryProvider = Provider<CharacterRepository>(
  (ref) => CharacterRepositoryImpl(
    localDataSource: ref.watch(characterLocalDataSourceProvider),
    localFileStorage: ref.watch(localFileStorageProvider),
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
