import 'package:mycharacterlist/features/characters/domain/entities/grade_definition.dart';

class GradeDefinitionModel extends GradeDefinition {
  const GradeDefinitionModel({
    required super.id,
    required super.name,
    required super.maxValue,
    required super.position,
  });

  factory GradeDefinitionModel.fromDatabase(Map<String, Object?> data) {
    return GradeDefinitionModel(
      id: data['id']! as String,
      name: data['name']! as String,
      maxValue: data['max_value']! as int,
      position: data['position']! as int,
    );
  }
}
