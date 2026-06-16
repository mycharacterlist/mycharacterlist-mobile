import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character_fact.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character_gender.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_repository.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_reference_repository.dart';

enum CreateCharacterField { name, anime, archetype }

class CreateCharacterState {
  const CreateCharacterState({
    this.isLoading = false,
    this.isSaving = false,
    this.isDeleting = false,
    this.errorMessage,
    this.invalidFields = const {},
  });

  final bool isLoading;
  final bool isSaving;
  final bool isDeleting;
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
      isLoading: state.isLoading,
      isSaving: state.isSaving,
      isDeleting: state.isDeleting,
      invalidFields: {...state.invalidFields}..remove(field),
    );
  }

  Future<bool> create(CreateCharacterInput input) async {
    final now = DateTime.now();
    return _save(
      input,
      Character(
        id: 'character_${now.microsecondsSinceEpoch}',
        name: input.name,
        sourceTitle: input.sourceTitle,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<Character?> loadCharacter(String id) async {
    state = const CreateCharacterState(isLoading: true);

    try {
      final character = await _repository.getCharacterById(id);
      if (character == null) {
        state = const CreateCharacterState(
          errorMessage: 'Character not found.',
        );
      } else {
        state = const CreateCharacterState();
      }
      return character;
    } catch (_) {
      state = const CreateCharacterState(
        errorMessage: 'Could not load character.',
      );
      return null;
    }
  }

  Future<bool> update(Character existingCharacter, CreateCharacterInput input) {
    return _save(input, existingCharacter);
  }

  Future<bool> delete(String id) async {
    state = const CreateCharacterState(isDeleting: true);

    try {
      await _repository.deleteCharacter(id);
      await _referenceRepository.deleteUnusedAnimeTitles();
      return true;
    } catch (_) {
      state = const CreateCharacterState(
        errorMessage: 'Could not delete character.',
      );
      return false;
    }
  }

  Future<int> countOtherCharactersWithSourceTitle(
    String sourceTitle,
    String excludeCharacterId,
  ) {
    return _repository.countCharactersWithSourceTitle(
      sourceTitle,
      excludeCharacterId: excludeCharacterId,
    );
  }

  Future<int> countCharactersWithSourceTitle(String sourceTitle) {
    return _repository.countCharactersWithSourceTitle(sourceTitle);
  }

  Future<String?> findAnimeTitle(String name) {
    return _referenceRepository.findAnimeTitle(name);
  }

  Future<bool> renameAnimeTitleForAllCharacters({
    required String oldSourceTitle,
    required String newSourceTitle,
  }) async {
    try {
      final canonicalNew = await _referenceRepository.ensureAnimeTitle(
        newSourceTitle,
      );
      await _repository.renameSourceTitleForAll(
        oldSourceTitle,
        canonicalNew,
      );
      await _referenceRepository.deleteUnusedAnimeTitles();
      state = const CreateCharacterState();
      return true;
    } catch (_) {
      state = const CreateCharacterState(
        errorMessage: 'Could not update anime for all characters.',
      );
      return false;
    }
  }

  Future<bool> _save(
    CreateCharacterInput input,
    Character existingCharacter,
  ) async {
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
      final normalizedName = name.toLowerCase();
      final normalizedSourceTitle = sourceTitle.toLowerCase();
      final characters = await _repository.getCharacters();
      final duplicateExists = characters.any(
        (character) =>
            character.id != existingCharacter.id &&
            character.name.trim().toLowerCase() == normalizedName &&
            character.sourceTitle.trim().toLowerCase() == normalizedSourceTitle,
      );
      if (duplicateExists) {
        state = const CreateCharacterState(
          errorMessage: 'This character already exists for the selected anime.',
          invalidFields: {CreateCharacterField.name},
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
      for (final definition in gradeDefinitions) {
        final value = input.grades[definition.id];
        if (value != null && (value < 0 || value > definition.maxValue)) {
          state = CreateCharacterState(
            errorMessage:
                '${definition.name} must be between 0 and '
                '${definition.maxValue}.',
          );
          return false;
        }
      }

      final grades = <String, int>{};
      for (final definition in gradeDefinitions) {
        final value = input.grades[definition.id];
        if (value != null) {
          grades[definition.id] = value;
        }
      }

      state = const CreateCharacterState(isSaving: true);

      final canonicalSourceTitle = await _referenceRepository.ensureAnimeTitle(
        sourceTitle,
      );
      final now = DateTime.now();
      final character = Character(
        id: existingCharacter.id,
        name: name,
        sourceTitle: canonicalSourceTitle,
        description: existingCharacter.description,
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
        createdAt: existingCharacter.createdAt,
        updatedAt: now,
      );

      await _repository.saveCharacter(character);
      await _referenceRepository.deleteUnusedAnimeTitles();
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
