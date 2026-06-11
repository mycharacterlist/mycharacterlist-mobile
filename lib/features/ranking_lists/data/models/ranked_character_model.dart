import 'package:mycharacterlist/features/ranking_lists/domain/entities/ranked_character.dart';

class RankedCharacterModel extends RankedCharacter {
  const RankedCharacterModel({
    required super.id,
    required super.listId,
    required super.characterId,
    required super.position,
    required super.addedAt,
  });

  factory RankedCharacterModel.fromEntity(RankedCharacter rankedCharacter) {
    return RankedCharacterModel(
      id: rankedCharacter.id,
      listId: rankedCharacter.listId,
      characterId: rankedCharacter.characterId,
      position: rankedCharacter.position,
      addedAt: rankedCharacter.addedAt,
    );
  }

  factory RankedCharacterModel.fromJson(Map<String, dynamic> json) {
    return RankedCharacterModel(
      id: json['id'] as String,
      listId: json['listId'] as String,
      characterId: json['characterId'] as String,
      position: json['position'] as int,
      addedAt: DateTime.parse(json['addedAt'] as String),
    );
  }

  factory RankedCharacterModel.fromDatabase(Map<String, Object?> data) {
    return RankedCharacterModel(
      id: data['id']! as String,
      listId: data['list_id']! as String,
      characterId: data['character_id']! as String,
      position: data['position']! as int,
      addedAt: DateTime.parse(data['added_at']! as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'listId': listId,
      'characterId': characterId,
      'position': position,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  Map<String, Object?> toDatabase() {
    return {
      'id': id,
      'list_id': listId,
      'character_id': characterId,
      'position': position,
      'added_at': addedAt.toIso8601String(),
    };
  }
}
