import 'package:mycharacterlist/features/characters/domain/entities/character_fact.dart';

class CharacterFactModel extends CharacterFact {
  const CharacterFactModel.text({required super.key, required super.value})
    : super.text();

  const CharacterFactModel.grade({
    required super.key,
    required super.value,
    required super.maximum,
  }) : super.grade();

  factory CharacterFactModel.fromEntity(CharacterFact fact) {
    if (fact.type == CharacterFactType.grade) {
      return CharacterFactModel.grade(
        key: fact.key,
        value: fact.numericValue!,
        maximum: fact.maxValue!,
      );
    }

    return CharacterFactModel.text(key: fact.key, value: fact.textValue ?? '');
  }

  factory CharacterFactModel.fromDatabase(Map<String, Object?> data) {
    if (data['fact_type'] == CharacterFactType.grade) {
      return CharacterFactModel.grade(
        key: data['fact_key']! as String,
        value: data['numeric_value']! as int,
        maximum: data['max_value']! as int,
      );
    }

    return CharacterFactModel.text(
      key: data['fact_key']! as String,
      value: data['fact_value']! as String,
    );
  }

  factory CharacterFactModel.fromJson(Map<String, dynamic> json) {
    if (json['type'] == CharacterFactType.grade) {
      return CharacterFactModel.grade(
        key: json['key'] as String,
        value: json['numericValue'] as int,
        maximum: json['maxValue'] as int,
      );
    }

    return CharacterFactModel.text(
      key: json['key'] as String,
      value: json['textValue'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'type': type,
      'textValue': textValue,
      'numericValue': numericValue,
      'maxValue': maxValue,
    };
  }

  Map<String, Object?> toDatabase({
    required String id,
    required String characterId,
  }) {
    return {
      'id': id,
      'character_id': characterId,
      'fact_key': key,
      'fact_type': type,
      'fact_value': textValue,
      'numeric_value': numericValue,
      'max_value': maxValue,
    };
  }
}
