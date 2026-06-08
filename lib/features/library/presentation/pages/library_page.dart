import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/app_appbar.dart';
import 'package:mycharacterlist/features/library/library_providers.dart';
import 'package:mycharacterlist/features/library/domain/entities/character_filters.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/library_widgets/Plus_button.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/library_widgets/library_card.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/library_widgets/library_filter_sheet.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/library_widgets/search_bar_widget.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  final searchController = TextEditingController();
  final charactersScrollController = ScrollController();
  CharacterFilters filters = const CharacterFilters();

  @override
  void initState() {
    super.initState();
    searchController.addListener(_search);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(charactersViewModelProvider.notifier).reset();
    });
  }

  void _search() {
    _resetListPosition();
    ref
        .read(charactersViewModelProvider.notifier)
        .search(searchController.text);
  }

  void _unfocusSearch() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _resetListPosition() {
    if (charactersScrollController.hasClients) {
      charactersScrollController.jumpTo(0);
    }
  }

  void _resetSearch() {
    _unfocusSearch();
    searchController
      ..removeListener(_search)
      ..clear()
      ..addListener(_search);
    filters = const CharacterFilters();
    _resetListPosition();
    ref.read(charactersViewModelProvider.notifier).reset();
  }

  void _openPage(String route) {
    _resetSearch();
    context.push(route);
  }

  void showFilterSheet() {
    _unfocusSearch();
    final references = ref.read(characterReferencesViewModelProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFD9D4D9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      builder: (sheetContext) => LibraryFilterSheet(
        filters: filters,
        animeTitles: references.animeTitles,
        archetypes: references.archetypes,
        onClear: () {
          filters = const CharacterFilters();
          _resetListPosition();
          ref.read(charactersViewModelProvider.notifier).clearFilters();
          sheetContext.pop();
        },
        onApply: (value) {
          filters = value;
          _resetListPosition();
          ref.read(charactersViewModelProvider.notifier).applyFilters(value);
          sheetContext.pop();
        },
      ),
    );
  }

  @override
  void dispose() {
    searchController
      ..removeListener(_search)
      ..dispose();
    charactersScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(charactersViewModelProvider);
    ref.watch(characterReferencesViewModelProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        title: 'Library',
        backgroundColor: const Color(0xFF1A4043),
        backButtonColor: const Color(0xFF009768),
        titleColor: const Color(0xFF4CB897),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _unfocusSearch,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/Library_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  SearchBarWidget(
                    controller: searchController,
                    onFilterPressed: showFilterSheet,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 110),
                      child: state.isLoading && state.characters.isEmpty
                          ? const Center(child: CircularProgressIndicator())
                          : Scrollbar(
                              thumbVisibility: true,
                              controller: charactersScrollController,
                              child: ListView.builder(
                                controller: charactersScrollController,
                                padding: const EdgeInsets.only(top: 5),
                                itemCount: state.characters.length,
                                itemBuilder: (context, index) {
                                  final character = state.characters[index];
                                  return LibraryCard(
                                    key: ValueKey(character.id),
                                    mainText: character.name,
                                    sideText: character.sourceTitle,
                                    index: index,
                                    onPressed: () => _openPage(
                                      AppRoutes.characterById(character.id),
                                    ),
                                    onEditPressed: () => _openPage(
                                      AppRoutes.characterEditById(character.id),
                                    ),
                                  );
                                },
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Center(
                child: PlusButton(
                  icon: const Icon(Icons.add, color: Colors.black, size: 45),
                  onPressed: () => _openPage(AppRoutes.characterCreate),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
