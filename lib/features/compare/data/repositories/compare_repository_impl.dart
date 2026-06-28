import 'package:mycharacterlist/features/characters/domain/entities/character.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_repository.dart';
import 'package:mycharacterlist/features/characters/domain/repositories/character_reference_repository.dart';
import 'package:mycharacterlist/features/compare/domain/repositories/compare_repository.dart';

class CompareRepositoryImpl implements CompareRepository {
  const CompareRepositoryImpl({
    required CharacterRepository characterRepository,
    required CharacterReferenceRepository referenceRepository,
  }) : _characterRepository = characterRepository,
       _referenceRepository = referenceRepository;

  final CharacterRepository _characterRepository;
  final CharacterReferenceRepository _referenceRepository;

  @override
  Future<List<Character>> getCharactersForCompare() {
    return _characterRepository.getCharacterSummaries();
  }

  @override
  Future<List<String>> getAnimeTitlesForCompare() {
    return _referenceRepository.getAnimeTitles();
  }
}
