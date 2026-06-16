import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/assets/app_background_assets.dart';
import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/app_appbar.dart';
import 'package:mycharacterlist/app/widgets/app_background_image.dart';
import 'package:mycharacterlist/app/widgets/bottom_action_slot.dart';
import 'package:mycharacterlist/core/platform/platform_file_helper.dart';
import 'package:mycharacterlist/features/library/library_providers.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_providers.dart';
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
    charactersScrollController.addListener(_loadMore);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(charactersViewModelProvider.notifier).resetInBackground();
    });
  }

  void _loadMore() {
    if (!charactersScrollController.hasClients ||
        charactersScrollController.position.extentAfter > 300) {
      return;
    }
    ref.read(charactersViewModelProvider.notifier).loadMore();
  }

  void _search(String query) {
    _resetListPosition();
    ref.read(charactersViewModelProvider.notifier).search(query);
  }

  void _clearSearch() {
    if (searchController.text.isEmpty) {
      return;
    }

    searchController.clear();
    _search('');
  }

  void _unfocusSearch() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _resetListPosition() {
    if (charactersScrollController.hasClients) {
      charactersScrollController.jumpTo(0);
    }
  }

  void _scheduleSearchReset() {
    final notifier = ref.read(charactersViewModelProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifier.resetInBackground();
    });
  }

  void _leaveLibrary() {
    _unfocusSearch();
    context.pop();
  }

  void _openPage(String route, {bool resetSearch = true}) {
    _unfocusSearch();
    if (resetSearch) {
      searchController.clear();
      filters = const CharacterFilters();
      _scheduleSearchReset();
    }
    context.push(route);
  }

  Future<void> _importCharacters() async {
    _unfocusSearch();
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result == null || result.files.isEmpty || !mounted) {
      return;
    }

    final path = await PlatformFileHelper.resolvePickedFilePath(
      result.files.single,
    );

    if (path == null || !mounted) {
      return;
    }

    final importResult = await ref
        .read(charactersViewModelProvider.notifier)
        .importFile(path);
    ref.invalidate(characterNameSuggestionsProvider);
    ref.invalidate(libraryCharactersProvider);
    ref.invalidate(rankingCharactersViewModelProvider);
    await ref.read(listsViewModelProvider.notifier).loadLists();
    await ref.read(characterReferencesViewModelProvider.notifier).load();

    if (mounted && importResult != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(importResult.message, textAlign: TextAlign.center),
        ),
      );
    }
  }

  Future<void> _exportCharacters() async {
    _unfocusSearch();
    final directoryPath = await PlatformFileHelper.pickExportDirectory(
      dialogTitle: 'Select export folder',
    );
    if (directoryPath == null || !mounted) {
      return;
    }

    final exportResult = await ref
        .read(charactersViewModelProvider.notifier)
        .exportToDirectory(directoryPath);

    if (mounted && exportResult != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(exportResult.message, textAlign: TextAlign.center),
        ),
      );
    }
  }

  Future<void> _showTransferActions() async {
    _unfocusSearch();
    final action = await showModalBottomSheet<_LibraryTransferAction>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_download_outlined),
              title: const Text('Import JSON'),
              onTap: () =>
                  sheetContext.pop(_LibraryTransferAction.importCharacters),
            ),
            ListTile(
              leading: const Icon(Icons.file_upload_outlined),
              title: const Text('Export all'),
              onTap: () =>
                  sheetContext.pop(_LibraryTransferAction.exportCharacters),
            ),
          ],
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    switch (action) {
      case _LibraryTransferAction.importCharacters:
        await _importCharacters();
        return;
      case _LibraryTransferAction.exportCharacters:
        await _exportCharacters();
        return;
      case null:
        return;
    }
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
    searchController.dispose();
    charactersScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(charactersViewModelProvider);
    ref.watch(characterReferencesViewModelProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _leaveLibrary();
        }
      },
      child: Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(
        title: 'Library',
        backgroundColor: const Color(0xFF1A4043),
        backButtonColor: const Color(0xFF009768),
        titleColor: const Color(0xFF4CB897),
        onBackPressed: _leaveLibrary,
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _unfocusSearch,
        child: Stack(
          children: [
            Positioned.fill(
              child: AppBackgroundImage(
                assetPath: AppBackgroundAssets.library,
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  SearchBarWidget(
                    controller: searchController,
                    onChanged: _search,
                    onClearPressed: _clearSearch,
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
                                itemCount:
                                    state.characters.length +
                                    (state.isLoadingMore ? 1 : 0),
                                itemBuilder: (context, index) {
                                  if (index == state.characters.length) {
                                    return const Padding(
                                      padding: EdgeInsets.all(16),
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }
                                  final character = state.characters[index];
                                  return LibraryCard(
                                    key: ValueKey(character.id),
                                    mainText: character.name,
                                    sideText: character.sourceTitle,
                                    index: index,
                                    onPressed: () => _openPage(
                                      AppRoutes.characterById(character.id),
                                      resetSearch: false,
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
            BottomActionSlot(
              bottomMargin: 20,
              child: PlusButton(
                icon: const Icon(Icons.add, color: Colors.black, size: 45),
                onPressed: () => _openPage(AppRoutes.characterCreate),
                onLongPress: state.isImporting || state.isExporting
                    ? null
                    : _showTransferActions,
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

enum _LibraryTransferAction { importCharacters, exportCharacters }
