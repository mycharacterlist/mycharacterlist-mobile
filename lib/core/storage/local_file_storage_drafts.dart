part of 'local_file_storage.dart';

class _LocalFileStorageDrafts {
  _LocalFileStorageDrafts(this._storage);

  final LocalFileStorage _storage;

  Future<String> compressAndStagePickedFile(String sourcePath) async {
    final sourceFile = File(sourcePath);

    if (!await sourceFile.exists()) {
      throw StateError('File does not exist: $sourcePath');
    }

    final bytes = await sourceFile.readAsBytes();
    final compressed = await _storage._imageCompressor.compress(
      bytes,
      sourcePath: sourceFile.path,
    );

    if (compressed.bytes.length >= bytes.length) {
      return _storage.saveBytes(
        bytes,
        folder: LocalFileStorage.draftsFolder,
        extension: p.extension(sourceFile.path),
        compress: false,
      );
    }

    return _storage.saveBytes(
      compressed.bytes,
      folder: LocalFileStorage.draftsFolder,
      extension: compressed.extension,
      compress: false,
    );
  }

  Future<void> deleteDraftFile(String? path) async {
    if (path == null || path.trim().isEmpty) {
      return;
    }

    final storageRoot = await _storage._storageRoot();
    final draftsDirectory = Directory(
      p.join(storageRoot.path, LocalFileStorage.draftsFolder),
    );
    final resolvedPath = await _storage.resolveExistingImagePath(path);
    if (resolvedPath == null) {
      return;
    }

    final file = File(resolvedPath);
    final normalizedPath = StoragePathUtils.normalizePathForComparison(
      file.absolute.path,
    );
    final normalizedDraftsDirectory = StoragePathUtils.normalizePathForComparison(
      draftsDirectory.absolute.path,
    );

    if (!StoragePathUtils.isInsideDirectory(
      normalizedPath,
      normalizedDraftsDirectory,
    )) {
      return;
    }

    if (await file.exists()) {
      await file.delete();
    }
  }

  Future<void> deleteDraftFiles(Iterable<String> paths) async {
    for (final path in paths) {
      await deleteDraftFile(path);
    }
  }

  Future<void> clearDraftsFolder() async {
    final storageRoot = await _storage._storageRoot();
    final draftsDirectory = Directory(
      p.join(storageRoot.path, LocalFileStorage.draftsFolder),
    );

    if (!await draftsDirectory.exists()) {
      return;
    }

    await for (final entity in draftsDirectory.list()) {
      if (entity is File) {
        await entity.delete();
      }
    }
  }

  Future<void> clearUnreferencedDraftFiles(Set<String> referencedPaths) async {
    final storageRoot = await _storage._storageRoot();
    final draftsDirectory = Directory(
      p.join(storageRoot.path, LocalFileStorage.draftsFolder),
    );

    if (!await draftsDirectory.exists()) {
      return;
    }

    final referencedBasenames = <String>{};
    for (final path in referencedPaths) {
      if (path.trim().isEmpty) {
        continue;
      }

      referencedBasenames.add(StoragePathUtils.basenameKey(path));

      final resolved = await _storage.resolveExistingImagePath(path);
      if (resolved != null) {
        referencedBasenames.add(p.basename(resolved).toLowerCase());
      }
    }

    await for (final entity in draftsDirectory.list()) {
      if (entity is! File) {
        continue;
      }

      final fileName = p.basename(entity.path).toLowerCase();
      if (referencedBasenames.contains(fileName)) {
        continue;
      }

      await entity.delete();
    }
  }
}
