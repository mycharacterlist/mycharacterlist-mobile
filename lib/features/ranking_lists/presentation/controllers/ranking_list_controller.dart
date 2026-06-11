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

  void toggleEditMode() {
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.toggleEditMode();
    });
  }

  void exitEditMode() {
    FocusManager.instance.primaryFocus?.unfocus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.exitEditMode();
    });
  }

  Future<void> openAddCharacterFlow(BuildContext context) async {
    while (true) {
      final selectedCharacter = await showDialog<Character>(
        context: context,
        builder: (context) => SelectCharacterDialog(listId: listId),
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
