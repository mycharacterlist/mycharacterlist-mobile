import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/characters/character_providers.dart';
import 'package:mycharacterlist/features/compare/data/repositories/compare_repository_impl.dart';
import 'package:mycharacterlist/features/compare/domain/repositories/compare_repository.dart';

final compareRepositoryProvider = Provider<CompareRepository>(
  (ref) => CompareRepositoryImpl(
    characterRepository: ref.watch(characterRepositoryProvider),
    referenceRepository: ref.watch(characterReferenceRepositoryProvider),
  ),
);
