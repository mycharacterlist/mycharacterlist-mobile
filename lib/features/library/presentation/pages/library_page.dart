import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/assets/app_background_assets.dart';
import 'package:mycharacterlist/app/router/routes.dart';
import 'package:mycharacterlist/app/widgets/layout/app_appbar.dart';
import 'package:mycharacterlist/app/widgets/feedback/app_loading_indicator.dart';
import 'package:mycharacterlist/app/widgets/feedback/app_loading_overlay.dart';
import 'package:mycharacterlist/app/widgets/layout/bottom_action_slot.dart';
import 'package:mycharacterlist/app/widgets/layout/bottom_sheet_padding.dart';
import 'package:mycharacterlist/app/widgets/layout/empty_state_message.dart';
import 'package:mycharacterlist/app/widgets/layout/screen_scaffold.dart';
import 'package:mycharacterlist/core/platform/platform_file_helper.dart';
import 'package:mycharacterlist/core/storage/app_disk_cache.dart';
import 'package:mycharacterlist/core/presentation/feedback/app_snack_bar.dart';
import 'package:mycharacterlist/core/theme/app_colors.dart';
import 'package:mycharacterlist/core/theme/screen_app_bar_styles.dart';
import 'package:mycharacterlist/features/compare/presentation/controllers/compare_controller.dart';
import 'package:mycharacterlist/features/library/library_providers.dart';
import 'package:mycharacterlist/features/patches/patch_providers.dart';
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
    if (!mounted) {
      return;
    }

    final keyboardInset = View.of(context).viewInsets.bottom;
    if (keyboardInset > 0) {
      return;
    }

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

  Future<void> _openPage(String route, {bool resetSearch = true}) async {
    _unfocusSearch();
    if (resetSearch) {
      searchController.clear();
      filters = const CharacterFilters();
      _scheduleSearchReset();
    }
    await context.push(route);
    if (!mounted) {
      return;
    }
    await refreshLibraryAfterCharacterMutation(ref);
  }

  Future<void> _showCompareOptions() async {
    _unfocusSearch();
    await ref.read(compareControllerProvider).showCompareOptionsSheet(context);
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

    try {
      final importResult = await ref
          .read(charactersViewModelProvider.notifier)
          .importFile(path);
      ref.invalidate(characterNameSuggestionsProvider);
      ref.invalidate(libraryCharactersProvider);
      ref.invalidate(rankingCharactersViewModelProvider);
      ref.invalidate(rankingListPatchesProvider);
      ref.invalidate(rankingListPatchByIdProvider);
      ref.invalidate(patchEntriesProvider);
      await ref.read(listsViewModelProvider.notifier).loadLists();
      await ref.read(characterReferencesViewModelProvider.notifier).load();

      if (mounted && importResult != null) {
        AppSnackBar.showCentered(context, importResult.message);
      }
    } finally {
      await AppDiskCache.deleteFileIfTemporary(path);
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

    final exportResult = await PlatformFileHelper.withExportDirectoryAccess(
      directoryPath,
      (path) => ref
          .read(charactersViewModelProvider.notifier)
          .exportToDirectory(path),
    );

    if (mounted && exportResult != null) {
      AppSnackBar.showCentered(context, exportResult.message);
    }
  }

  Future<void> _showTransferActions() async {
    _unfocusSearch();
    final action = await showModalBottomSheet<_LibraryTransferAction>(
      context: context,
      useSafeArea: false,
      builder: (sheetContext) => BottomSheetPadding(
        bottomMargin: 8,
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
      useSafeArea: false,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (context, scrollController) => DecoratedBox(
          decoration: const BoxDecoration(
            color: AppColors.searchField,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: LibraryFilterSheet(
            scrollController: scrollController,
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
        ),
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
    final hasSearchOrFilter =
        searchController.text.trim().isNotEmpty || filters.hasActiveFilters;
    final emptyMessage =
        hasSearchOrFilter ? 'No results found' : 'Library is empty';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          _leaveLibrary();
        }
      },
      child: ScreenScaffold(
      resizeToAvoidBottomInset: false,
      backgroundAssetPath: AppBackgroundAssets.library,
      appBar: CustomAppBar(
        title: 'Library',
        backgroundColor: AppScreenAppBars.library.backgroundColor,
        backButtonColor: AppScreenAppBars.library.backButtonColor,
        titleColor: AppScreenAppBars.library.titleColor,
        onBackPressed: _leaveLibrary,
        actionWidget: IconButton(
          icon: const Icon(Icons.compare_arrows, color: Colors.white),
          tooltip: 'Compare',
          onPressed: _showCompareOptions,
        ),
      ),
      bodyWrapper: (body) => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _unfocusSearch,
        child: body,
      ),
      overlays: [
        if (!state.isLoading && state.characters.isEmpty)
          Positioned(
            left: 0,
            right: 0,
            top: _librarySearchSectionHeight,
            bottom: BottomActionSlot.contentBottomPadding(
              context,
              bottomMargin: 20,
            ),
            child: IgnorePointer(
              child: Center(
                child: Text(
                  emptyMessage,
                  style: emptyStateTextStyle,
                  textAlign: TextAlign.center,
                ),
              ),
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
        if (state.isImporting || state.isExporting)
          AppLoadingOverlay(
            title: state.importProgress?.title ??
                (state.isExporting
                    ? 'Exporting characters...'
                    : 'Importing characters...'),
            completed: state.importProgress?.completed,
            total: state.importProgress?.total,
          ),
      ],
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SearchBarWidget(
              controller: searchController,
              onChanged: _search,
              onClearPressed: _clearSearch,
              onFilterPressed: showFilterSheet,
            ),
            Expanded(
              child: ClipRect(
                child: state.isLoading && state.characters.isEmpty
                    ? const AppLoadingIndicator()
                    : state.characters.isEmpty
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: EdgeInsets.only(
                          bottom: BottomActionSlot.contentBottomPadding(
                            context,
                            bottomMargin: 20,
                          ),
                        ),
                        child: Scrollbar(
                        thumbVisibility: true,
                        controller: charactersScrollController,
                        child: ListView.builder(
                          controller: charactersScrollController,
                          padding: const EdgeInsets.only(top: 5),
                          itemCount: state.characters.length +
                              (state.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == state.characters.length) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: AppLoadingIndicator(),
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
                                resetSearch: false,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
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

const _librarySearchSectionHeight = 90.0;
