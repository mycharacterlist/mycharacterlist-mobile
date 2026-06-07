import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mycharacterlist/app/widgets/app_appbar.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character_gender.dart';
import 'package:mycharacterlist/features/characters/domain/entities/grade_definition.dart';
import 'package:mycharacterlist/features/library/library_providers.dart';
import 'package:mycharacterlist/features/library/presentation/viewmodels/create_character_view_model.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/character_create_widgets/gallery_dropdown.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/character_create_widgets/lower_buttons.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/character_create_widgets/main_information_dropdown.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/character_create_widgets/main_photo_picker.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/character_create_widgets/personal_grades_dropdown.dart';
import 'package:mycharacterlist/features/library/presentation/widgets/character_create_widgets/personal_notes_dropdown.dart';

class CharacterCreatePage extends ConsumerStatefulWidget {
  const CharacterCreatePage({super.key});

  @override
  ConsumerState<CharacterCreatePage> createState() =>
      _CharacterCreatePageState();
}

class _CharacterCreatePageState extends ConsumerState<CharacterCreatePage> {
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final heightController = TextEditingController();
  final japaneseNameController = TextEditingController();
  final animeController = TextEditingController();
  final archetypeController = TextEditingController();
  final notesController = TextEditingController();
  final gradeControllers = <String, TextEditingController>{};

  String selectedGender = CharacterGender.unknown;
  String? mainImagePath;
  List<String?> galleryImagePaths = List.filled(6, null);
  int formVersion = 0;

  @override
  void initState() {
    super.initState();
    nameController.addListener(_clearNameError);
    animeController.addListener(_clearAnimeError);
    archetypeController.addListener(_clearArchetypeError);
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

  List<TextEditingController> get _controllers => [
    nameController,
    ageController,
    heightController,
    japaneseNameController,
    animeController,
    archetypeController,
    notesController,
    ...gradeControllers.values,
  ];

  Map<String, int> _grades(List<GradeDefinition> definitions) {
    return {
      for (final definition in definitions)
        definition.id:
            int.tryParse(gradeControllers[definition.id]?.text ?? '') ?? 0,
    };
  }

  void _syncGradeControllers(List<GradeDefinition> definitions) {
    for (final definition in definitions) {
      gradeControllers.putIfAbsent(
        definition.id,
        () => TextEditingController(),
      );
    }
  }

  SnackBar _centeredSnackBar(String message) {
    return SnackBar(
      content: Text(message, textAlign: TextAlign.center),
    );
  }

  Future<void> _createCharacter(List<GradeDefinition> definitions) async {
    final created = await ref
        .read(createCharacterViewModelProvider.notifier)
        .create(
          CreateCharacterInput(
            name: nameController.text,
            sourceTitle: animeController.text,
            age: ageController.text,
            height: heightController.text,
            japaneseName: japaneseNameController.text,
            archetype: archetypeController.text,
            gender: selectedGender,
            personalNotes: notesController.text,
            grades: _grades(definitions),
            mainImagePath: mainImagePath,
            galleryImagePaths: galleryImagePaths.whereType<String>().toList(),
          ),
        );

    if (!mounted || !created) {
      return;
    }

    await ref.read(charactersViewModelProvider.notifier).loadCharacters();

    if (mounted) {
      context.pop();
    }
  }

  Future<void> _addAnimeTitle() async {
    final added = await ref
        .read(characterReferencesViewModelProvider.notifier)
        .addAnimeTitle(animeController.text);

    if (mounted && added) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(_centeredSnackBar('Anime title added.'));
    }
  }

  void _clearAll() {
    for (final controller in _controllers) {
      controller.clear();
    }

    setState(() {
      selectedGender = CharacterGender.unknown;
      mainImagePath = null;
      galleryImagePaths = List.filled(6, null);
      formVersion++;
    });
  }

  @override
  void dispose() {
    nameController.removeListener(_clearNameError);
    animeController.removeListener(_clearAnimeError);
    archetypeController.removeListener(_clearArchetypeError);

    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final createState = ref.watch(createCharacterViewModelProvider);
    final referencesState = ref.watch(characterReferencesViewModelProvider);
    _syncGradeControllers(referencesState.gradeDefinitions);

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

    return Scaffold(
      appBar: CustomAppBar(
        title: 'New Character',
        backgroundColor: const Color(0xFF1A4043),
        backButtonColor: const Color(0xFF009768),
        titleColor: const Color(0xFF4CB897),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/Library_bg.jpg',
              fit: BoxFit.cover,
            ),
          ),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 17),
                            const Center(
                              child: Text(
                                'New character',
                                style: TextStyle(
                                  fontSize: 45,
                                  color: Colors.black,
                                  fontFamily: 'GreatVibes',
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: MainPhotoPicker(
                                imagePath: mainImagePath,
                                onChanged: (path) =>
                                    setState(() => mainImagePath = path),
                              ),
                            ),
                            const SizedBox(height: 25),
                            MainInformationDropdown(
                              key: ValueKey(formVersion),
                              nameController: nameController,
                              ageController: ageController,
                              heightController: heightController,
                              japaneseNameController: japaneseNameController,
                              animeController: animeController,
                              archetypeController: archetypeController,
                              animeTitles: referencesState.animeTitles,
                              archetypes: referencesState.archetypes,
                              onAddAnime: _addAnimeTitle,
                              selectedGender: selectedGender,
                              onGenderChanged: (value) =>
                                  setState(() => selectedGender = value),
                              nameHasError: createState.invalidFields.contains(
                                CreateCharacterField.name,
                              ),
                              animeHasError: createState.invalidFields.contains(
                                CreateCharacterField.anime,
                              ),
                              archetypeHasError: createState.invalidFields
                                  .contains(CreateCharacterField.archetype),
                            ),
                            const SizedBox(height: 15),
                            PersonalGradesDropdown(
                              definitions: referencesState.gradeDefinitions,
                              controllers: gradeControllers,
                            ),
                            const SizedBox(height: 15),
                            GalleryDropdown(
                              imagePaths: galleryImagePaths,
                              onChanged: (paths) =>
                                  setState(() => galleryImagePaths = paths),
                            ),
                            const SizedBox(height: 15),
                            PersonalNotesDropdown(controller: notesController),
                            const SizedBox(height: 15),
                            LowerButtons(
                              onClear: _clearAll,
                              onCreate: () => _createCharacter(
                                referencesState.gradeDefinitions,
                              ),
                              isSaving: createState.isSaving,
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
        ],
      ),
    );
  }
}
