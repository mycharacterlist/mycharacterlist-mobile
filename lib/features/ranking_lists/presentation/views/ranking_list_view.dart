import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/app/assets/app_background_assets.dart';
import 'package:mycharacterlist/app/widgets/layout/app_appbar.dart';
import 'package:mycharacterlist/app/widgets/layout/bottom_action_slot.dart';
import 'package:mycharacterlist/app/widgets/layout/screen_scaffold.dart';
import 'package:mycharacterlist/app/widgets/utils/system_view_padding.dart';
import 'package:mycharacterlist/core/presentation/listeners/view_model_error_listener.dart';
import 'package:mycharacterlist/core/theme/app_colors.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/viewmodels/ranking_characters_view_model.dart';
import 'package:mycharacterlist/features/patches/presentation/controllers/patch_controller.dart';
import 'package:mycharacterlist/features/patches/presentation/widgets/patch_action_button.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/inside_list/add_character_button.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/inside_list/ranking_characters_list.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_providers.dart';

class RankingListView extends ConsumerWidget {
  const RankingListView({
    super.key,
    required this.listId,
  });

  final String listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentList = ref.watch(rankingListByIdProvider(listId));
    final charactersState = ref.watch(rankingCharactersViewModelProvider(listId));
    final content = ref.watch(rankedListContentProvider(listId));
    final controller = ref.watch(rankingListControllerProvider(listId));
    final patchController = ref.watch(patchControllerProvider(listId));

    listenViewModelError(
      ref,
      provider: rankingCharactersViewModelProvider(listId),
      selectError: (state) => (state as RankingCharactersState).errorMessage,
      clearError: () => ref
          .read(rankingCharactersViewModelProvider(listId).notifier)
          .clearError(),
      context: context,
    );

    if (currentList == null) {
      return const Scaffold(
        body: Center(child: Text('List not found')),
      );
    }

    return PopScope(
      canPop: !charactersState.isEditMode,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && charactersState.isEditMode) {
          controller.exitEditMode();
        }
      },
      child: ScreenScaffold(
        resizeToAvoidBottomInset: false,
        backgroundAssetPath: AppBackgroundAssets.rankingList,
        appBar: CustomAppBar(
          title: currentList.name,
          backgroundColor: AppColors.rankingAppBarBackground,
          backButtonColor: Colors.purple,
          titleColor: Colors.limeAccent,
          onBackPressed:
              charactersState.isEditMode ? controller.exitEditMode : null,
          actionWidget: IconButton(
            icon: Icon(
              charactersState.isEditMode ? Icons.check : Icons.edit_note,
              color: Colors.white,
            ),
            onPressed: controller.toggleEditMode,
          ),
        ),
        overlays: [
          if (!charactersState.isEditMode) ...[
            BottomActionSlot(
              bottomMargin: 12,
              child: GestureDetector(
                onTap: () => controller.openAddCharacterFlow(context),
                child: const AddCharacterButton(),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 12 + SystemViewPadding.bottomOf(context),
              child: GestureDetector(
                onTap: () => patchController.showPatchOptionsSheet(context),
                child: const PatchActionButton(),
              ),
            ),
          ],
        ],
        child: RankingCharactersList(
          listId: listId,
          content: content,
          isEditMode: charactersState.isEditMode,
        ),
      ),
    );
  }
}
