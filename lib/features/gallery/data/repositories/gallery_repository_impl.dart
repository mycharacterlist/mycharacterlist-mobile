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

  @override
  Future<void> addGalleryImages({
    required String characterId,
    required List<String> imagePaths,
    void Function(int completed, int total)? onProgress,
  }) async {
    if (imagePaths.isEmpty) {
      return;
    }

    final total = imagePaths.length;
    var completed = 0;
    final initialCharacter = await _characterRepository.getCharacterById(
      characterId,
    );
    if (initialCharacter == null) {
      throw StateError('Character not found.');
    }
    var character = initialCharacter;

    for (final imagePath in imagePaths) {
      final updatedCharacter = character.copyWith(
        galleryImagePaths: [
          ...character.galleryImagePaths,
          imagePath,
        ],
        updatedAt: DateTime.now(),
      );

      await _characterRepository.saveCharacter(updatedCharacter);
      completed += 1;
      onProgress?.call(completed, total);

      character =
          await _characterRepository.getCharacterById(characterId) ??
          updatedCharacter;
    }
  }
}
