import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranked_character.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/repositories/ranking_list_repository.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/utils/view_model_error.dart';

class RankingCharactersState {
  const RankingCharactersState({
    this.characters = const [],
    this.isInitialLoading = false,
    this.isEditMode = false,
    this.errorMessage,
  });

  final List<RankedCharacter> characters;
  final bool isInitialLoading;
  final bool isEditMode;
  final String? errorMessage;

  RankingCharactersState copyWith({
    List<RankedCharacter>? characters,
    bool? isInitialLoading,
    bool? isEditMode,
    String? errorMessage,
  }) {
    return RankingCharactersState(
      characters: characters ?? this.characters,
      isInitialLoading: isInitialLoading ?? this.isInitialLoading,
      isEditMode: isEditMode ?? this.isEditMode,
      errorMessage: errorMessage,
    );
  }
}

class RankingCharactersViewModel extends StateNotifier<RankingCharactersState> {
  RankingCharactersViewModel({
    required RankingListRepository repository,
    required this.listId,
  }) : _repository = repository,
       super(const RankingCharactersState(isInitialLoading: true)) {
    loadCharacters();
  }

  final RankingListRepository _repository;
  final String listId;

  int maxInsertPosition() => state.characters.length + 1;

  void toggleEditMode() {
    state = state.copyWith(isEditMode: !state.isEditMode);
  }

  void exitEditMode() {
    state = state.copyWith(isEditMode: false);
  }

  Future<void> loadCharacters() async {
    final isInitialLoad = state.characters.isEmpty;

    if (isInitialLoad) {
      state = state.copyWith(isInitialLoading: true);
    }

    try {
      final characters = await _repository.getRankedCharacters(listId);

      state = state.copyWith(
        characters: characters,
        isInitialLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isInitialLoading: false,
        errorMessage: messageFromViewModelError(error),
      );
    }
  }

  Future<void> addCharacter({
    required String characterId,
    required int position,
  }) async {
    try {
      await _repository.addCharacterToList(
        listId: listId,
        characterId: characterId,
        position: position,
      );

      await loadCharacters();
    } catch (error) {
      state = state.copyWith(
        errorMessage: messageFromViewModelError(error),
      );
    }
  }

  Future<void> reorderAtIndices(int oldIndex, int newIndex) async {
    var targetIndex = newIndex;

    if (targetIndex > oldIndex) {
      targetIndex--;
    }

    final previousCharacters = state.characters;
    final reorderedCharacters = List<RankedCharacter>.from(previousCharacters);
    final movedCharacter = reorderedCharacters.removeAt(oldIndex);
    reorderedCharacters.insert(targetIndex, movedCharacter);

    try {
      await _repository.moveCharacter(
        listId: listId,
        characterId: movedCharacter.characterId,
        newPosition: targetIndex + 1,
      );

      final updatedCharacters = reorderedCharacters.asMap().entries.map((entry) {
        return entry.value.copyWith(position: entry.key + 1);
      }).toList();

      state = state.copyWith(characters: updatedCharacters);
    } catch (error) {
      state = state.copyWith(
        characters: previousCharacters,
        errorMessage: messageFromViewModelError(error),
      );
      rethrow;
    }
  }

  void clearError() {
    state = RankingCharactersState(
      characters: state.characters,
      isInitialLoading: state.isInitialLoading,
      isEditMode: state.isEditMode,
    );
  }
}
