part of 'local_file_storage.dart';

class _LocalFileStorageMigration {
  _LocalFileStorageMigration(this._storage);

  final LocalFileStorage _storage;

  Future<void> cleanupOrphanedStorage({
    required Set<String> activeCharacterIds,
  }) async {
    final storageRoot = await _storage._storageRoot();
    if (!await storageRoot.exists()) {
      return;
    }

    await for (final entity in storageRoot.list()) {
      if (entity is File) {
        final fileName = p.basename(entity.path);
        if (fileName.startsWith('.')) {
          continue;
        }

        await _storage._deleteIfExists(entity);
        continue;
      }

      if (entity is! Directory) {
        continue;
      }

      final directoryName = p.basename(entity.path);
      if (directoryName.startsWith('.') ||
          directoryName == LocalFileStorage.draftsFolder) {
        continue;
      }

      if (!activeCharacterIds.contains(directoryName)) {
        await entity.delete(recursive: true);
      }
    }
  }

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
      referencedBasenames.add(StoragePathUtils.basenameKey(path));
    }

    trackReference(mainImagePath);
    for (final path in galleryImagePaths) {
      trackReference(path);
    }

    for (final path in [mainImagePath, ...galleryImagePaths]) {
      if (path == null || path.trim().isEmpty) {
        continue;
      }

      final resolved = await _storage.resolveExistingImagePath(
        path,
        characterFolder: characterId,
      );
      if (resolved != null) {
        referencedBasenames.add(p.basename(resolved).toLowerCase());
      } else {
        unresolvedBasenames.add(StoragePathUtils.basenameKey(path));
      }
    }

    final orphanPaths = <String>{};

    await _storage._paths.forEachImageFileInDirectory(
      await _storage._characterDirectory(characterId),
      (file) {
        final fileName = p.basename(file.path).toLowerCase();
        if (referencedBasenames.contains(fileName)) {
          return;
        }
        orphanPaths.add(file.absolute.path);
      },
    );

    final storageRoot = await _storage._storageRoot();
    await _storage._paths.forEachImageFileInDirectory(
      Directory(p.join(storageRoot.path, LocalFileStorage.draftsFolder)),
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
        : await _storage.resolveExistingImagePath(
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
    final resolvedPath = await _storage.resolveExistingImagePath(
      storedPath,
      characterFolder: characterId,
    );
    if (resolvedPath == null) {
      return storedPath;
    }

    try {
      var nextPath = await _storage.saveFile(resolvedPath, folder: characterId);
      nextPath =
          await _storage.compressStoredFileIfNeeded(nextPath) ?? nextPath;
      return nextPath;
    } on Object {
      return storedPath;
    }
  }
}
