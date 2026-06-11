import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/widgets/app_appbar.dart';
import 'package:mycharacterlist/features/characters/domain/entities/grade_definition.dart';
import 'package:mycharacterlist/features/library/library_providers.dart';
import 'package:mycharacterlist/features/ranking_lists/ranking_list_providers.dart';
import 'package:mycharacterlist/features/library/presentation/controllers/character_form_controller.dart';
import 'package:mycharacterlist/features/library/presentation/viewmodels/create_character_view_model.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/character_create_widgets/gallery_dropdown.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/character_create_widgets/lower_buttons.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/character_create_widgets/main_information_dropdown.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/character_create_widgets/main_photo_picker.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/character_create_widgets/personal_grades_dropdown.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/character_create_widgets/personal_notes_dropdown.dart';

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

  void _clearArchetypeError() {
    ref
        .read(createCharacterViewModelProvider.notifier)
        .clearFieldError(CreateCharacterField.archetype);
  }

  SnackBar _centeredSnackBar(String message) {
    return SnackBar(content: Text(message, textAlign: TextAlign.center));
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
      await _popWithoutWarning();
    }
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

    await _popWithoutWarning();
    _refreshLibraryAfterMutation(includeRanking: includeRanking);
  }

  Future<void> _createCharacter(List<GradeDefinition> definitions) async {
    await _runWithProcessing(
      () => ref
          .read(createCharacterViewModelProvider.notifier)
          .create(form.toInput(definitions)),
    );
  }

  Future<void> _saveCharacter(List<GradeDefinition> definitions) async {
    final character = form.character;
    if (character == null) {
      return;
    }

    await _runWithProcessing(
      () => ref
          .read(createCharacterViewModelProvider.notifier)
          .update(character, form.toInput(definitions)),
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

  void _refreshLibraryAfterMutation({bool includeRanking = false}) {
    ref.invalidate(libraryCharactersProvider);
    ref.invalidate(characterNameSuggestionsProvider);

    if (includeRanking) {
      ref.invalidate(rankingCharactersViewModelProvider);
      ref.invalidate(rankedListCharacterDetailsProvider);
    }

    Future.microtask(() {
      ref.read(charactersViewModelProvider.notifier).loadCharacters();
      ref.read(characterReferencesViewModelProvider.notifier).load();
    });
  }

  void _clearAll() {
    setState(() {
      form.clear();
      formVersion++;
    });
  }

  @override
  void dispose() {
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
    final characterNames =
        ref.watch(characterNameSuggestionsProvider).value ?? const <String>[];
    form.syncGradeControllers(referencesState.gradeDefinitions);

    ref.listen(createCharacterViewModelProvider, (previous, next) {
      if (next.errorMessage == null ||
          next.errorMessage == previous?.errorMessage) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(_centeredSnackBar(next.errorMessage!));
    });

    ref.listen(characterReferencesViewModelProvider, (previous, next) {
      if (next.errorMessage == null ||
          next.errorMessage == previous?.errorMessage) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(_centeredSnackBar(next.errorMessage!));
    });

    return PopScope(
      canPop: allowPop && !isProcessing,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && !isProcessing) {
          _requestExit();
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
          title: isEditing ? 'Edit Character' : 'New Character',
          backgroundColor: const Color(0xFF1A4043),
          backButtonColor: const Color(0xFF009768),
          titleColor: const Color(0xFF4CB897),
          onBackPressed: isProcessing ? () {} : _requestExit,
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/Library_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.90,
                  height: MediaQuery.of(context).size.height * 0.87,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Image.asset(
                          'assets/images/PagePictureFixed.png',
                          fit: BoxFit.fill,
                        ),
                      ),
                      Positioned(
                        top: 55,
                        left: 20,
                        right: 20,
                        bottom: 25,
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
                                ),
                                const SizedBox(height: 15),
                                PersonalGradesDropdown(
                                  definitions: referencesState.gradeDefinitions,
                                  controllers: form.grades,
                                ),
                                const SizedBox(height: 15),
                                GalleryDropdown(
                                  imagePaths: form.galleryImagePaths,
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
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (isProcessing)
              const Positioned.fill(
                child: AbsorbPointer(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
