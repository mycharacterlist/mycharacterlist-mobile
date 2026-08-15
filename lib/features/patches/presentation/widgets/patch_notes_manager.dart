import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/feedback/app_loading_indicator.dart';
import 'package:mycharacterlist/app/widgets/layout/empty_state_message.dart';
import 'package:mycharacterlist/core/errors/error_mapper.dart';
import 'package:mycharacterlist/core/presentation/feedback/app_snack_bar.dart';
import 'package:mycharacterlist/features/patches/data/repositories/patch_repository_providers.dart';
import 'package:mycharacterlist/features/patches/domain/entities/ranking_list_patch.dart';
import 'package:mycharacterlist/features/patches/patch_providers.dart';
import 'package:mycharacterlist/features/patches/presentation/utils/patch_formatters.dart';
import 'package:mycharacterlist/features/patches/presentation/widgets/duplicate_patch_confirmation_dialog.dart';
import 'package:mycharacterlist/features/patches/presentation/widgets/edit_patch_dialog.dart';
import 'package:mycharacterlist/features/patches/presentation/widgets/patch_note_card.dart';
import 'package:mycharacterlist/features/patches/presentation/widgets/patch_note_form.dart';

class PatchNotesManager extends ConsumerStatefulWidget {
  const PatchNotesManager({
    super.key,
    required this.listId,
    required this.isEditMode,
  });

  final String listId;
  final bool isEditMode;

  @override
  ConsumerState<PatchNotesManager> createState() => PatchNotesManagerState();
}

class PatchNotesManagerState extends ConsumerState<PatchNotesManager> {
  final TextEditingController _versionController = TextEditingController();
  final TextEditingController _releaseDateController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _versionFocusNode = FocusNode();

  bool _showAddPatch = false;
  bool _isSaving = false;

  void showAddPatchForm() {
    setState(() {
      _showAddPatch = true;
    });
  }

  void toggleAddPatch() {
    setState(() {
      _showAddPatch = !_showAddPatch;
    });
  }

  Future<void> addPatch() async {
    final version = _versionController.text.trim();
    final releaseDate = _releaseDateController.text.trim();

    if (version.isEmpty || releaseDate.isEmpty) {
      return;
    }

    final createdAt = PatchFormatters.parseReleaseDate(releaseDate);

    if (createdAt == null) {
      AppSnackBar.showCentered(context, 'Enter release date as dd.mm.yyyy');
      return;
    }

    final repository = ref.read(patchRepositoryProvider);
    final duplicatePatch = await repository.findDuplicatePatchForCurrentList(
      widget.listId,
    );

    if (duplicatePatch != null) {
      if (!mounted) {
        return;
      }

      final confirmed = await showDuplicatePatchConfirmationDialog(
        context,
        duplicatePatch: duplicatePatch,
      );

      if (!confirmed || !mounted) {
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      await repository.createPatchFromCurrentList(
            widget.listId,
            label: version,
            createdAt: createdAt,
          );

      ref.invalidate(rankingListPatchesProvider(widget.listId));
      ref.invalidate(currentListDuplicatePatchProvider(widget.listId));

      if (!mounted) {
        return;
      }

      setState(() {
        _versionController.clear();
        _releaseDateController.clear();
        _showAddPatch = false;
      });

      AppSnackBar.showCentered(context, 'Patch saved');
    } catch (error) {
      if (mounted) {
        AppSnackBar.showCentered(context, ErrorMapper.userMessage(error));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void closeForm() {
    setState(() {
      _showAddPatch = false;
    });
  }

  void _openPatch(String patchId) {
    context.push(
      AppRoutes.rankingListPatchById(
        widget.listId,
        patchId,
      ),
    );
  }

  Future<void> _editPatch(RankingListPatch patch) async {
    final result = await EditPatchDialog.show(
      context,
      patch: patch,
    );

    if (result == null || !mounted) {
      return;
    }

    if (result.action == EditPatchAction.delete) {
      await _deletePatch(patch);
      return;
    }

    final releaseDate = result.releaseDate;
    final label = result.label;

    if (releaseDate == null || label == null) {
      return;
    }

    final createdAt = PatchFormatters.parseReleaseDate(releaseDate);

    if (createdAt == null) {
      AppSnackBar.showCentered(context, 'Enter release date as dd.mm.yyyy');
      return;
    }

    try {
      await ref.read(patchRepositoryProvider).updatePatch(
            RankingListPatch(
              id: patch.id,
              listId: patch.listId,
              label: label,
              createdAt: createdAt,
            ),
          );

      ref.invalidate(rankingListPatchesProvider(widget.listId));
      ref.invalidate(currentListDuplicatePatchProvider(widget.listId));

      if (mounted) {
        AppSnackBar.showCentered(context, 'Patch updated');
      }
    } catch (error) {
      if (mounted) {
        AppSnackBar.showCentered(context, ErrorMapper.userMessage(error));
      }
    }
  }

  Future<void> _deletePatch(RankingListPatch patch) async {
    try {
      await ref.read(patchRepositoryProvider).deletePatch(patch.id);

      ref.invalidate(rankingListPatchesProvider(widget.listId));
      ref.invalidate(rankingListPatchByIdProvider(patch.id));
      ref.invalidate(patchEntriesProvider(patch.id));
      ref.invalidate(currentListDuplicatePatchProvider(widget.listId));

      if (mounted) {
        AppSnackBar.showCentered(context, 'Deleted: ${patch.label}');
      }
    } catch (error) {
      if (mounted) {
        AppSnackBar.showCentered(context, ErrorMapper.userMessage(error));
      }
    }
  }

  @override
  void dispose() {
    _versionController.dispose();
    _releaseDateController.dispose();
    _scrollController.dispose();
    _versionFocusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patchesAsync = ref.watch(rankingListPatchesProvider(widget.listId));
    final currentDuplicatePatch = ref
        .watch(currentListDuplicatePatchProvider(widget.listId))
        .valueOrNull;

    return Stack(
      children: [
        Positioned.fill(
          child: patchesAsync.when(
            loading: () => const AppLoadingIndicator(),
            error: (error, _) => Center(
              child: EmptyStateMessage(
                message: ErrorMapper.userMessage(error),
                bottomPadding: 0,
                color: Colors.white,
              ),
            ),
            data: (patches) {
              if (patches.isEmpty) {
                return const EmptyStateMessage(
                  message: 'No patches yet',
                  bottomPadding: 0,
                  color: Colors.white,
                );
              }

              return Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                trackVisibility: true,
                thickness: 5,
                radius: const Radius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      right: 8,
                      bottom: 3,
                    ),
                    itemCount: patches.length,
                    itemBuilder: (context, index) {
                      final patch = patches[index];

                      return PatchNoteCard(
                        number: index + 1,
                        version: patch.label,
                        releaseDate:
                            PatchFormatters.formatReleaseDate(patch.createdAt),
                        isEditMode: widget.isEditMode,
                        isCurrentSnapshot:
                            currentDuplicatePatch?.id == patch.id,
                        onPressed: widget.isEditMode
                            ? () => _editPatch(patch)
                            : () => _openPatch(patch.id),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
        if (_showAddPatch)
          Positioned(
            top: 5,
            left: 0,
            right: 0,
            child: PatchNoteForm(
              versionController: _versionController,
              releaseDateController: _releaseDateController,
              versionFocusNode: _versionFocusNode,
              onAdd: addPatch,
              isSaving: _isSaving,
            ),
          ),
      ],
    );
  }
}
