import 'dart:convert';
import 'dart:io';

import 'package:mycharacterlist/core/database/app_database.dart';
import 'package:mycharacterlist/core/storage/local_file_storage.dart';
import 'package:mycharacterlist/features/characters/data/models/character_model.dart';
import 'package:mycharacterlist/features/characters/data/sources/local/character_local_data_source.dart';
import 'package:path/path.dart' as p;

class ImageCompressionMigrationProgress {
  const ImageCompressionMigrationProgress({
    required this.completed,
    required this.total,
  });

  final int completed;
  final int total;

  String get title => 'Updating photos...';
}

typedef ImageCompressionMigrationProgressCallback =
    void Function(ImageCompressionMigrationProgress progress);

/// One-time migration that compresses images saved before upload compression
/// was added. Skips files that are already as small as the compressor can make
/// them. Progress is saved after each character so a closed app can resume.
class ImageCompressionMigration {
  ImageCompressionMigration({
    required CharacterLocalDataSource characterLocalDataSource,
    required LocalFileStorage localFileStorage,
  }) : _characterLocalDataSource = characterLocalDataSource,
       _localFileStorage = localFileStorage;

  static const markerFileName = '.image_compression_migration_v1';
  static const progressFileName = '.image_compression_migration_v1_progress';

  final CharacterLocalDataSource _characterLocalDataSource;
  final LocalFileStorage _localFileStorage;

  static Future<void> runIfNeeded({
    ImageCompressionMigrationProgressCallback? onProgress,
  }) async {
    final migration = ImageCompressionMigration(
      characterLocalDataSource: CharacterLocalDataSource(
        appDatabase: AppDatabase(),
      ),
      localFileStorage: LocalFileStorage(),
    );
    await migration.migrate(onProgress: onProgress);
  }

  Future<void> migrate({
    ImageCompressionMigrationProgressCallback? onProgress,
  }) async {
    final marker = await _markerFile();
    if (await marker.exists()) {
      return;
    }

    final characters = await _characterLocalDataSource.getCharacters();
    final total = characters.length;
    final completedIds = await _readProgress();

    void report(int completed) {
      onProgress?.call(
        ImageCompressionMigrationProgress(
          completed: completed,
          total: total,
        ),
      );
    }

    report(completedIds.length);

    for (final character in characters) {
      if (completedIds.contains(character.id)) {
        continue;
      }

      await _migrateCharacter(character);
      completedIds.add(character.id);
      await _writeProgress(completedIds);
      report(completedIds.length);
    }

    await marker.writeAsString(DateTime.now().toIso8601String());
    await _deleteProgress();
  }

  Future<File> _markerFile() async {
    final storageRoot = await _localFileStorage.storageRoot();
    return File(p.join(storageRoot.path, markerFileName));
  }

  Future<File> _progressFile() async {
    final storageRoot = await _localFileStorage.storageRoot();
    return File(p.join(storageRoot.path, progressFileName));
  }

  Future<Set<String>> _readProgress() async {
    final file = await _progressFile();
    if (!await file.exists()) {
      return {};
    }

    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) {
        return {};
      }

      final rawIds = decoded['completedCharacterIds'];
      if (rawIds is! List) {
        return {};
      }

      return rawIds.map((id) => id.toString()).toSet();
    } on Object {
      return {};
    }
  }

  Future<void> _writeProgress(Set<String> completedCharacterIds) async {
    final file = await _progressFile();
    final sortedIds = completedCharacterIds.toList()..sort();
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'completedCharacterIds': sortedIds,
      }),
    );
  }

  Future<void> _deleteProgress() async {
    final file = await _progressFile();
    if (await file.exists()) {
      await file.delete();
    }
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

    await _localFileStorage.markMigrationProcessedImages(
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
