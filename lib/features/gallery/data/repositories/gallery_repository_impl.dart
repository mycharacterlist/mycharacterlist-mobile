import 'package:mycharacterlist/features/characters/domain/repositories/character_repository.dart';
import 'package:mycharacterlist/features/gallery/domain/repositories/gallery_repository.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  const GalleryRepositoryImpl({
    required CharacterRepository characterRepository,
  }) : _characterRepository = characterRepository;

  final CharacterRepository _characterRepository;

  @override
  Future<List<String>> getGalleryImagePaths(String characterId) async {
    final character = await _characterRepository.getCharacterById(characterId);
    return character?.galleryImagePaths ?? const [];
  }
}
