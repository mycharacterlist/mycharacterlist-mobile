import 'package:flutter/material.dart';

import 'package:mycharacterlist/core/text/text_editing_utils.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character_gender.dart';
import 'package:mycharacterlist/features/characters/domain/entities/grade_definition.dart';
import 'package:mycharacterlist/features/library/presentation/viewmodels/create_character_view_model.dart';

class CharacterFormController {
  final name = TextEditingController();
  final age = TextEditingController();
  final height = TextEditingController();
  final japaneseName = TextEditingController();
  final anime = TextEditingController();
  final archetype = TextEditingController();
  final notes = TextEditingController();
  final grades = <String, TextEditingController>{};

  Character? character;
  String gender = CharacterGender.unknown;
  String? mainImagePath;
  List<String> galleryImagePaths = [];

  List<TextEditingController> get textControllers => [
    name,
    age,
    height,
    japaneseName,
    anime,
    archetype,
    notes,
    ...grades.values,
  ];

  void syncGradeControllers(List<GradeDefinition> definitions) {
    for (final definition in definitions) {
      grades.putIfAbsent(definition.id, TextEditingController.new);
    }
  }

  void populate(Character value) {
    character = value;
    setCollapsedControllerText(name, value.name);
    setCollapsedControllerText(age, value.age);
    setCollapsedControllerText(height, value.height);
    setCollapsedControllerText(japaneseName, value.japaneseName);
    setCollapsedControllerText(anime, value.sourceTitle);
    setCollapsedControllerText(archetype, value.archetype);
    setCollapsedControllerText(notes, value.personalNotes);
    gender = value.gender;
    mainImagePath = value.mainImagePath;
    galleryImagePaths = [...value.galleryImagePaths];

    for (final entry in value.grades.entries) {
      setCollapsedControllerText(
        grades.putIfAbsent(entry.key, TextEditingController.new),
        entry.value.toString(),
      );
    }
  }

  CreateCharacterInput toInput(List<GradeDefinition> definitions) {
    final gradeValues = <String, int>{};
    for (final definition in definitions) {
      final value = int.tryParse(grades[definition.id]?.text ?? '');
      if (value != null) {
        gradeValues[definition.id] = value;
      }
    }

    return CreateCharacterInput(
      name: name.text,
      sourceTitle: anime.text,
      age: age.text,
      height: height.text,
      japaneseName: japaneseName.text,
      archetype: archetype.text,
      gender: gender,
      personalNotes: notes.text,
      grades: gradeValues,
      mainImagePath: mainImagePath,
      galleryImagePaths: galleryImagePaths,
      facts: character?.facts ?? const [],
    );
  }

  bool hasUnsavedChanges(List<GradeDefinition> definitions) {
    final original = character;

    if (original == null) {
      return name.text.isNotEmpty ||
          age.text.isNotEmpty ||
          height.text.isNotEmpty ||
          japaneseName.text.isNotEmpty ||
          anime.text.isNotEmpty ||
          archetype.text.isNotEmpty ||
          notes.text.isNotEmpty ||
          gender != CharacterGender.unknown ||
          mainImagePath != null ||
          galleryImagePaths.isNotEmpty ||
          definitions.any(
            (definition) => grades[definition.id]?.text.isNotEmpty ?? false,
          );
    }

    return name.text != original.name ||
        age.text != original.age ||
        height.text != original.height ||
        japaneseName.text != original.japaneseName ||
        anime.text != original.sourceTitle ||
        archetype.text != original.archetype ||
        notes.text != original.personalNotes ||
        gender != original.gender ||
        mainImagePath != original.mainImagePath ||
        !_sameList(galleryImagePaths, original.galleryImagePaths) ||
        definitions.any(
          (definition) =>
              (grades[definition.id]?.text ?? '') !=
              (original.grades[definition.id]?.toString() ?? ''),
        );
  }

  bool _sameList(List<String> left, List<String> right) {
    if (left.length != right.length) {
      return false;
    }

    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) {
        return false;
      }
    }
    return true;
  }

  void clear() {
    for (final controller in textControllers) {
      controller.clear();
    }

    gender = CharacterGender.unknown;
    mainImagePath = null;
    galleryImagePaths = [];
  }

  void dispose() {
    for (final controller in textControllers) {
      controller.dispose();
    }
  }
}
