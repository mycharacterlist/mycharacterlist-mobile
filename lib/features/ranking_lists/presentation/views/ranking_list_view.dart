import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/app/widgets/app_appbar.dart';
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
            child: DecoratedBox(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/InsideListMain_bg.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          _buildBody(context, ref, content, charactersState.isEditMode),
          if (!charactersState.isEditMode)
            Positioned(
              bottom: 20,
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

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    RankedListContent content,
    bool isEditMode,
  ) {
    if (content.isLoadingCharacters || content.isLoadingLibrary) {
      return const Center(child: CircularProgressIndicator());
    }

    if (content.isEmpty) {
      return const Center(
        child: Text(
          'List is empty',
          style: TextStyle(fontSize: 24, color: Colors.white),
        ),
      );
    }

    if (content.libraryFailed) {
      return const Center(
        child: Text(
          'Failed to load characters',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      );
    }

    final controller = ref.read(rankingListControllerProvider(listId));

    return Scrollbar(
      thumbVisibility: true,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, top: 16, bottom: 120),
        child: ReorderableListView.builder(
          padding: const EdgeInsets.only(right: 16),
          buildDefaultDragHandles: false,
          proxyDecorator: (child, index, animation) {
            return Material(color: Colors.transparent, child: child);
          },
          itemCount: content.items.length,
          onReorder: !isEditMode
              ? (_, __) {}
              : controller.reorderCharacters,
          itemBuilder: (context, index) {
            final item = content.items[index];

            return RankingCharacterCard(
              key: ValueKey(item.id),
              index: item.position,
              title: item.title,
              subtitle: item.subtitle,
              dragHandle: isEditMode
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
