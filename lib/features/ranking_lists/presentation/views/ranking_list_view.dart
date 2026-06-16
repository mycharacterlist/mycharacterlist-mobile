import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/assets/app_background_assets.dart';
import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/app_appbar.dart';
import 'package:mycharacterlist/app/widgets/app_background_image.dart';
import 'package:mycharacterlist/app/widgets/bottom_action_slot.dart';
import 'package:mycharacterlist/app/widgets/empty_state_message.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/models/ranked_character_display_item.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/models/ranked_list_content.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/utils/view_model_error_listener.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/viewmodels/ranking_characters_view_model.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/inside_list/add_character_button.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/inside_list/ranking_character_card.dart';
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
      child: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        title: currentList.name,
        backgroundColor: const Color(0xFF091E7A),
        backButtonColor: Colors.purple,
        titleColor: Colors.limeAccent,
        onBackPressed: charactersState.isEditMode ? controller.exitEditMode : null,
        actionWidget: IconButton(
          icon: Icon(
            charactersState.isEditMode ? Icons.check : Icons.edit_note,
            color: Colors.white,
          ),
          onPressed: controller.toggleEditMode,
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: AppBackgroundImage(
              assetPath: AppBackgroundAssets.rankingList,
            ),
          ),
          _RankingCharactersList(
            listId: listId,
            content: content,
            isEditMode: charactersState.isEditMode,
          ),
          if (!charactersState.isEditMode)
            BottomActionSlot(
              bottomMargin: 12,
              child: GestureDetector(
                onTap: () => controller.openAddCharacterFlow(context),
                child: const AddCharacterButton(),
              ),
            ),
        ],
      ),
      ),
    );
  }
}

class _RankingCharactersList extends ConsumerStatefulWidget {
  const _RankingCharactersList({
    required this.listId,
    required this.content,
    required this.isEditMode,
  });

  final String listId;
  final RankedListContent content;
  final bool isEditMode;

  @override
  ConsumerState<_RankingCharactersList> createState() =>
      _RankingCharactersListState();
}

