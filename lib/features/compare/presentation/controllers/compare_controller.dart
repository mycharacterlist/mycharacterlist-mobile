import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/layout/bottom_sheet_padding.dart';
import 'package:mycharacterlist/core/theme/app_colors.dart';

enum _CompareSheetAction {
  characters,
  anime,
}

class CompareController {
  Future<void> showCompareOptionsSheet(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final action = await showModalBottomSheet<_CompareSheetAction>(
      context: context,
      useSafeArea: false,
      builder: (sheetContext) => BottomSheetPadding(
        bottomMargin: 8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.people_outline, color: AppColors.formAccent),
              title: const Text('Compare characters'),
              subtitle: const Text('Compare two characters side by side'),
              onTap: () => Navigator.pop(sheetContext, _CompareSheetAction.characters),
            ),
            ListTile(
              leading: const Icon(Icons.groups_outlined, color: AppColors.formAccent),
              title: const Text('Teams'),
              subtitle: const Text('Compare characters by anime'),
              onTap: () => Navigator.pop(sheetContext, _CompareSheetAction.anime),
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
      case _CompareSheetAction.characters:
        context.push(AppRoutes.compareCharacters);
      case _CompareSheetAction.anime:
        context.push(AppRoutes.compareAnime);
    }
  }
}

final compareControllerProvider = Provider<CompareController>(
  (ref) => CompareController(),
);
