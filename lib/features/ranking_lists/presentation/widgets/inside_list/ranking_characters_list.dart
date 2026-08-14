import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/feedback/app_loading_indicator.dart';
import 'package:mycharacterlist/app/widgets/layout/empty_state_message.dart';
import 'package:mycharacterlist/app/widgets/utils/system_view_padding.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/state/ranked_character_display_item.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/state/ranked_list_content.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/viewmodels/ranking_characters_view_model.dart';
import 'package:mycharacterlist/features/ranking_lists/presentation/widgets/inside_list/ranking_character_card.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_providers.dart';

class RankingCharactersList extends ConsumerStatefulWidget {
  const RankingCharactersList({
    super.key,
    required this.listId,
    required this.content,
    required this.isEditMode,
    this.allowEditing = true,
    this.onItemTap,
    this.cardColorOpacity = 1,
    this.unavailableCardColorOpacity = 1,
    this.cardColorOpacityBuilder,
    this.bottomContentPadding = 84,
  });

  final String listId;
  final RankedListContent content;
  final bool isEditMode;
  final bool allowEditing;
  final ValueChanged<RankedCharacterDisplayItem>? onItemTap;
  final double cardColorOpacity;
  final double unavailableCardColorOpacity;
  final double Function(RankedCharacterDisplayItem item)? cardColorOpacityBuilder;
  final double bottomContentPadding;

  @override
  ConsumerState<RankingCharactersList> createState() =>
      _RankingCharactersListState();
}

class _RankingCharactersListState extends ConsumerState<RankingCharactersList> {
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
  void didUpdateWidget(covariant RankingCharactersList oldWidget) {
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
    RankingCharactersList oldWidget,
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

    if (widget.isEditMode && widget.allowEditing) {
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
          currentItem.subtitle != incomingItem.subtitle ||
          currentItem.isCharacterAvailable !=
              incomingItem.isCharacterAvailable) {
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
        isCharacterAvailable: item.isCharacterAvailable,
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
    if (!widget.allowEditing) {
      return;
    }

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
    if (!widget.allowEditing) {
      return;
    }

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

  VoidCallback? _onItemTap(RankedCharacterDisplayItem item) {
    if (!item.isCharacterAvailable) {
      return null;
    }

    if (widget.isEditMode && widget.allowEditing) {
      return () => ref
          .read(rankingListControllerProvider(widget.listId))
          .showRemoveCharacterSheet(context, item);
    }

    if (widget.onItemTap != null) {
      return () => widget.onItemTap!(item);
    }

    if (item.characterId.isNotEmpty) {
      return () => context.push(AppRoutes.characterById(item.characterId));
    }

    return null;
  }

  double _cardColorOpacityFor(RankedCharacterDisplayItem item) {
    final customOpacity = widget.cardColorOpacityBuilder?.call(item);
    if (customOpacity != null) {
      return customOpacity;
    }

    if (!item.isCharacterAvailable) {
      return widget.unavailableCardColorOpacity;
    }

    return widget.cardColorOpacity;
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.content;

    if (content.isLoadingCharacters) {
      return const AppLoadingIndicator();
    }

    if (content.isEmpty) {
      return const EmptyStateMessage(
        message: 'List is empty',
        color: Colors.limeAccent,
      );
    }

    final displayItems = _items.isNotEmpty ? _items : content.items;

    if (displayItems.isEmpty) {
      return const AppLoadingIndicator();
    }

    final animateMarquee = !widget.isEditMode || !_isDragging;
    final bottomInset = SystemViewPadding.bottomOf(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        top: 16,
        bottom: widget.bottomContentPadding + bottomInset,
      ),
      child: RawScrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        thickness: 5,
        radius: const Radius.circular(10),
        mainAxisMargin: 0,
        padding: EdgeInsets.zero,
        child: Listener(
          onPointerUp: (_) => _setDragging(false),
          onPointerCancel: (_) => _setDragging(false),
          child: ReorderableListView.builder(
            scrollController: _scrollController,
            padding: const EdgeInsets.only(right: 16),
            buildDefaultDragHandles: false,
            proxyDecorator: (child, index, animation) {
              final item = displayItems[index];
              final colorOpacity = _cardColorOpacityFor(item);

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
                  isCharacterAvailable: item.isCharacterAvailable,
                  colorOpacity: colorOpacity,
                ),
              );
            },
            itemCount: displayItems.length,
            onReorder:
                widget.isEditMode && widget.allowEditing
                    ? _handleReorder
                    : (_, __) {},
            itemBuilder: (context, index) {
              final item = displayItems[index];
              final colorOpacity = _cardColorOpacityFor(item);

              return RankingCharacterCard(
                key: ValueKey(item.id),
                itemId: item.id,
                index: item.position,
                title: item.title,
                subtitle: item.subtitle,
                isEditMode: widget.isEditMode && widget.allowEditing,
                animateMarquee: animateMarquee,
                isCharacterAvailable: item.isCharacterAvailable,
                colorOpacity: colorOpacity,
                bottomSpacing: index == displayItems.length - 1 ? 0 : 16,
                maxPosition: displayItems.length,
                onPositionSubmitted: widget.isEditMode && widget.allowEditing
                    ? (targetPosition) =>
                          _handleMoveToPosition(item.id, targetPosition)
                    : null,
                dragHandle: widget.isEditMode && widget.allowEditing
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
                onTap: _onItemTap(item),
              );
            },
          ),
        ),
      ),
    );
  }
}
