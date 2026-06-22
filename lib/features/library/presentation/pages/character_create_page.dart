import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/bootstrap/app_image_cache.dart';
import 'package:mycharacterlist/app/assets/app_background_assets.dart';
import 'package:mycharacterlist/app/widgets/layout/app_appbar.dart';
import 'package:mycharacterlist/app/widgets/feedback/app_loading_indicator.dart';
import 'package:mycharacterlist/app/widgets/feedback/app_loading_overlay.dart';
import 'package:mycharacterlist/app/widgets/layout/framed_content_panel.dart';
import 'package:mycharacterlist/app/widgets/layout/screen_scaffold.dart';
import 'package:mycharacterlist/core/presentation/listeners/view_model_error_listener.dart';
import 'package:mycharacterlist/core/presentation/feedback/app_snack_bar.dart';
import 'package:mycharacterlist/core/storage/app_disk_cache.dart';
import 'package:mycharacterlist/core/theme/screen_app_bar_styles.dart';
import 'package:mycharacterlist/core/storage/storage_providers.dart';
import 'package:mycharacterlist/features/characters/domain/entities/grade_definition.dart';
import 'package:mycharacterlist/features/library/library_providers.dart';
import 'package:mycharacterlist/features/library/presentation/controllers/character_form_controller.dart';
import 'package:mycharacterlist/features/library/presentation/viewmodels/character_references_view_model.dart';
import 'package:mycharacterlist/features/library/presentation/viewmodels/create_character_view_model.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/character_create_widgets/gallery_dropdown.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/character_create_widgets/lower_buttons.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/character_create_widgets/main_information_dropdown.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/character_create_widgets/main_photo_picker.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/character_create_widgets/personal_grades_dropdown.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/character_create_widgets/personal_notes_dropdown.dart';

enum _AnimeRenameChoice { skip, cancel, onlyHere, all }

class CharacterCreatePage extends ConsumerStatefulWidget {
  const CharacterCreatePage({super.key, this.characterId});

  final String? characterId;

  @override
  ConsumerState<CharacterCreatePage> createState() =>
      _CharacterCreatePageState();
}

class _CharacterCreatePageState extends ConsumerState<CharacterCreatePage> {
  final form = CharacterFormController();
  final formScrollController = ScrollController();
  int formVersion = 0;
  bool allowPop = false;
  bool isProcessing = false;
  bool isGalleryCompressing = false;
  int galleryCompressCompleted = 0;
  int galleryCompressTotal = 0;
  String? _animeRenameSource;

  bool get isEditing => widget.characterId != null;

