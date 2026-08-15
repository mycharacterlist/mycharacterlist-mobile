part of 'local_file_storage.dart';

class _LocalFileStoragePaths {
  _LocalFileStoragePaths(this._storage);

  final LocalFileStorage _storage;

  Future<String?> resolveExistingImagePath(
    String? path, {
    String? characterFolder,
  }) async {
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    final sanitizedPath = StoragePathUtils.sanitizeStoredPath(path.trim());
    final candidates = await _buildPathResolutionCandidates(
      sanitizedPath,
      characterFolder: characterFolder,
    );

    for (final candidate in candidates) {
      final file = File(candidate);
      if (await file.exists()) {
        return file.absolute.path;
      }
    }

    return null;
  }

  Future<List<String>> _buildPathResolutionCandidates(
    String path, {
    String? characterFolder,
  }) async {
    final seen = <String>{};
    final candidates = <String>[];

    void addCandidate(String? candidate) {
      if (candidate == null || candidate.isEmpty) {
        return;
      }

      for (final variant in StoragePathUtils.iosPathVariants(candidate)) {
        if (seen.add(variant)) {
          candidates.add(variant);
        }
      }
    }

    addCandidate(p.normalize(path));

    final rebasedPath = await _rebasePathToCurrentStorageRoot(path);
    addCandidate(rebasedPath);

    final fileName = p.basename(p.normalize(path));
    if (fileName.isEmpty) {
      return candidates;
    }

    final storageRoot = await _storage._storageRoot();
    if (characterFolder != null && characterFolder.isNotEmpty) {
      addCandidate(p.join(storageRoot.path, characterFolder, fileName));
      addCandidate(
        p.join(storageRoot.path, LocalFileStorage.draftsFolder, fileName),
      );
    }

    addCandidate(p.join(storageRoot.path, fileName));

    final discoveredPath = await _findImageByBasename(
      fileName,
      characterFolder: characterFolder,
    );
    addCandidate(discoveredPath);

    return candidates;
  }

  Future<String?> _findImageByBasename(
    String fileName, {
    String? characterFolder,
  }) async {
    final storageRoot = await _storage._storageRoot();
    final normalizedFileName = fileName.toLowerCase();

    if (characterFolder != null && characterFolder.isNotEmpty) {
      final match = await _findBasenameInDirectory(
        Directory(p.join(storageRoot.path, characterFolder)),
        normalizedFileName,
      );
      if (match != null) {
        return match;
      }
    }

    final draftsMatch = await _findBasenameInDirectory(
      Directory(p.join(storageRoot.path, LocalFileStorage.draftsFolder)),
      normalizedFileName,
    );
    if (draftsMatch != null) {
      return draftsMatch;
    }

    if (!await storageRoot.exists()) {
      return null;
    }

    await for (final entity in storageRoot.list()) {
      if (entity is! Directory) {
        continue;
      }

      final directoryName = p.basename(entity.path);
      if (directoryName.startsWith('.') ||
          directoryName == LocalFileStorage.draftsFolder) {
        continue;
      }

      final match = await _findBasenameInDirectory(entity, normalizedFileName);
      if (match != null) {
        return match;
      }
    }

    return null;
  }

  Future<String?> _findBasenameInDirectory(
    Directory directory,
    String normalizedFileName,
  ) async {
    if (!await directory.exists()) {
      return null;
    }

    await for (final entity in directory.list()) {
      if (entity is! File) {
        continue;
      }

      if (p.basename(entity.path).toLowerCase() == normalizedFileName) {
        return entity.absolute.path;
      }
    }

    return null;
  }

  Future<String?> _rebasePathToCurrentStorageRoot(String path) async {
    final normalized = StoragePathUtils.normalizePathForComparison(
      p.normalize(path),
    );
    final marker = '/${LocalFileStorage.storageFolderName}/';
    final markerIndex = normalized.indexOf(marker);
    if (markerIndex < 0) {
      return null;
    }

    final suffix = normalized.substring(markerIndex + marker.length);
    if (suffix.isEmpty) {
      return null;
    }

    final storageRoot = await _storage._storageRoot();
    return p.join(storageRoot.path, suffix.replaceAll('\\', '/'));
  }
}
