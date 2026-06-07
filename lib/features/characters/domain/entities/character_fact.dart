class CharacterFactType {
  const CharacterFactType._();

  static const text = 'text';
  static const grade = 'grade';
}

class CharacterFact {
  const CharacterFact.text({required this.key, required String value})
    : type = CharacterFactType.text,
      textValue = value,
      numericValue = null,
      maxValue = null;

  const CharacterFact.grade({
    required this.key,
    required int value,
    required int maximum,
  }) : type = CharacterFactType.grade,
       textValue = null,
       numericValue = value,
       maxValue = maximum;

  final String key;
  final String type;
  final String? textValue;
  final int? numericValue;
  final int? maxValue;
}
