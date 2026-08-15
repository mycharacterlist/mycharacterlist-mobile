import 'package:flutter/material.dart';

import 'package:mycharacterlist/features/patches/domain/entities/ranking_list_patch.dart';

Future<bool> showDuplicatePatchConfirmationDialog(
  BuildContext context, {
  required RankingListPatch duplicatePatch,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Patch already exists'),
      content: Text(
        'A patch with the same ranking already exists: '
        '"${duplicatePatch.label}". Create another one anyway?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Create'),
        ),
      ],
    ),
  );

  return confirmed ?? false;
}
