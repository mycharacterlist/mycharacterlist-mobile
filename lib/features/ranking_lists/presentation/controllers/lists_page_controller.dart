import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/viewmodels/lists_view_model.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/lists_page/create_list_dialog.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_providers.dart';

class ListsPageController {
  ListsPageController(this._ref);

  final Ref _ref;
  final TextEditingController nameController = TextEditingController();

  ListsViewModel get _viewModel => _ref.read(listsViewModelProvider.notifier);

  void toggleEditMode() => _viewModel.toggleEditMode();

  void exitEditMode() => _viewModel.exitEditMode();

  void showCreateDialog(BuildContext context) {
    nameController.clear();

    CreateListDialog.show(
      context: context,
      controller: nameController,
      onCreate: (selectedColor) => _submitCreate(context, selectedColor),
    );
  }

  void showEditDialog(BuildContext context, RankingList list) {
    _viewModel.exitEditMode();
    nameController.text = list.name;

    CreateListDialog.show(
      context: context,
      controller: nameController,
      initialColor: Color(list.colorValue),
      title: 'Edit list',
      submitLabel: 'Save',
      onCreate: (selectedColor) => _submitUpdate(context, list, selectedColor),
      onDelete: () => confirmDeleteList(context, list),
    );
  }

  Future<void> confirmDeleteList(BuildContext context, RankingList list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete list?'),
        content: const Text(
          'The list and all character positions inside it will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final deleted = await _viewModel.deleteList(list.id);

    if (!context.mounted || !deleted) {
      return;
    }

    nameController.clear();
    Navigator.pop(context);
  }

  Future<void> _submitCreate(BuildContext context, Color selectedColor) async {
    final created = await _viewModel.createList(
      name: nameController.text,
      color: selectedColor,
    );

    if (!context.mounted || !created) {
      return;
    }

    nameController.clear();
    Navigator.pop(context);
  }

  Future<void> _submitUpdate(
    BuildContext context,
    RankingList list,
    Color selectedColor,
  ) async {
    final updated = await _viewModel.updateList(
      list: list,
      name: nameController.text,
      color: selectedColor,
    );

    if (!context.mounted || !updated) {
      return;
    }

    nameController.clear();
    Navigator.pop(context);
  }

  void dispose() {
    nameController.dispose();
  }
}
