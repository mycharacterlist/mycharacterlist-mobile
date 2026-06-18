import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/assets/app_background_assets.dart';
import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/layout/app_appbar.dart';
import 'package:mycharacterlist/app/widgets/feedback/app_loading_indicator.dart';
import 'package:mycharacterlist/app/widgets/layout/screen_scaffold.dart';
import 'package:mycharacterlist/app/widgets/utils/system_view_padding.dart';
import 'package:mycharacterlist/core/theme/app_colors.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/inside_list/ranking_character_card.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_providers.dart';

class RankingListPatchDetailPage extends StatelessWidget {
  const RankingListPatchDetailPage({
    super.key,
    required this.listId,
    required this.patchId,
  });

  final String listId;
  final String patchId;

  @override
  Widget build(BuildContext context) {
    return RankingListPatchDetailView(
      listId: listId,
      patchId: patchId,
    );
  }
}

class RankingListPatchDetailView extends ConsumerWidget {
  const RankingListPatchDetailView({
    super.key,
    required this.listId,
    required this.patchId,
  });

  final String listId;
  final String patchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final patchAsync = ref.watch(rankingListPatchByIdProvider(patchId));
    final contentAsync = ref.watch(patchDisplayContentProvider(patchId));
    final bottomInset = SystemViewPadding.bottomOf(context);

    return ScreenScaffold(
      resizeToAvoidBottomInset: false,
      backgroundAssetPath: AppBackgroundAssets.rankingList,
      appBar: CustomAppBar(
        title: patchAsync.valueOrNull?.label ?? 'Patch',
        backgroundColor: AppColors.rankingAppBarBackground,
        backButtonColor: Colors.purple,
        titleColor: Colors.limeAccent,
      ),
      child: contentAsync.when(
        loading: () => const AppLoadingIndicator(),
        error: (error, _) => Center(
          child: Text(
            error.toString(),
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
        data: (content) {
          return Scrollbar(
            thumbVisibility: true,
            child: ListView.separated(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomInset),
              itemCount: content.items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final item = content.items[index];

                return RankingCharacterCard(
                  key: ValueKey(item.id),
                  itemId: item.id,
                  index: item.position,
                  title: item.title,
                  subtitle: item.subtitle,
                  animateMarquee: true,
                  onTap: item.isCharacterAvailable
                      ? () => context.push(
                            AppRoutes.characterById(item.characterId),
                          )
                      : null,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
