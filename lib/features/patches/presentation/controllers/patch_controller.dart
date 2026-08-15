import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/layout/bottom_sheet_padding.dart';
import 'package:mycharacterlist/core/errors/error_mapper.dart';
import 'package:mycharacterlist/core/presentation/feedback/app_snack_bar.dart';
import 'package:mycharacterlist/core/theme/app_colors.dart';
import 'package:mycharacterlist/features/patches/patch_providers.dart';
import 'package:mycharacterlist/features/patches/data/repositories/patch_repository_providers.dart';
import 'package:mycharacterlist/features/patches/presentation/widgets/duplicate_patch_confirmation_dialog.dart';
import 'package:mycharacterlist/features/patches/presentation/widgets/save_patch_dialog.dart';

class PatchController {
  PatchController(this._ref, this.listId);

  final Ref _ref;
  final String listId;

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
      final repository = _ref.read(patchRepositoryProvider);
      final suggestedLabel = await repository.getSuggestedPatchLabel(listId);

      if (!context.mounted) {
        return;
      }

      final label = await SavePatchDialog.show(
        context,
        suggestedLabel: suggestedLabel,
      );

      if (label == null || !context.mounted) {
        return;
      }

      final duplicatePatch = await repository.findDuplicatePatchForCurrentList(
        listId,
      );

      if (duplicatePatch != null) {
        if (!context.mounted) {
          return;
        }

        final confirmed = await showDuplicatePatchConfirmationDialog(
          context,
          duplicatePatch: duplicatePatch,
        );

        if (!confirmed || !context.mounted) {
          return;
        }
      }

      final patch = await repository.createPatchFromCurrentList(
        listId,
        label: label,
      );
      _ref.invalidate(rankingListPatchesProvider(listId));
      _ref.invalidate(currentListDuplicatePatchProvider(listId));

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

final patchControllerProvider = Provider.autoDispose.family<PatchController, String>(
  (ref, listId) => PatchController(ref, listId),
);
