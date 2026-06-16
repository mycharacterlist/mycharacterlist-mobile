import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/models/ranked_character_display_item.dart';
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

  Future<void> showRemoveCharacterSheet(
    BuildContext context,
    RankedCharacterDisplayItem item,
  ) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final shouldRemove = await showModalBottomSheet<bool>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.person_remove_outlined,
                color: Color(0xFFB71C1C),
              ),
              title: Text('Remove "${item.title}" from list'),
              onTap: () => Navigator.pop(sheetContext, true),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(sheetContext, false),
            ),
          ],
        ),
      ),
    );

    if (shouldRemove != true || !context.mounted) {
      return;
    }

    await confirmRemoveCharacter(context, item);
  }

  Future<void> confirmRemoveCharacter(
    BuildContext context,
    RankedCharacterDisplayItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove from list?'),
        content: Text(
          '"${item.title}" will be removed from this list. '
          'The character will stay in your library.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await _viewModel.removeCharacter(characterId: item.characterId);
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
