import 'package:mycharacterlist/features/characters/domain/entities/grade_definition.dart';

class CharacterGradeService {
  const CharacterGradeService._();

  static double? calculateOverall({
    required List<GradeDefinition> definitions,
    required Map<String, int> grades,
  }) {
    final validDefinitions = definitions
        .where((definition) => definition.maxValue > 0)
        .toList();

    if (validDefinitions.isEmpty) {
      return null;
    }

    final normalizedSum = validDefinitions.fold<double>(0, (sum, definition) {
      final value = grades[definition.id] ?? 0;
      return sum + value / definition.maxValue;
    });

    return (normalizedSum / validDefinitions.length) * 10;
  }

  static String formatOverall(double overall) {
    final rounded = (overall * 100).round() / 100;
    return '${_formatScore(rounded)}/10';
  }

  static String _formatScore(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    var text = value.toStringAsFixed(2);
    while (text.contains('.') && text.endsWith('0')) {
      text = text.substring(0, text.length - 1);
    }

    return text;
  }
}
