class CharacterGender {
  const CharacterGender._();

  static const female = 'female';
  static const male = 'male';
  static const unknown = 'unknown';

  static const values = [female, male, unknown];

  static String normalize(String value) {
    final normalizedValue = value.trim().toLowerCase();

    if (values.contains(normalizedValue)) {
      return normalizedValue;
    }

    return unknown;
  }
}
