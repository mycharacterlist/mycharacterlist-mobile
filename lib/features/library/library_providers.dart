import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/characters/character_providers.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_providers.dart';
import 'package:mycharacterlist/features/library/presentation/viewmodels/characters_view_model.dart';
import 'package:mycharacterlist/features/library/presentation/viewmodels/character_references_view_model.dart';
import 'package:mycharacterlist/features/library/presentation/viewmodels/create_character_view_model.dart';

final charactersViewModelProvider =
    StateNotifierProvider<CharactersViewModel, CharactersState>(
      (ref) => CharactersViewModel(
        repository: ref.watch(characterRepositoryProvider),
        referenceRepository: ref.watch(characterReferenceRepositoryProvider),
        rankingListRepository: ref.watch(rankingListRepositoryProvider),
      ),
    );

final createCharacterViewModelProvider =
    StateNotifierProvider<CreateCharacterViewModel, CreateCharacterState>(
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
