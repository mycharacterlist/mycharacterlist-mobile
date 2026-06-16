import 'dart:io';

import 'package:mycharacterlist/core/database/app_database.dart';
import 'package:mycharacterlist/core/storage/local_file_storage.dart';
import 'package:mycharacterlist/features/characters/data/models/character_model.dart';
import 'package:mycharacterlist/features/characters/data/sources/local/character_local_data_source.dart';
import 'package:path/path.dart' as p;

/// One-time migration that compresses images saved before upload compression
/// was added. Skips files that are already as small as the compressor can make
/// them, so it is safe to run more than once.
class ImageCompressionMigration {
  ImageCompressionMigration({
    required CharacterLocalDataSource characterLocalDataSource,
    required LocalFileStorage localFileStorage,
  }) : _characterLocalDataSource = characterLocalDataSource,
       _localFileStorage = localFileStorage;

  static const markerFileName = '.image_compression_migration_v1';

  final CharacterLocalDataSource _characterLocalDataSource;
  final LocalFileStorage _localFileStorage;

  static Future<void> runIfNeeded() async {
    final migration = ImageCompressionMigration(
      characterLocalDataSource: CharacterLocalDataSource(
        appDatabase: AppDatabase(),
      ),
      localFileStorage: LocalFileStorage(),
    );
    await migration.migrate();
  }

  Future<void> migrate() async {
    final marker = await _markerFile();
    if (await marker.exists()) {
      return;
    }

    final characters = await _characterLocalDataSource.getCharacters();
    for (final character in characters) {
      await _migrateCharacter(character);
    }

    await marker.writeAsString(DateTime.now().toIso8601String());
  }

  Future<File> _markerFile() async {
    final storageRoot = await _localFileStorage.storageRoot();
    return File(p.join(storageRoot.path, markerFileName));
  }

  Future<String?> _compressPath(String? path) async {
    try {
      return await _localFileStorage.compressStoredFileIfNeeded(path);
    } on Object {
      return path;
    }
  }

  Future<void> _migrateCharacter(CharacterModel character) async {
    final newMainPath = await _compressPath(character.mainImagePath);

    final newGalleryPaths = <String>[];
    for (final path in character.galleryImagePaths) {
      newGalleryPaths.add(await _compressPath(path) ?? path);
    }

    final mainChanged = newMainPath != character.mainImagePath;
    final galleryChanged = !_samePaths(
      character.galleryImagePaths,
      newGalleryPaths,
    );
    if (mainChanged || galleryChanged) {
      await _characterLocalDataSource.saveCharacter(
        CharacterModel.fromEntity(
          character.copyWith(
            mainImagePath: newMainPath,
            galleryImagePaths: newGalleryPaths,
          ),
        ),
      );
    }

    await _localFileStorage.markMigratedImagesAsCompressed(
      character.id,
      [
        newMainPath,
        ...newGalleryPaths,
      ].whereType<String>(),
    );
  }

  bool _samePaths(List<String> left, List<String> right) {
    if (left.length != right.length) {
      return false;
    }

    for (var index = 0; index < left.length; index++) {
      if (left[index] != right[index]) {
        return false;
      }
    }

    return true;
  }
}
