import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

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

/// One-time migration that relocates legacy images into character folders,
/// compresses them when possible, and fixes stored paths in SQLite.
class ImageCompressionMigration {
  ImageCompressionMigration({
    required CharacterLocalDataSource characterLocalDataSource,
    required LocalFileStorage localFileStorage,
  }) : _characterLocalDataSource = characterLocalDataSource,
       _localFileStorage = localFileStorage;

  static const markerFileName = '.image_compression_migration_v3';
  static const progressFileName = '.image_compression_migration_v3_progress';
  static const legacyMarkerFileName = '.image_compression_migration_v1';
  static const supersededMarkerFileName = '.image_compression_migration_v2';

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

      try {
        await _migrateCharacter(character);
      } on Object catch (error, stackTrace) {
        debugPrint(
          'Image migration failed for ${character.id}: $error\n$stackTrace',
        );
      }

      completedIds.add(character.id);
      await _writeProgress(completedIds);
      report(completedIds.length);
    }

    await _localFileStorage.cleanupOrphanedStorage(
      activeCharacterIds: (await _characterLocalDataSource.getCharacters())
          .map((character) => character.id)
          .toSet(),
    );

    final referencedPaths = <String>{};
    for (final character in await _characterLocalDataSource.getCharacters()) {
      referencedPaths.addAll(
        _collectPaths(
          mainImagePath: character.mainImagePath,
          galleryImagePaths: character.galleryImagePaths,
        ),
      );
    }
    await _localFileStorage.clearUnreferencedDraftFiles(referencedPaths);
    await marker.writeAsString(DateTime.now().toIso8601String());
    await _deleteProgress();
    await _deleteLegacyMarker();
    await _deleteSupersededMarker();
  }

  Future<void> _migrateCharacter(CharacterModel character) async {
    final previousPaths = _collectPaths(
      mainImagePath: character.mainImagePath,
      galleryImagePaths: character.galleryImagePaths,
    );

    final recovered = await _localFileStorage.recoverMissingImageReferences(
      characterId: character.id,
      mainImagePath: character.mainImagePath,
      galleryImagePaths: character.galleryImagePaths,
    );

    final migrated = await _localFileStorage.migrateCharacterImages(
      characterId: character.id,
      mainImagePath: recovered.mainImagePath,
      galleryImagePaths: recovered.galleryImagePaths,
    );

    final updatedCharacter = character.copyWith(
      mainImagePath: migrated.mainImagePath,
      galleryImagePaths: migrated.galleryImagePaths,
    );

    final pathsChanged =
        updatedCharacter.mainImagePath != character.mainImagePath ||
        !_samePaths(
          updatedCharacter.galleryImagePaths,
          character.galleryImagePaths,
        );

    if (pathsChanged) {
      await _characterLocalDataSource.saveCharacter(
        CharacterModel.fromEntity(updatedCharacter),
      );
    }

    final nextPaths = _collectPaths(
      mainImagePath: updatedCharacter.mainImagePath,
      galleryImagePaths: updatedCharacter.galleryImagePaths,
    );

    await _localFileStorage.deleteFiles(
      previousPaths.difference(nextPaths).toList(),
      characterFolder: character.id,
    );

    await _localFileStorage.syncCompressedManifest(
      character.id,
      nextPaths,
    );
  }

  Set<String> _collectPaths({
    required String? mainImagePath,
    required List<String> galleryImagePaths,
  }) {
    return {
      if (mainImagePath != null && mainImagePath.trim().isNotEmpty) mainImagePath,
      ...galleryImagePaths.where((path) => path.trim().isNotEmpty),
    };
  }

  Future<File> _markerFile() async {
    final storageRoot = await _localFileStorage.storageRoot();
    return File(p.join(storageRoot.path, markerFileName));
  }

  Future<File> _progressFile() async {
    final storageRoot = await _localFileStorage.storageRoot();
    return File(p.join(storageRoot.path, progressFileName));
  }

  Future<void> _deleteSupersededMarker() async {
    final storageRoot = await _localFileStorage.storageRoot();
    for (final markerName in {
      supersededMarkerFileName,
      '.image_compression_migration_v2_progress',
    }) {
      final marker = File(p.join(storageRoot.path, markerName));
      if (await marker.exists()) {
        await marker.delete();
      }
    }
  }

  Future<void> _deleteLegacyMarker() async {
    final storageRoot = await _localFileStorage.storageRoot();
    final legacyMarker = File(
      p.join(storageRoot.path, legacyMarkerFileName),
    );
    if (await legacyMarker.exists()) {
      await legacyMarker.delete();
    }
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
