import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character_fact.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character_gender.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_repository.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_reference_repository.dart';

enum CreateCharacterField { name, anime, archetype }

class CreateCharacterState {
  const CreateCharacterState({
    this.isSaving = false,
    this.errorMessage,
    this.invalidFields = const {},
  });

  final bool isSaving;
  final String? errorMessage;
  final Set<CreateCharacterField> invalidFields;
}

class CreateCharacterInput {
  const CreateCharacterInput({
    required this.name,
    required this.sourceTitle,
    required this.age,
    required this.height,
    required this.japaneseName,
    required this.archetype,
    required this.gender,
    required this.personalNotes,
    required this.grades,
    required this.galleryImagePaths,
    this.facts = const [],
    this.mainImagePath,
  });

  final String name;
  final String sourceTitle;
  final String age;
  final String height;
  final String japaneseName;
  final String archetype;
  final String gender;
  final String personalNotes;
  final Map<String, int> grades;
  final String? mainImagePath;
  final List<String> galleryImagePaths;
  final List<CharacterFact> facts;
}

class CreateCharacterViewModel extends StateNotifier<CreateCharacterState> {
  CreateCharacterViewModel({
    required CharacterRepository repository,
    required CharacterReferenceRepository referenceRepository,
  }) : _repository = repository,
       _referenceRepository = referenceRepository,
       super(const CreateCharacterState());

  final CharacterRepository _repository;
  final CharacterReferenceRepository _referenceRepository;

  void clearFieldError(CreateCharacterField field) {
    if (!state.invalidFields.contains(field)) {
      return;
    }

    state = CreateCharacterState(
      isSaving: state.isSaving,
      invalidFields: {...state.invalidFields}..remove(field),
    );
  }

  Future<bool> create(CreateCharacterInput input) async {
    final name = input.name.trim();
    final sourceTitle = input.sourceTitle.trim();

    if (name.isEmpty) {
      state = const CreateCharacterState(
        errorMessage: 'Character name cannot be empty.',
        invalidFields: {CreateCharacterField.name},
      );
      return false;
    }

    if (sourceTitle.isEmpty) {
      state = const CreateCharacterState(
        errorMessage: 'Anime/source title cannot be empty.',
        invalidFields: {CreateCharacterField.anime},
      );
      return false;
    }

    try {
      final animeExists = await _referenceRepository.containsAnimeTitle(
        sourceTitle,
      );
      if (!animeExists) {
        state = const CreateCharacterState(
          errorMessage: 'Select an anime from the list or add it with New+.',
          invalidFields: {CreateCharacterField.anime},
        );
        return false;
      }

      final archetype = input.archetype.trim();
      final archetypeExists =
          archetype.isEmpty ||
          await _referenceRepository.containsArchetype(archetype);
      if (!archetypeExists) {
        state = const CreateCharacterState(
          errorMessage: 'Select an archetype from the list.',
          invalidFields: {CreateCharacterField.archetype},
        );
        return false;
      }

      final gradeDefinitions = await _referenceRepository.getGradeDefinitions();
      final grades = {
        for (final definition in gradeDefinitions)
          definition.id: (input.grades[definition.id] ?? 0).clamp(
            0,
            definition.maxValue,
          ),
      };

      state = const CreateCharacterState(isSaving: true);

      final now = DateTime.now();
      final character = Character(
        id: 'character_${now.microsecondsSinceEpoch}',
        name: name,
        sourceTitle: sourceTitle,
        age: input.age.trim(),
        height: input.height.trim(),
        japaneseName: input.japaneseName.trim(),
        archetype: archetype,
        gender: CharacterGender.normalize(input.gender),
        personalNotes: input.personalNotes.trim(),
        grades: grades,
        mainImagePath: input.mainImagePath,
        galleryImagePaths: input.galleryImagePaths,
        facts: input.facts,
        createdAt: now,
        updatedAt: now,
      );

      await _repository.saveCharacter(character);
      state = const CreateCharacterState();
      return true;
    } on StateError catch (error) {
      state = CreateCharacterState(errorMessage: error.message);
      return false;
    } catch (_) {
      state = const CreateCharacterState(
        errorMessage: 'Could not save character.',
      );
      return false;
    }
  }
}
