import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mycharacterlist/core/errors/app_messages.dart';
import 'package:mycharacterlist/core/errors/error_mapper.dart';

import 'package:mycharacterlist/features/characters/domain/repositories/character_reference_repository.dart';
import 'package:mycharacterlist/features/characters/domain/entities/grade_definition.dart';

class CharacterReferencesState {
  const CharacterReferencesState({
    this.animeTitles = const [],
    this.archetypes = const [],
    this.gradeDefinitions = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<String> animeTitles;
  final List<String> archetypes;
  final List<GradeDefinition> gradeDefinitions;
  final bool isLoading;
  final String? errorMessage;
}

class CharacterReferencesViewModel
    extends StateNotifier<CharacterReferencesState> {
  CharacterReferencesViewModel({
    required CharacterReferenceRepository repository,
  }) : _repository = repository,
       super(const CharacterReferencesState(isLoading: true)) {
    load();
  }

  final CharacterReferenceRepository _repository;

  Future<void> load() async {
    try {
      final animeTitles = await _repository.getAnimeTitles();
      final archetypes = await _repository.getArchetypes();
      final gradeDefinitions = await _repository.getGradeDefinitions();
      state = CharacterReferencesState(
        animeTitles: animeTitles,
        archetypes: archetypes,
        gradeDefinitions: gradeDefinitions,
      );
    } catch (_) {
      state = const CharacterReferencesState(
        errorMessage: AppMessages.couldNotLoadReferences,
      );
    }
  }

  Future<bool> addGradeDefinition({
    required String name,
    required int maxValue,
  }) async {
    try {
      await _repository.addGradeDefinition(name: name, maxValue: maxValue);
      await load();
      return true;
    } on StateError catch (error) {
      state = CharacterReferencesState(
        animeTitles: state.animeTitles,
        archetypes: state.archetypes,
        gradeDefinitions: state.gradeDefinitions,
        errorMessage: ErrorMapper.userMessage(error),
      );
      return false;
    } catch (_) {
      state = CharacterReferencesState(
        animeTitles: state.animeTitles,
        archetypes: state.archetypes,
        gradeDefinitions: state.gradeDefinitions,
        errorMessage: AppMessages.couldNotSaveGradeDefinition,
      );
      return false;
    }
  }
}
