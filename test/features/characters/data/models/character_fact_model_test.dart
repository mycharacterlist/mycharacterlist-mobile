import 'package:flutter_test/flutter_test.dart';

import 'package:mycharacterlist/features/characters/data/models/character_fact_model.dart';

void main() {
  test('serializes and restores a text fact', () {
    const fact = CharacterFactModel.text(key: 'Favorite food', value: 'Pizza');

    final restored = CharacterFactModel.fromJson(fact.toJson());

    expect(restored.key, 'Favorite food');
    expect(restored.textValue, 'Pizza');
    expect(restored.numericValue, isNull);
    expect(restored.maxValue, isNull);
  });

  test('serializes and restores a grade fact with custom maximum', () {
    const fact = CharacterFactModel.grade(
      key: 'Power',
      value: 80,
      maximum: 100,
    );

    final restored = CharacterFactModel.fromJson(fact.toJson());

    expect(restored.key, 'Power');
    expect(restored.numericValue, 80);
    expect(restored.maxValue, 100);
    expect(restored.textValue, isNull);
  });
}
