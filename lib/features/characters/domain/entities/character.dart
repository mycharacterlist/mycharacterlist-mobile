import 'package:mycharacterlist/features/characters/domain/entities/character_gender.dart';
import 'package:mycharacterlist/features/characters/domain/entities/character_fact.dart';

class Character {
  const Character({
    required this.id,
    required this.name,
    required this.sourceTitle,
    required this.createdAt,
    required this.updatedAt,
    this.description = '',
    this.age = '',
    this.height = '',
    this.japaneseName = '',
    this.archetype = '',
    this.gender = CharacterGender.unknown,
    this.personalNotes = '',
    this.mainImagePath,
    this.galleryImagePaths = const [],
    this.grades = const {},
    this.facts = const [],
  });

  final String id;
  final String name;
  final String sourceTitle;
  final String description;
  final String age;
  final String height;
  final String japaneseName;
  final String archetype;
  final String gender;
  final String personalNotes;
  final String? mainImagePath;
  final List<String> galleryImagePaths;
  final Map<String, int> grades;
  final List<CharacterFact> facts;
  final DateTime createdAt;
  final DateTime updatedAt;

  Character copyWith({
    String? id,
    String? name,
    String? sourceTitle,
    String? description,
    String? age,
    String? height,
    String? japaneseName,
    String? archetype,
    String? gender,
    String? personalNotes,
    String? mainImagePath,
    List<String>? galleryImagePaths,
    Map<String, int>? grades,
    List<CharacterFact>? facts,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Character(
      id: id ?? this.id,
      name: name ?? this.name,
      sourceTitle: sourceTitle ?? this.sourceTitle,
      description: description ?? this.description,
      age: age ?? this.age,
      height: height ?? this.height,
      japaneseName: japaneseName ?? this.japaneseName,
      archetype: archetype ?? this.archetype,
      gender: gender ?? this.gender,
      personalNotes: personalNotes ?? this.personalNotes,
      mainImagePath: mainImagePath ?? this.mainImagePath,
      galleryImagePaths: galleryImagePaths ?? this.galleryImagePaths,
      grades: grades ?? this.grades,
      facts: facts ?? this.facts,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
