import 'package:mycharacterlist/features/characters/domain/entities/character.dart';

abstract interface class CharacterRepository {
  Future<List<Character>> getCharacters();

  Future<List<Character>> getCharactersPage({
    required int offset,
    required int limit,
  });

  Future<Character?> getCharacterById(String id);

  Future<List<Character>> searchCharacters(String query);

  Future<List<Character>> searchCharactersPage(
    String query, {
    required int offset,
    required int limit,
  });

  Future<void> saveCharacter(Character character);

  Future<void> deleteCharacter(String id);
}
