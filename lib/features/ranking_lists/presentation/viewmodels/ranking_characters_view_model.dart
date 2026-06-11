import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranked_character.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/repositories/ranking_list_repository.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/utils/view_model_error.dart';

class RankingCharactersState {
  const RankingCharactersState({
    this.characters = const [],
    this.isLoading = false,
    this.isEditMode = false,
    this.errorMessage,
  });

  final List<RankedCharacter> characters;
  final bool isLoading;
  final bool isEditMode;
  final String? errorMessage;

  RankingCharactersState copyWith({
    List<RankedCharacter>? characters,
    bool? isLoading,
    bool? isEditMode,
    String? errorMessage,
  }) {
    return RankingCharactersState(
      characters: characters ?? this.characters,
      isLoading: isLoading ?? this.isLoading,
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
       super(const RankingCharactersState(isLoading: true)) {
    loadCharacters();
  }

  final RankingListRepository _repository;
  final String listId;

  bool containsCharacter(String characterId) {
    return state.characters.any(
      (rankedCharacter) => rankedCharacter.characterId == characterId,
    );
  }

  String duplicateCharacterMessage(String characterName) {
    return '$characterName is already in this list';
  }

  int maxInsertPosition() => state.characters.length + 1;

  void toggleEditMode() {
    state = state.copyWith(isEditMode: !state.isEditMode);
  }

  Future<void> loadCharacters() async {
    state = state.copyWith(isLoading: true);

    try {
      final characters = await _repository.getRankedCharacters(listId);

      state = state.copyWith(
        characters: characters,
        isLoading: false,
      );
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
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

    final rankedCharacter = state.characters[oldIndex];

    await moveCharacter(
      characterId: rankedCharacter.characterId,
      newPosition: targetIndex + 1,
    );
  }

  Future<void> moveCharacter({
    required String characterId,
    required int newPosition,
  }) async {
    try {
      await _repository.moveCharacter(
        listId: listId,
        characterId: characterId,
        newPosition: newPosition,
      );

      await loadCharacters();
    } catch (error) {
      state = state.copyWith(
        errorMessage: messageFromViewModelError(error),
      );
    }
  }

  void clearError() {
    state = RankingCharactersState(
      characters: state.characters,
      isLoading: state.isLoading,
      isEditMode: state.isEditMode,
    );
  }
}
