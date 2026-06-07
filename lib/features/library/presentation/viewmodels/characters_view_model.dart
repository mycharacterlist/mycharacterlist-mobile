import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_repository.dart';

class CharactersState {
  const CharactersState({
    this.characters = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Character> characters;
  final bool isLoading;
  final String? errorMessage;
}

class CharactersViewModel extends StateNotifier<CharactersState> {
  CharactersViewModel({required CharacterRepository repository})
    : _repository = repository,
      super(const CharactersState(isLoading: true)) {
    loadCharacters();
  }

  final CharacterRepository _repository;

  Future<void> loadCharacters() async {
    state = CharactersState(characters: state.characters, isLoading: true);

    try {
      final characters = await _repository.getCharacters();
      state = CharactersState(characters: characters);
    } catch (_) {
      state = CharactersState(
        characters: state.characters,
        errorMessage: 'Could not load characters.',
      );
    }
  }

  Future<void> search(String query) async {
    state = CharactersState(characters: state.characters, isLoading: true);

    try {
      final characters = await _repository.searchCharacters(query);
      state = CharactersState(characters: characters);
    } catch (_) {
      state = CharactersState(
        characters: state.characters,
        errorMessage: 'Could not search characters.',
      );
    }
  }
}
