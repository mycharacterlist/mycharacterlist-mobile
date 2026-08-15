import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/app/assets/app_background_assets.dart';
import 'package:mycharacterlist/app/widgets/layout/app_appbar.dart';
import 'package:mycharacterlist/app/widgets/layout/screen_scaffold.dart';
import 'package:mycharacterlist/core/theme/app_colors.dart';
import 'package:mycharacterlist/features/patches/patch_providers.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/inside_list/ranking_characters_list.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_providers.dart';

class RankingListPatchDetailPage extends ConsumerWidget {
  const RankingListPatchDetailPage({
    super.key,
    required this.listId,
    required this.patchId,
  });

  final String listId;
  final String patchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentList = ref.watch(rankingListByIdProvider(listId));
    final currentPatch = ref.watch(rankingListPatchByIdProvider(patchId));
    final content = ref.watch(patchDisplayContentProvider(patchId));
    final title = currentPatch.maybeWhen(
      data: (patch) => patch?.label ?? currentList?.name ?? 'Patch detail',
      orElse: () => currentList?.name ?? 'Patch detail',
    );

    return ScreenScaffold(
      resizeToAvoidBottomInset: false,
      backgroundAssetPath: AppBackgroundAssets.patches,
      appBar: CustomAppBar(
        title: title,
        backgroundColor: AppColors.InsidePatchAppBarBackground,
        backButtonColor: Colors.black,
        titleColor: const Color(0xFF7A789A),
      ),
      child: RankingCharactersList(
        listId: listId,
        content: content,
        isEditMode: false,
        allowEditing: false,
        unavailableCardColorOpacity: 0.50,
        bottomContentPadding: 16,
      ),
    );
  }
}
