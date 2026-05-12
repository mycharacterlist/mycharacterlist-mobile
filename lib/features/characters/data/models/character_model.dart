import 'package:mycharacterlist/features/characters/domain/entities/character.dart';

class CharacterModel extends Character {
  const CharacterModel({
    required super.id,
    required super.name,
    required super.sourceTitle,
    required super.createdAt,
    required super.updatedAt,
    super.description,
    super.age,
    super.height,
    super.japaneseName,
    super.archetype,
    super.gender,
    super.personalNotes,
    super.mainImagePath,
    super.galleryImagePaths,
    super.grades,
  });

  factory CharacterModel.fromEntity(Character character) {
    return CharacterModel(
      id: character.id,
      name: character.name,
      sourceTitle: character.sourceTitle,
      description: character.description,
      age: character.age,
      height: character.height,
      japaneseName: character.japaneseName,
      archetype: character.archetype,
      gender: character.gender,
      personalNotes: character.personalNotes,
      mainImagePath: character.mainImagePath,
      galleryImagePaths: character.galleryImagePaths,
      grades: character.grades,
      createdAt: character.createdAt,
      updatedAt: character.updatedAt,
    );
  }

  factory CharacterModel.fromJson(Map<String, dynamic> json) {
    return CharacterModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sourceTitle: json['sourceTitle'] as String,
      description: json['description'] as String? ?? '',
      age: json['age'] as String? ?? '',
      height: json['height'] as String? ?? '',
      japaneseName: json['japaneseName'] as String? ?? '',
      archetype: json['archetype'] as String? ?? '',
      gender: json['gender'] as String? ?? '',
      personalNotes: json['personalNotes'] as String? ?? '',
      mainImagePath: json['mainImagePath'] as String?,
      galleryImagePaths: List<String>.from(
        json['galleryImagePaths'] as List? ?? const [],
      ),
      grades: Map<String, int>.from(json['grades'] as Map? ?? const {}),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  factory CharacterModel.fromDatabase(
    Map<String, Object?> data, {
    List<String> galleryImagePaths = const [],
    Map<String, int> grades = const {},
  }) {
    return CharacterModel(
      id: data['id']! as String,
      name: data['name']! as String,
      sourceTitle: data['source_title']! as String,
      description: data['description']! as String,
      age: data['age'] as String? ?? '',
      height: data['height'] as String? ?? '',
      japaneseName: data['japanese_name'] as String? ?? '',
      archetype: data['archetype'] as String? ?? '',
      gender: data['gender'] as String? ?? '',
      personalNotes: data['personal_notes'] as String? ?? '',
      mainImagePath: data['main_image_path'] as String?,
      galleryImagePaths: galleryImagePaths,
      grades: grades,
      createdAt: DateTime.parse(data['created_at']! as String),
      updatedAt: DateTime.parse(data['updated_at']! as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sourceTitle': sourceTitle,
      'description': description,
      'age': age,
      'height': height,
      'japaneseName': japaneseName,
      'archetype': archetype,
      'gender': gender,
      'personalNotes': personalNotes,
      'mainImagePath': mainImagePath,
      'galleryImagePaths': galleryImagePaths,
      'grades': grades,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, Object?> toDatabase() {
    return {
      'id': id,
      'name': name,
      'source_title': sourceTitle,
      'description': description,
      'age': age,
      'height': height,
      'japanese_name': japaneseName,
      'archetype': archetype,
      'gender': gender,
      'personal_notes': personalNotes,
      'main_image_path': mainImagePath,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