class _RankingCharactersListState extends ConsumerState<_RankingCharactersList> {
  final ScrollController _scrollController = ScrollController();
  late List<RankedCharacterDisplayItem> _items;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _items = List<RankedCharacterDisplayItem>.from(widget.content.items);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _RankingCharactersList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncItemsFromContent(widget.content, oldWidget);
  }

  void _scheduleItemsUpdate(List<RankedCharacterDisplayItem> items) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      setState(() => _items = items);
    });
  }

  void _syncItemsFromContent(
    RankedListContent content,
    _RankingCharactersList oldWidget,
  ) {
    if (content.isLoadingCharacters) {
      return;
    }

    if (content.isEmpty) {
      if (_items.isNotEmpty) {
        _scheduleItemsUpdate(const []);
      }
      return;
    }

    if (_items.isEmpty) {
      _items = List<RankedCharacterDisplayItem>.from(content.items);
      return;
    }

    if (widget.isEditMode) {
      final currentIds = _items.map((item) => item.id).toSet();
      final incomingIds = content.items.map((item) => item.id).toSet();

      if (currentIds.length != incomingIds.length ||
          !currentIds.containsAll(incomingIds)) {
        _scheduleItemsUpdate(
          List<RankedCharacterDisplayItem>.from(content.items),
        );
      }
      return;
    }

    if (!_hasSameDisplayItems(_items, content.items) ||
        (!widget.isEditMode && oldWidget.isEditMode)) {
      _scheduleItemsUpdate(
        List<RankedCharacterDisplayItem>.from(content.items),
      );
    }
  }

  bool _hasSameDisplayItems(
    List<RankedCharacterDisplayItem> currentItems,
    List<RankedCharacterDisplayItem> incomingItems,
  ) {
    if (currentItems.length != incomingItems.length) {
      return false;
    }

    for (var index = 0; index < currentItems.length; index++) {
      final currentItem = currentItems[index];
      final incomingItem = incomingItems[index];

      if (currentItem.id != incomingItem.id ||
          currentItem.characterId != incomingItem.characterId ||
          currentItem.position != incomingItem.position ||
          currentItem.title != incomingItem.title ||
          currentItem.subtitle != incomingItem.subtitle) {
        return false;
      }
    }

    return true;
  }

  List<RankedCharacterDisplayItem> _itemsWithUpdatedPositions(
    List<RankedCharacterDisplayItem> items,
  ) {
    return items.asMap().entries.map((entry) {
      final item = entry.value;

      return RankedCharacterDisplayItem(
        id: item.id,
        characterId: item.characterId,
        position: entry.key + 1,
        title: item.title,
        subtitle: item.subtitle,
      );
    }).toList();
  }

  void _setDragging(bool isDragging) {
    if (_isDragging == isDragging) {
      return;
    }

    setState(() => _isDragging = isDragging);
  }

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    var targetIndex = newIndex;

    if (targetIndex > oldIndex) {
      targetIndex--;
    }

    try {
      await _applyReorder(oldIndex, targetIndex);
    } finally {
      _setDragging(false);
    }
  }

  void _ensureItemsLoaded() {
    if (_items.isEmpty && widget.content.items.isNotEmpty) {
      _items = List<RankedCharacterDisplayItem>.from(widget.content.items);
    }
  }

  Future<void> _handleMoveToPosition(String itemId, int targetPosition) async {
    _ensureItemsLoaded();

    final listIndex = _items.indexWhere((item) => item.id == itemId);
    if (listIndex == -1) {
      return;
    }

    final targetIndex = targetPosition - 1;
    if (targetIndex == listIndex) {
      return;
    }

    await _applyReorder(listIndex, targetIndex);
  }

  Future<void> _applyReorder(int oldIndex, int targetIndex) async {
    _ensureItemsLoaded();

    final previousItems = List<RankedCharacterDisplayItem>.from(_items);
    final reorderedItems = List<RankedCharacterDisplayItem>.from(_items);
    final movedItem = reorderedItems.removeAt(oldIndex);
    reorderedItems.insert(targetIndex, movedItem);

    setState(() {
      _items = _itemsWithUpdatedPositions(reorderedItems);
    });

    final viewModel = ref.read(
      rankingCharactersViewModelProvider(widget.listId).notifier,
    );

    final newIndex = targetIndex < oldIndex ? targetIndex : targetIndex + 1;

    try {
      await viewModel.reorderAtIndices(oldIndex, newIndex);
    } catch (_) {
      if (mounted) {
        setState(() => _items = previousItems);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content;

    if (content.isLoadingCharacters) {
      return const Center(child: CircularProgressIndicator());
    }

    if (content.isEmpty) {
      return const EmptyStateMessage(
        message: 'List is empty',
        color: Colors.limeAccent,
      );
    }

    final displayItems = _items.isNotEmpty ? _items : content.items;

    if (displayItems.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final animateMarquee = !widget.isEditMode || !_isDragging;

    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: Padding(
        padding: EdgeInsets.only(left: 16, top: 16, bottom: 84 + bottomInset),
        child: Listener(
          onPointerUp: (_) => _setDragging(false),
          onPointerCancel: (_) => _setDragging(false),
          child: ReorderableListView.builder(
            scrollController: _scrollController,
            padding: const EdgeInsets.only(right: 16),
            buildDefaultDragHandles: false,
            proxyDecorator: (child, index, animation) {
              final item = displayItems[index];

              return Material(
                color: Colors.transparent,
                elevation: 6,
                shadowColor: Colors.black45,
                child: RankingCharacterCard(
                  itemId: item.id,
                  index: item.position,
                  title: item.title,
                  subtitle: item.subtitle,
                  animateMarquee: false,
                  isDragProxy: true,
                ),
              );
            },
            itemCount: displayItems.length,
            onReorder: widget.isEditMode ? _handleReorder : (_, __) {},
            itemBuilder: (context, index) {
              final item = displayItems[index];

              return RankingCharacterCard(
                key: ValueKey(item.id),
                itemId: item.id,
                index: item.position,
                title: item.title,
                subtitle: item.subtitle,
                isEditMode: widget.isEditMode,
                animateMarquee: animateMarquee,
                maxPosition: displayItems.length,
                onPositionSubmitted: widget.isEditMode
                    ? (targetPosition) =>
                          _handleMoveToPosition(item.id, targetPosition)
                    : null,
                dragHandle: widget.isEditMode
                    ? Listener(
                        onPointerDown: (_) => _setDragging(true),
                        child: ReorderableDragStartListener(
                          index: index,
                          child: const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: Icon(Icons.drag_handle, size: 40),
                          ),
                        ),
                      )
                    : null,
                onTap: widget.isEditMode
                    ? () => ref
                          .read(rankingListControllerProvider(widget.listId))
                          .showRemoveCharacterSheet(context, item)
                    : () => context.push(
                          AppRoutes.characterById(item.characterId),
                        ),
              );
            },
          ),
        ),
      ),
    );
  }
}
