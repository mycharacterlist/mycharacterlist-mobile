import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/assets/app_background_assets.dart';
import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/layout/app_appbar.dart';
import 'package:mycharacterlist/app/widgets/feedback/app_loading_indicator.dart';
import 'package:mycharacterlist/app/widgets/layout/bottom_action_slot.dart';
import 'package:mycharacterlist/app/widgets/layout/screen_scaffold.dart';
import 'package:mycharacterlist/core/presentation/listeners/view_model_error_listener.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/viewmodels/lists_view_model.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/lists_page/create_new_button.dart';
import 'package:mycharacterlist/core/theme/app_colors.dart';
import 'package:mycharacterlist/core/theme/screen_app_bar_styles.dart';
import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranking_list.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_providers.dart';

class ListsView extends ConsumerWidget {
  const ListsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(listsViewModelProvider);
    final controller = ref.watch(listsPageControllerProvider);

    listenViewModelError(
      ref,
      provider: listsViewModelProvider,
      selectError: (next) => (next as ListsState).errorMessage,
      clearError: () => ref.read(listsViewModelProvider.notifier).clearError(),
      context: context,
    );

    return ScreenScaffold(
      resizeToAvoidBottomInset: false,
      backgroundAssetPath: AppBackgroundAssets.lists,
      appBar: CustomAppBar(
        title: state.isEditMode ? 'Select list' : 'My Lists',
        backgroundColor: AppScreenAppBars.lists.backgroundColor,
        backButtonColor: AppScreenAppBars.lists.backButtonColor,
        titleColor: AppScreenAppBars.lists.titleColor,
        onBackPressed: state.isEditMode ? controller.exitEditMode : null,
        actionWidget: IconButton(
          onPressed: controller.toggleEditMode,
          icon: Icon(state.isEditMode ? Icons.close : Icons.edit),
          color: AppColors.listsMagenta,
          tooltip: state.isEditMode ? 'Cancel editing' : 'Edit list',
        ),
      ),
      overlays: [
        if (!state.isEditMode)
          BottomActionSlot(
            bottomMargin: 40,
            child: CreateNewButton(
              text: 'Create new',
              onPressed: () => controller.showCreateDialog(context),
            ),
          ),
      ],
      child: SafeArea(
        maintainBottomViewPadding: true,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 120),
          child: state.isLoading && state.lists.isEmpty
              ? const AppLoadingIndicator()
              : state.lists.isEmpty
                  ? const Center(
                      child: Text(
                        'No lists yet',
                        style: TextStyle(
                          fontSize: 24,
                          color: AppColors.listsGold,
                          fontFamily: 'JpAnimeFont',
                        ),
                      ),
                    )
                  : _RankingListsReorderableList(
                      lists: state.lists,
                      isEditMode: state.isEditMode,
                      onReorder: (oldIndex, newIndex) => ref
                          .read(listsViewModelProvider.notifier)
                          .reorderLists(oldIndex, newIndex),
                      onListPressed: (list) {
                        if (state.isEditMode) {
                          controller.showEditDialog(context, list);
                          return;
                        }

                        context.push(AppRoutes.rankingListById(list.id));
                      },
                    ),
        ),
      ),
    );
  }
}

class _RankingListsReorderableList extends StatefulWidget {
  const _RankingListsReorderableList({
    required this.lists,
    required this.isEditMode,
    required this.onReorder,
    required this.onListPressed,
  });

  final List<RankingList> lists;
  final bool isEditMode;
  final void Function(int oldIndex, int newIndex) onReorder;
  final ValueChanged<RankingList> onListPressed;

  @override
  State<_RankingListsReorderableList> createState() =>
      _RankingListsReorderableListState();
}

class _RankingListsReorderableListState
    extends State<_RankingListsReorderableList> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: ReorderableListView.builder(
        scrollController: _scrollController,
        padding: const EdgeInsets.only(top: 20),
        buildDefaultDragHandles: false,
        itemCount: widget.lists.length,
        onReorder: widget.isEditMode ? widget.onReorder : (_, __) {},
        proxyDecorator: (child, index, animation) {
          return Material(
            color: Colors.transparent,
            elevation: 6,
            shadowColor: Colors.black45,
            child: ScaleTransition(
              scale: Tween<double>(
                begin: 1,
                end: 1.03,
              ).animate(animation),
              child: child,
            ),
          );
        },
        itemBuilder: (context, index) {
          final list = widget.lists[index];

          return Padding(
            key: ValueKey(list.id),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 10,
            ),
            child: _RankingListCard(
              list: list,
              index: index,
              isEditMode: widget.isEditMode,
              onPressed: () => widget.onListPressed(list),
            ),
          );
        },
      ),
    );
  }
}

class _RankingListCard extends StatelessWidget {
  const _RankingListCard({
    required this.list,
    required this.index,
    required this.isEditMode,
    required this.onPressed,
  });

  final RankingList list;
  final int index;
  final bool isEditMode;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.listsCardStart,
            Color(list.colorValue),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: isEditMode
            ? Border.all(
                color: AppColors.listsMagenta,
                width: 3,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
        ),
        onPressed: onPressed,
        child: isEditMode
            ? ReorderableDelayedDragStartListener(
                index: index,
                child: _RankingListCardContent(
                  list: list,
                  isEditMode: isEditMode,
                ),
              )
            : _RankingListCardContent(
                list: list,
                isEditMode: isEditMode,
              ),
      ),
    );
  }
}

class _RankingListCardContent extends StatelessWidget {
  const _RankingListCardContent({
    required this.list,
    required this.isEditMode,
  });

  final RankingList list;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    return Row(
          children: [
            const SizedBox(width: 40),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    list.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: const TextStyle(
                      fontSize: 22,
                      height: 1.05,
                      fontFamily: 'JpAnimeFont',
                      color: AppColors.listsGold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 40,
              child: isEditMode
                  ? const Icon(
                      Icons.edit,
                      color: AppColors.listsMagenta,
                    )
                  : null,
            ),
          ],
    );
  }
}
