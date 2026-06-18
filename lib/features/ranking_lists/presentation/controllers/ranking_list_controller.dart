import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/widgets/layout/bottom_sheet_padding.dart';
import 'package:mycharacterlist/core/errors/error_mapper.dart';
import 'package:mycharacterlist/core/presentation/feedback/app_snack_bar.dart';
import 'package:mycharacterlist/core/theme/app_colors.dart';
import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/state/ranked_character_display_item.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/viewmodels/ranking_characters_view_model.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/inside_list/position_dialog.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/inside_list/select_character_dialog.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_providers.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_repository_providers.dart';

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
      useSafeArea: false,
      builder: (sheetContext) => BottomSheetPadding(
        bottomMargin: 8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.person_remove_outlined,
                color: AppColors.destructive,
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

  Future<void> showPatchOptionsSheet(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final action = await showModalBottomSheet<_PatchSheetAction>(
      context: context,
      useSafeArea: false,
      builder: (sheetContext) => BottomSheetPadding(
        bottomMargin: 8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save_outlined, color: AppColors.formAccent),
              title: const Text('Save'),
              subtitle: const Text('Save the current ranking as a patch'),
              onTap: () => Navigator.pop(sheetContext, _PatchSheetAction.save),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: AppColors.formAccent),
              title: const Text('Patch list'),
              subtitle: const Text('Open saved patches for this list'),
              onTap: () => Navigator.pop(sheetContext, _PatchSheetAction.openList),
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(sheetContext),
            ),
          ],
        ),
      ),
    );

    if (!context.mounted || action == null) {
      return;
    }

    switch (action) {
      case _PatchSheetAction.save:
        await saveCurrentListPatch(context);
      case _PatchSheetAction.openList:
        context.push(AppRoutes.rankingListPatchesById(listId));
    }
  }

  Future<void> saveCurrentListPatch(BuildContext context) async {
    try {
      final patch = await _ref
          .read(rankingListRepositoryProvider)
          .createPatchFromCurrentList(listId);
      _ref.invalidate(rankingListPatchesProvider(listId));

      if (context.mounted) {
        AppSnackBar.showCentered(context, 'Saved: ${patch.label}');
      }
    } catch (error) {
      if (context.mounted) {
        AppSnackBar.showCentered(context, ErrorMapper.userMessage(error));
      }
    }
  }
}

enum _PatchSheetAction {
  save,
  openList,
}
