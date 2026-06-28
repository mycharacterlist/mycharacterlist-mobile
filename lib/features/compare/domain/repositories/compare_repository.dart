import 'package:mycharacterlist/features/characters/domain/entities/character.dart';

abstract interface class CompareRepository {
  Future<List<Character>> getCharactersForCompare();

  Future<List<String>> getAnimeTitlesForCompare();
}
