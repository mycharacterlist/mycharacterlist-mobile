import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/characters/domain/entities/grade_definition.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_reference_repository.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_repository.dart';
import 'package:mycharacterlist/features/library/domain/entities/character_filters.dart';
import 'package:mycharacterlist/features/library/domain/services/character_filter_service.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranked_character.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/repositories/ranking_list_repository.dart';

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
  CharactersViewModel({
    required CharacterRepository repository,
    required CharacterReferenceRepository referenceRepository,
    required RankingListRepository rankingListRepository,
  }) : _repository = repository,
       _referenceRepository = referenceRepository,
       _rankingListRepository = rankingListRepository,
       super(const CharactersState(isLoading: true)) {
    loadCharacters();
  }

  final CharacterRepository _repository;
  final CharacterReferenceRepository _referenceRepository;
  final RankingListRepository _rankingListRepository;

  String _query = '';
  CharacterFilters _filters = const CharacterFilters();
  int _requestId = 0;

  Future<void> loadCharacters() async {
    return _apply();
  }

  Future<void> reset() async {
    _query = '';
    _filters = const CharacterFilters();
    await _apply();
  }

  Future<void> applyFilters(CharacterFilters filters) async {
    _filters = filters;
    await _apply();
  }

  Future<void> clearFilters() async {
    _filters = const CharacterFilters();
    await _apply();
  }

  Future<void> search(String query) async {
    _query = query.trim();
    await _apply();
  }

  Future<void> _apply() async {
    final requestId = ++_requestId;
    state = CharactersState(characters: state.characters, isLoading: true);

    try {
      final characters = _query.isEmpty
          ? await _repository.getCharacters()
          : await _repository.searchCharacters(_query);
      final definitions = _filters.hasGradeFilter
          ? await _referenceRepository.getGradeDefinitions()
          : const <GradeDefinition>[];

      final filteredCharacters = <Character>[];
      for (final character in characters) {
        final rankings = _filters.positions.isEmpty
            ? const <RankedCharacter>[]
            : await _rankingListRepository.getCharacterRankings(character.id);

        if (CharacterFilterService.matches(
          character: character,
          filters: _filters,
          gradeDefinitions: definitions,
          rankings: rankings,
        )) {
          filteredCharacters.add(character);
        }
      }

      if (requestId == _requestId) {
        state = CharactersState(characters: filteredCharacters);
      }
    } catch (_) {
      if (requestId == _requestId) {
        state = CharactersState(
          characters: state.characters,
          errorMessage: 'Could not filter characters.',
        );
      }
    }
  }
}
