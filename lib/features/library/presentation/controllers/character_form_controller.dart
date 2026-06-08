import 'package:flutter/material.dart';

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
    name.text = value.name;
    age.text = value.age;
    height.text = value.height;
    japaneseName.text = value.japaneseName;
    anime.text = value.sourceTitle;
    archetype.text = value.archetype;
    notes.text = value.personalNotes;
    gender = value.gender;
    mainImagePath = value.mainImagePath;
    galleryImagePaths = [...value.galleryImagePaths];

    for (final entry in value.grades.entries) {
      grades.putIfAbsent(entry.key, TextEditingController.new).text = entry
          .value
          .toString();
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