  @override
  void initState() {
    super.initState();
    form.name.addListener(_clearNameError);
    form.anime.addListener(_clearAnimeError);
    form.archetype.addListener(_clearArchetypeError);

    if (isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadCharacter());
    }
  }

  Future<void> _loadCharacter() async {
    final character = await ref
        .read(createCharacterViewModelProvider.notifier)
        .loadCharacter(widget.characterId!);

    if (!mounted || character == null) {
      return;
    }

    setState(() {
      form.populate(character);
      _animeRenameSource = character.sourceTitle.trim();
      formVersion++;
    });
  }

  void _clearNameError() {
    ref
        .read(createCharacterViewModelProvider.notifier)
        .clearFieldError(CreateCharacterField.name);
  }

  void _clearAnimeError() {
    ref
        .read(createCharacterViewModelProvider.notifier)
        .clearFieldError(CreateCharacterField.anime);
  }

  void _rememberExistingAnimeTitle(String title) {
    _animeRenameSource = title;
  }

  void _clearArchetypeError() {
    ref
        .read(createCharacterViewModelProvider.notifier)
        .clearFieldError(CreateCharacterField.archetype);
  }

  void _onGalleryCompressionState(
    bool isCompressing, {
    int completed = 0,
    int total = 0,
  }) {
    setState(() {
      isGalleryCompressing = isCompressing;
      galleryCompressCompleted = completed;
      galleryCompressTotal = total;
    });
  }

  Future<void> _requestExit() async {
    final definitions = ref.read(
      characterReferencesViewModelProvider.select(
        (state) => state.gradeDefinitions,
      ),
    );
    if (!form.hasUnsavedChanges(definitions)) {
      await _popWithoutWarning();
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your unsaved changes will be lost.'),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => dialogContext.pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _discardFormDrafts();
      await _popWithoutWarning();
    }
  }

  Future<void> _discardFormDrafts() async {
    final fileStorage = ref.read(localFileStorageProvider);
    await fileStorage.deleteDraftFile(form.mainImagePath);
    await fileStorage.deleteDraftFiles(form.galleryImagePaths);
  }

  Future<void> _popWithoutWarning() async {
    setState(() => allowPop = true);
    await Future<void>.delayed(Duration.zero);
    if (mounted) {
      context.pop();
    }
  }

  Future<void> _runWithProcessing(
    Future<bool> Function() action, {
    bool includeRanking = false,
  }) async {
    if (isProcessing) {
      return;
    }

    setState(() => isProcessing = true);

    final succeeded = await action();

    if (!mounted) {
      return;
    }

    if (!succeeded) {
      setState(() => isProcessing = false);
      return;
    }

    await _refreshLibraryAfterMutation(includeRanking: includeRanking);
    await _popWithoutWarning();
  }

  Future<_AnimeRenameChoice> _resolveAnimeRenameChoice(String newAnime) async {
    final viewModel = ref.read(createCharacterViewModelProvider.notifier);
    final oldAnime = isEditing
        ? form.character?.sourceTitle.trim()
        : _animeRenameSource;

    if (oldAnime == null || oldAnime.isEmpty) {
      return _AnimeRenameChoice.skip;
    }

    if (oldAnime.toLowerCase() == newAnime.toLowerCase()) {
      return _AnimeRenameChoice.skip;
    }

    final existingNewAnime = await viewModel.findAnimeTitle(newAnime);
    if (existingNewAnime != null) {
      return _AnimeRenameChoice.skip;
    }

    final othersCount = isEditing
        ? await viewModel.countOtherCharactersWithSourceTitle(
            oldAnime,
            form.character!.id,
          )
        : await viewModel.countCharactersWithSourceTitle(oldAnime);

    if (othersCount <= 0) {
      return _AnimeRenameChoice.skip;
    }

    final applyToAll = await _showAnimeRenameDialog(
      oldAnime: oldAnime,
      otherCharactersCount: othersCount,
    );

    if (!mounted) {
      return _AnimeRenameChoice.cancel;
    }

    if (applyToAll == null) {
      return _AnimeRenameChoice.cancel;
    }

    return applyToAll ? _AnimeRenameChoice.all : _AnimeRenameChoice.onlyHere;
  }

  Future<void> _createCharacter(List<GradeDefinition> definitions) async {
    if (isProcessing) {
      return;
    }

    final newAnime = form.anime.text.trim();
    final oldAnime = _animeRenameSource;
    final renameChoice = await _resolveAnimeRenameChoice(newAnime);

    if (!mounted || renameChoice == _AnimeRenameChoice.cancel) {
      return;
    }

    final viewModel = ref.read(createCharacterViewModelProvider.notifier);

    setState(() => isProcessing = true);

    final succeeded = await viewModel.create(form.toInput(definitions));

    if (!mounted) {
      return;
    }

    if (!succeeded) {
      setState(() => isProcessing = false);
      return;
    }

    if (renameChoice == _AnimeRenameChoice.all && oldAnime != null) {
      final renamed = await viewModel.renameAnimeTitleForAllCharacters(
        oldSourceTitle: oldAnime,
        newSourceTitle: newAnime,
      );

      if (!mounted) {
        return;
      }

      if (!renamed) {
        AppSnackBar.showCentered(
          context,
          'Could not update anime for all characters.',
        );
      }
    }

    await _refreshLibraryAfterMutation(
      characterId: isEditing ? form.character?.id : null,
    );
    await _popWithoutWarning();
  }

  Future<void> _saveCharacter(List<GradeDefinition> definitions) async {
    final character = form.character;
    if (character == null || isProcessing) {
      return;
    }

    final newAnime = form.anime.text.trim();
    final oldAnime = character.sourceTitle.trim();
    final renameChoice = await _resolveAnimeRenameChoice(newAnime);

    if (!mounted || renameChoice == _AnimeRenameChoice.cancel) {
      return;
    }

    final viewModel = ref.read(createCharacterViewModelProvider.notifier);

    setState(() => isProcessing = true);

    final succeeded = await viewModel.update(character, form.toInput(definitions));

    if (!mounted) {
      return;
    }

    if (!succeeded) {
      setState(() => isProcessing = false);
      return;
    }

    if (renameChoice == _AnimeRenameChoice.all) {
      final renamed = await viewModel.renameAnimeTitleForAllCharacters(
        oldSourceTitle: oldAnime,
        newSourceTitle: newAnime,
      );

      if (!mounted) {
        return;
      }

      if (!renamed) {
        AppSnackBar.showCentered(
          context,
          'Could not update anime for all characters.',
        );
      }
    }

    await _refreshLibraryAfterMutation(characterId: character.id);
    await _popWithoutWarning();
  }

  Future<bool?> _showAnimeRenameDialog({
    required String oldAnime,
    required int otherCharactersCount,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update anime?'),
        content: Text('$otherCharactersCount more use "$oldAnime".'),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => dialogContext.pop(false),
            child: const Text('Only here'),
          ),
          TextButton(
            onPressed: () => dialogContext.pop(true),
            child: const Text('All'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCharacter() async {
    final character = form.character;
    if (character == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete character?'),
        content: const Text(
          'The character, all saved images, and all list positions will be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) {
      return;
    }

    await _runWithProcessing(
      () => ref
          .read(createCharacterViewModelProvider.notifier)
          .delete(character.id),
      includeRanking: true,
    );
  }

  Future<void> _refreshLibraryAfterMutation({
    String? characterId,
    bool includeRanking = true,
  }) {
    return refreshLibraryAfterCharacterMutation(
      ref,
      characterId: characterId,
      includeRanking: includeRanking,
    );
  }

  Future<void> _clearAll() async {
    await _discardFormDrafts();
    if (!mounted) {
      return;
    }

    setState(() {
      form.clear();
      _animeRenameSource = null;
      formVersion++;
    });
  }

  @override
  void dispose() {
    AppImageCache.trimAfterHeavyScreen();
    AppDiskCache.cleanUnused(includeDrafts: true);
    form.name.removeListener(_clearNameError);
    form.anime.removeListener(_clearAnimeError);
    form.archetype.removeListener(_clearArchetypeError);
    form.dispose();
    formScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      createCharacterViewModelProvider.select((state) => state.isLoading),
    );
    final invalidFields = ref.watch(
      createCharacterViewModelProvider.select((state) => state.invalidFields),
    );
    final referencesState = ref.watch(characterReferencesViewModelProvider);
    final fileStorage = ref.read(localFileStorageProvider);
    final characterNames =
        ref.watch(characterNameSuggestionsProvider).value ?? const <String>[];
    form.syncGradeControllers(referencesState.gradeDefinitions);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    listenViewModelError(
      ref,
      provider: createCharacterViewModelProvider,
      selectError: (state) => (state as CreateCharacterState).errorMessage,
      context: context,
      centered: true,
    );

    listenViewModelError(
      ref,
      provider: characterReferencesViewModelProvider,
      selectError: (state) => (state as CharacterReferencesState).errorMessage,
      context: context,
      centered: true,
    );

    return PopScope(
      canPop: allowPop && !isProcessing && !isGalleryCompressing,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !isProcessing && !isGalleryCompressing) {
          _requestExit();
        }
      },
      child: ScreenScaffold(
        resizeToAvoidBottomInset: false,
        backgroundAssetPath: AppBackgroundAssets.library,
        appBar: CustomAppBar(
          title: isEditing ? 'Edit Character' : 'New Character',
          backgroundColor: AppScreenAppBars.library.backgroundColor,
          backButtonColor: AppScreenAppBars.library.backButtonColor,
          titleColor: AppScreenAppBars.library.titleColor,
          onBackPressed: isProcessing || isGalleryCompressing
              ? () {}
              : _requestExit,
        ),
        overlays: [
          if (isProcessing) const AppLoadingOverlay(dimmed: false),
          if (isGalleryCompressing)
            AppLoadingOverlay(
              title: 'Preparing photos...',
              completed: galleryCompressCompleted,
              total: galleryCompressTotal,
            ),
        ],
        child: isLoading
            ? const AppLoadingIndicator()
            : FramedContentPanel(
                widthFactor: 0.90,
                frameAssetPath: AppBackgroundAssets.characterForm,
                contentPadding: const EdgeInsets.only(
                  top: 55,
                  left: 20,
                  right: 20,
                  bottom: 25,
                ),
                child: ClipRect(
                  child: SingleChildScrollView(
                    controller: formScrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                                const SizedBox(height: 17),
                                Center(
                                  child: Text(
                                    isEditing
                                        ? 'Edit character'
                                        : 'New character',
                                    style: const TextStyle(
                                      fontSize: 45,
                                      color: Colors.black,
                                      fontFamily: 'GreatVibes',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: MainPhotoPicker(
                                    imagePath: form.mainImagePath,
                                    fileStorage: fileStorage,
                                    onChanged: (path) => setState(
                                      () => form.mainImagePath = path,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 25),
                                MainInformationDropdown(
                                  key: ValueKey(formVersion),
                                  nameController: form.name,
                                  ageController: form.age,
                                  heightController: form.height,
                                  japaneseNameController: form.japaneseName,
                                  animeController: form.anime,
                                  archetypeController: form.archetype,
                                  characterNames: characterNames,
                                  animeTitles: referencesState.animeTitles,
                                  archetypes: referencesState.archetypes,
                                  selectedGender: form.gender,
                                  onGenderChanged: (value) =>
                                      setState(() => form.gender = value),
                                  nameHasError: invalidFields
                                      .contains(CreateCharacterField.name),
                                  animeHasError: invalidFields
                                      .contains(CreateCharacterField.anime),
                                  archetypeHasError: invalidFields
                                      .contains(CreateCharacterField.archetype),
                                  onExistingAnimeSelected:
                                      _rememberExistingAnimeTitle,
                                ),
                                const SizedBox(height: 15),
                                PersonalGradesDropdown(
                                  definitions: referencesState.gradeDefinitions,
                                  controllers: form.grades,
                                ),
                                const SizedBox(height: 15),
                                GalleryDropdown(
                                  imagePaths: form.galleryImagePaths,
                                  fileStorage: fileStorage,
                                  onCompressionStateChanged:
                                      _onGalleryCompressionState,
                                  onChanged: (paths) => setState(
                                    () => form.galleryImagePaths = paths,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                PersonalNotesDropdown(controller: form.notes),
                                const SizedBox(height: 15),
                                LowerButtons(
                                  onClear: isEditing
                                      ? _deleteCharacter
                                      : _clearAll,
                                  onCreate: isEditing
                                      ? () => _saveCharacter(
                                          referencesState.gradeDefinitions,
                                        )
                                      : () => _createCharacter(
                                          referencesState.gradeDefinitions,
                                        ),
                                  clearLabel: isEditing
                                      ? 'Delete character'
                                      : 'Clear all',
                                  createLabel: isEditing ? 'Save' : 'Create',
                                ),
                                SizedBox(height: 20 + bottomInset),
                              ],
                            ),
                  ),
                ),
              ),
      ),
    );
  }
}
