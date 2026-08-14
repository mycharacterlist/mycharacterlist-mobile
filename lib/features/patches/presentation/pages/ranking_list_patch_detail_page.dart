import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/app/assets/app_background_assets.dart';
import 'package:mycharacterlist/app/widgets/layout/app_appbar.dart';
import 'package:mycharacterlist/app/widgets/layout/screen_scaffold.dart';
import 'package:mycharacterlist/core/theme/app_colors.dart';
import 'package:mycharacterlist/features/patches/patch_providers.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/state/ranked_character_display_item.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/state/ranked_list_content.dart';
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

  static const _testItems = [
    RankedCharacterDisplayItem(
      id: 'patch_test_1',
      characterId: '',
      position: 1,
      title: 'Mai Sakurajima',
      subtitle: 'Rascal Does Not Dream of Bunny Girl Senpai',
      isCharacterAvailable: false
    ),
    RankedCharacterDisplayItem(
      id: 'patch_test_2',
      characterId: '',
      position: 2,
      title: 'Saber Artoria Pendragon',
      subtitle: 'Fate/stay night',
      isCharacterAvailable: false,
    ),
    RankedCharacterDisplayItem(
      id: 'patch_test_3',
      characterId: '',
      position: 3,
      title: 'Makise Kurisu',
      subtitle: 'Steins;Gate',
      isCharacterAvailable: false,
    ),
    RankedCharacterDisplayItem(
      id: 'patch_test_4',
      characterId: '',
      position: 4,
      title: 'Violet Evergarden',
      subtitle: 'Violet Evergarden',
      isCharacterAvailable: false,
    ),
    RankedCharacterDisplayItem(
      id: 'patch_test_5',
      characterId: '',
      position: 5,
      title: 'Holo',
      subtitle: 'Spice and Wolf',
    ),
    RankedCharacterDisplayItem(
      id: 'patch_test_6',
      characterId: '',
      position: 6,
      title: 'Shinobu Oshino',
      subtitle: 'Monogatari Series',
    ),
    RankedCharacterDisplayItem(
      id: 'patch_test_7',
      characterId: '',
      position: 7,
      title: 'Frieren',
      subtitle: 'Frieren: Beyond Journey\'s End',
      isCharacterAvailable: false,
    ),
    RankedCharacterDisplayItem(
      id: 'patch_test_8',
      characterId: '',
      position: 8,
      title: 'Zero Two',
      subtitle: 'DARLING in the FRANXX',
    ),
    RankedCharacterDisplayItem(
      id: 'patch_test_9',
      characterId: '',
      position: 9,
      title: 'Megumin',
      subtitle: 'KonoSuba',
    ),
    RankedCharacterDisplayItem(
      id: 'patch_test_10',
      characterId: '',
      position: 10,
      title: 'Rin Tohsaka',
      subtitle: 'Fate/stay night',
      isCharacterAvailable: false,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentList = ref.watch(rankingListByIdProvider(listId));
    final currentPatch = ref.watch(rankingListPatchByIdProvider(patchId));
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
        content: const RankedListContent(items: _testItems),
        isEditMode: false,
        allowEditing: false,
        unavailableCardColorOpacity: 0.50,
      ),
    );
  }
}
