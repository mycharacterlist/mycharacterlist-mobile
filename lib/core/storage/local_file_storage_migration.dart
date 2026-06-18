part of 'local_file_storage.dart';

extension _LocalFileStorageMigration on LocalFileStorage {
  /// Removes legacy folders and loose files left behind after images were relocated.
  /// Does not delete files inside active character folders.
  Future<void> cleanupOrphanedStorage({
    required Set<String> activeCharacterIds,
  }) async {
    final storageRoot = await _storageRoot();
    if (!await storageRoot.exists()) {
      return;
    }

    await for (final entity in storageRoot.list()) {
      if (entity is File) {
        final fileName = p.basename(entity.path);
        if (fileName.startsWith('.')) {
          continue;
        }

        await _deleteIfExists(entity);
        continue;
      }

      if (entity is! Directory) {
        continue;
      }

      final directoryName = p.basename(entity.path);
      if (directoryName.startsWith('.') || directoryName == draftsFolder) {
        continue;
      }

      if (!activeCharacterIds.contains(directoryName)) {
        await entity.delete(recursive: true);
      }
    }
  }

  /// Relocates character images into [characterId], compresses when possible,
  /// and returns the final paths to store in SQLite.
  Future<MigratedCharacterImages> migrateCharacterImages({
    required String characterId,
    required String? mainImagePath,
    required List<String> galleryImagePaths,
  }) async {
    final migratedMain = await _migrateImagePath(
      mainImagePath,
      characterId: characterId,
    );

    final migratedGallery = <String>[];
    for (final path in galleryImagePaths) {
      if (path.trim().isEmpty) {
        continue;
      }

      final migratedPath = await _migrateImagePath(
        path,
        characterId: characterId,
      );
      migratedGallery.add(migratedPath ?? path);
    }

    return MigratedCharacterImages(
      mainImagePath: migratedMain,
      galleryImagePaths: migratedGallery,
    );
  }

  /// Re-links image files in [characterId] folder that are not referenced in SQLite.
  Future<MigratedCharacterImages> recoverMissingImageReferences({
    required String characterId,
    required String? mainImagePath,
    required List<String> galleryImagePaths,
  }) async {
    final referencedBasenames = <String>{};
    final unresolvedBasenames = <String>{};

    void trackReference(String? path) {
      if (path == null || path.trim().isEmpty) {
        return;
      }
      referencedBasenames.add(_basenameKey(path));
    }

    trackReference(mainImagePath);
    for (final path in galleryImagePaths) {
      trackReference(path);
    }

    for (final path in [mainImagePath, ...galleryImagePaths]) {
      if (path == null || path.trim().isEmpty) {
        continue;
      }

      final resolved = await resolveExistingImagePath(
        path,
        characterFolder: characterId,
      );
      if (resolved != null) {
        referencedBasenames.add(p.basename(resolved).toLowerCase());
      } else {
        unresolvedBasenames.add(_basenameKey(path));
      }
    }

    final orphanPaths = <String>{};

    await _forEachImageFileInDirectory(
      await _characterDirectory(characterId),
      (file) {
        final fileName = p.basename(file.path).toLowerCase();
        if (referencedBasenames.contains(fileName)) {
          return;
        }
        orphanPaths.add(file.absolute.path);
      },
    );

    final storageRoot = await _storageRoot();
    await _forEachImageFileInDirectory(
      Directory(p.join(storageRoot.path, draftsFolder)),
      (file) {
        final fileName = p.basename(file.path).toLowerCase();
        if (!unresolvedBasenames.contains(fileName)) {
          return;
        }
        if (referencedBasenames.contains(fileName)) {
          return;
        }
        orphanPaths.add(file.absolute.path);
      },
    );

    if (orphanPaths.isEmpty) {
      return MigratedCharacterImages(
        mainImagePath: mainImagePath,
        galleryImagePaths: galleryImagePaths,
      );
    }

    final sortedOrphans = orphanPaths.toList()..sort();

    var nextMain = mainImagePath;
    final nextGallery = List<String>.from(galleryImagePaths);

    final mainResolved = nextMain == null || nextMain.trim().isEmpty
        ? null
        : await resolveExistingImagePath(
            nextMain,
            characterFolder: characterId,
          );

    if (mainResolved == null && sortedOrphans.isNotEmpty) {
      nextMain = sortedOrphans.removeAt(0);
    }

    nextGallery.addAll(sortedOrphans);

    return MigratedCharacterImages(
      mainImagePath: nextMain,
      galleryImagePaths: nextGallery,
    );
  }

  Future<String?> _migrateImagePath(
    String? path, {
    required String characterId,
  }) async {
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    final storedPath = path.trim();
    final resolvedPath = await resolveExistingImagePath(
      storedPath,
      characterFolder: characterId,
    );
    if (resolvedPath == null) {
      return storedPath;
    }

    try {
      var nextPath = await saveFile(resolvedPath, folder: characterId);
      nextPath = await compressStoredFileIfNeeded(nextPath) ?? nextPath;
      return nextPath;
    } on Object {
      return storedPath;
    }
  }
}
