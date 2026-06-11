import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/viewmodels/ranking_characters_view_model.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/inside_list/position_dialog.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/inside_list/select_character_dialog.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_providers.dart';

class RankingListController {
  RankingListController(this._ref, this.listId);

  final Ref _ref;
  final String listId;

  RankingCharactersViewModel get _viewModel =>
      _ref.read(rankingCharactersViewModelProvider(listId).notifier);

  void toggleEditMode() => _viewModel.toggleEditMode();

  Future<void> openAddCharacterFlow(
    BuildContext context,
    List<Character> libraryCharacters,
  ) async {
    while (true) {
      final rankedCharacterIds = _ref
          .read(rankingCharactersViewModelProvider(listId))
          .characters
          .map((rankedCharacter) => rankedCharacter.characterId)
          .toSet();

      final availableCharacters = libraryCharacters
          .where((character) => !rankedCharacterIds.contains(character.id))
          .toList();

      if (availableCharacters.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'All library characters are already in this list',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return;
      }

      final selectedCharacter = await showDialog<Character>(
        context: context,
        builder: (context) => SelectCharacterDialog(
          characters: availableCharacters,
        ),
      );

      if (selectedCharacter == null || !context.mounted) {
        return;
      }

      final position = await showDialog<int>(
        context: context,
        builder: (context) => PositionDialog(
          character: selectedCharacter,
          maxPosition: _viewModel.maxInsertPosition(),
        ),
      );

      if (position == null || !context.mounted) {
        continue;
      }

      await _viewModel.addCharacter(
        characterId: selectedCharacter.id,
        position: position,
      );

      return;
    }
  }
}
