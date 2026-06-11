import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/characters/domain/entities/grade_definition.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_reference_repository.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_repository.dart';
import 'package:mycharacterlist/features/library/domain/entities/character_filters.dart';
import 'package:mycharacterlist/features/library/domain/entities/character_export_result.dart';
import 'package:mycharacterlist/features/library/domain/entities/character_import_result.dart';
import 'package:mycharacterlist/features/library/domain/services/character_filter_service.dart';
import 'package:mycharacterlist/features/library/data/services/character_json_import_service.dart';
import 'package:mycharacterlist/features/library/data/services/character_json_export_service.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranked_character.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/repositories/ranking_list_repository.dart';

class CharactersState {
  const CharactersState({
    this.characters = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.isImporting = false,
    this.isExporting = false,
    this.errorMessage,
  });

  final List<Character> characters;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool isImporting;
  final bool isExporting;
  final String? errorMessage;
}

class CharactersViewModel extends StateNotifier<CharactersState> {
  CharactersViewModel({
    required CharacterRepository repository,
    required CharacterReferenceRepository referenceRepository,
    required RankingListRepository rankingListRepository,
    required CharacterJsonImportService importService,
    required CharacterJsonExportService exportService,
  }) : _repository = repository,
       _referenceRepository = referenceRepository,
       _rankingListRepository = rankingListRepository,
       _importService = importService,
       _exportService = exportService,
       super(const CharactersState(isLoading: true));

  final CharacterRepository _repository;
  final CharacterReferenceRepository _referenceRepository;
  final RankingListRepository _rankingListRepository;
  final CharacterJsonImportService _importService;
  final CharacterJsonExportService _exportService;

  String _query = '';
  CharacterFilters _filters = const CharacterFilters();
  int _requestId = 0;
  int _nextOffset = 0;

  static const _pageSize = 20;

  Future<void> loadCharacters() async {
    return _apply();
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) {
      return;
    }
    await _loadNextPage(reset: false);
  }

  Future<void> reset() async {
    _query = '';
    _filters = const CharacterFilters();
    await _apply();
  }

  Future<void> resetInBackground() async {
    _query = '';
    _filters = const CharacterFilters();
    _nextOffset = 0;
    await _loadNextPage(reset: true, silent: true);
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
    final normalizedQuery = query.trim();
    if (_query == normalizedQuery) {
      return;
    }
    _query = normalizedQuery;
    await _apply();
  }

  Future<CharacterImportResult?> importFile(String filePath) async {
    state = CharactersState(
      characters: state.characters,
      hasMore: state.hasMore,
      isImporting: true,
    );

    try {
      final result = await _importService.importFile(filePath);
      await _apply();
      return result;
    } catch (_) {
      state = CharactersState(
        characters: state.characters,
        hasMore: state.hasMore,
        errorMessage: 'Could not import characters from JSON.',
      );
      return null;
    }
  }

  Future<CharacterExportResult?> exportToDirectory(String directoryPath) async {
    state = CharactersState(
      characters: state.characters,
      hasMore: state.hasMore,
      isExporting: true,
    );

    try {
      final result = await _exportService.exportToDirectory(directoryPath);
      state = CharactersState(
        characters: state.characters,
        hasMore: state.hasMore,
      );
      return result;
    } catch (_) {
      state = CharactersState(
        characters: state.characters,
        hasMore: state.hasMore,
        errorMessage: 'Could not export characters.',
      );
      return null;
    }
  }

  Future<void> _apply() async {
    _nextOffset = 0;
    await _loadNextPage(reset: true);
  }

  Future<void> _loadNextPage({
    required bool reset,
    bool silent = false,
  }) async {
    final requestId = reset ? ++_requestId : _requestId;
    if (!silent) {
      state = CharactersState(
        characters: reset ? const [] : state.characters,
        isLoading: reset,
        isLoadingMore: !reset,
        hasMore: state.hasMore,
        isImporting: state.isImporting,
        isExporting: state.isExporting,
      );
    }

    try {
      final useSummaries = !_filters.hasActiveFilters;
      final definitions = _filters.hasGradeFilter
          ? await _referenceRepository.getGradeDefinitions()
          : const <GradeDefinition>[];

      final filteredCharacters = <Character>[];
      var hasMore = true;

      while (filteredCharacters.length < _pageSize && hasMore) {
        final characters = _loadCharactersPage(useSummaries: useSummaries);

        if (requestId != _requestId) {
          return;
        }

        final pageCharacters = await characters;

        if (requestId != _requestId) {
          return;
        }

        _nextOffset += pageCharacters.length;
        hasMore = pageCharacters.length == _pageSize;

        final rankingsByCharacterId = _filters.positions.isEmpty
            ? const <String, List<RankedCharacter>>{}
            : await _rankingListRepository.getCharacterRankingsBatch(
                pageCharacters.map((character) => character.id).toList(),
              );

        if (requestId != _requestId) {
          return;
        }

        for (final character in pageCharacters) {
          final rankings =
              rankingsByCharacterId[character.id] ?? const <RankedCharacter>[];

          if (CharacterFilterService.matches(
            character: character,
            filters: _filters,
            gradeDefinitions: definitions,
            rankings: rankings,
          )) {
            filteredCharacters.add(character);
          }
        }
      }

      if (requestId == _requestId) {
        state = CharactersState(
          characters: reset
              ? filteredCharacters
              : [...state.characters, ...filteredCharacters],
          hasMore: hasMore,
        );
      }
    } catch (_) {
      if (requestId == _requestId) {
        state = CharactersState(
          characters: state.characters,
          hasMore: state.hasMore,
          errorMessage: 'Could not filter characters.',
        );
      }
    }
  }

  Future<List<Character>> _loadCharactersPage({
    required bool useSummaries,
  }) {
    if (useSummaries) {
      return _query.isEmpty
          ? _repository.getCharacterSummariesPage(
              offset: _nextOffset,
              limit: _pageSize,
            )
          : _repository.searchCharacterSummariesPage(
              _query,
              offset: _nextOffset,
              limit: _pageSize,
            );
    }

    return _query.isEmpty
        ? _repository.getCharacterListItemsPage(
            offset: _nextOffset,
            limit: _pageSize,
          )
        : _repository.searchCharacterListItemsPage(
            _query,
            offset: _nextOffset,
            limit: _pageSize,
          );
  }
}
