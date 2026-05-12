import 'package:mycharacterlist/features/characters/domain/entities/character.dart';

abstract interface class CharacterRepository {
  Future<List<Character>> getCharacters();

  Future<Character?> getCharacterById(String id);

  Future<List<Character>> searchCharacters(String query);

  Future<void> saveCharacter(Character character);

  Future<void> deleteCharacter(String id);
}
