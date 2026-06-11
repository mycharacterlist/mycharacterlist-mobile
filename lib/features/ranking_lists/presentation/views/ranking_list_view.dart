import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/app/assets/app_background_assets.dart';
import 'package:mycharacterlist/app/widgets/app_appbar.dart';
import 'package:mycharacterlist/app/widgets/app_background_image.dart';
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
    final libraryCharactersAsync = ref.watch(libraryCharactersProvider);
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        title: currentList.name,
        backgroundColor: const Color(0xFF091E7A),
        backButtonColor: Colors.purple,
        titleColor: Colors.limeAccent,
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
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Center(
                child: libraryCharactersAsync.when(
                  data: (libraryCharacters) => GestureDetector(
                    onTap: () => controller.openAddCharacterFlow(
                      context,
                      libraryCharacters,
                    ),
                    child: const AddCharacterButton(),
                  ),
                  loading: () => const AddCharacterButton(),
                  error: (_, __) => const AddCharacterButton(),
                ),
              ),
            ),
        ],
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

  void _syncItemsFromContent(
    RankedListContent content,
    _RankingCharactersList oldWidget,
  ) {
    if (content.items.isEmpty) {
      if (_items.isNotEmpty) {
        setState(() => _items = const []);
      }
      return;
    }

    final currentIds = _items.map((item) => item.id).toSet();
    final incomingIds = content.items.map((item) => item.id).toSet();

    if (currentIds.length != incomingIds.length ||
        !currentIds.containsAll(incomingIds)) {
      setState(() => _items = List<RankedCharacterDisplayItem>.from(content.items));
      return;
    }

    if (!widget.isEditMode && oldWidget.isEditMode) {
      setState(() => _items = List<RankedCharacterDisplayItem>.from(content.items));
    }
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

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    var targetIndex = newIndex;

    if (targetIndex > oldIndex) {
      targetIndex--;
    }

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

    if (content.isLoadingCharacters && _items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (content.isEmpty || _items.isEmpty) {
      return const Center(
        child: Text(
          'List is empty',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      );
    }

    return Scrollbar(
      controller: _scrollController,
      thumbVisibility: true,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 16, bottom: 84),
        child: ReorderableListView.builder(
          scrollController: _scrollController,
          padding: const EdgeInsets.only(right: 16),
          buildDefaultDragHandles: false,
          proxyDecorator: (child, index, animation) {
            return Material(color: Colors.transparent, child: child);
          },
          itemCount: _items.length,
          onReorder: widget.isEditMode ? _handleReorder : (_, __) {},
          itemBuilder: (context, index) {
            final item = _items[index];

            return RankingCharacterCard(
              key: ValueKey(item.id),
              index: item.position,
              title: item.title,
              subtitle: item.subtitle,
              dragHandle: widget.isEditMode
                  ? ReorderableDragStartListener(
                      index: index,
                      child: const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(Icons.drag_handle, size: 40),
                      ),
                    )
                  : null,
            );
          },
        ),
      ),
    );
  }
}
