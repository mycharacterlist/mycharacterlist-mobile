part of 'local_file_storage.dart';

extension _LocalFileStorageDrafts on LocalFileStorage {
  /// Compresses a picked image immediately and stores it in [draftsFolder].
  Future<String> compressAndStagePickedFile(String sourcePath) async {
    final sourceFile = File(sourcePath);

    if (!await sourceFile.exists()) {
      throw StateError('File does not exist: $sourcePath');
    }

    final bytes = await sourceFile.readAsBytes();
    final compressed = await _imageCompressor.compress(
      bytes,
      sourcePath: sourceFile.path,
    );

    if (compressed.bytes.length >= bytes.length) {
      return saveBytes(
        bytes,
        folder: draftsFolder,
        extension: p.extension(sourceFile.path),
        compress: false,
      );
    }

    return saveBytes(
      compressed.bytes,
      folder: draftsFolder,
      extension: compressed.extension,
      compress: false,
    );
  }

  Future<void> deleteDraftFile(String? path) async {
    if (path == null || path.trim().isEmpty) {
      return;
    }

    final storageRoot = await _storageRoot();
    final draftsDirectory = Directory(p.join(storageRoot.path, draftsFolder));
    final resolvedPath = await resolveExistingImagePath(path);
    if (resolvedPath == null) {
      return;
    }

    final file = File(resolvedPath);
    final normalizedPath = _normalizePathForComparison(file.absolute.path);
    final normalizedDraftsDirectory = _normalizePathForComparison(
      draftsDirectory.absolute.path,
    );

    if (!_isInsideDirectory(normalizedPath, normalizedDraftsDirectory)) {
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

  /// Removes leftover files from [draftsFolder] after they were moved to a
  /// character folder or when the form is abandoned.
  Future<void> clearDraftsFolder() async {
    final storageRoot = await _storageRoot();
    final draftsDirectory = Directory(p.join(storageRoot.path, draftsFolder));

    if (!await draftsDirectory.exists()) {
      return;
    }

    await for (final entity in draftsDirectory.list()) {
      if (entity is File) {
        await entity.delete();
      }
    }
  }

  /// Deletes draft files that are not referenced by any stored character path.
  Future<void> clearUnreferencedDraftFiles(Set<String> referencedPaths) async {
    final storageRoot = await _storageRoot();
    final draftsDirectory = Directory(p.join(storageRoot.path, draftsFolder));

    if (!await draftsDirectory.exists()) {
      return;
    }

    final referencedBasenames = <String>{};
    for (final path in referencedPaths) {
      if (path.trim().isEmpty) {
        continue;
      }

      referencedBasenames.add(_basenameKey(path));

      final resolved = await resolveExistingImagePath(path);
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
