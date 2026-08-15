import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/compare/data/repositories/compare_repository_providers.dart';

final compareCharactersProvider = FutureProvider.autoDispose<List<Character>>((
  ref,
) {
  return ref.watch(compareRepositoryProvider).getCharactersForCompare();
});

final compareAnimeTitlesProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) {
  return ref.watch(compareRepositoryProvider).getAnimeTitlesForCompare();
});
