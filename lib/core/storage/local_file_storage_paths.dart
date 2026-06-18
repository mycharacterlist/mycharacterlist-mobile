part of 'local_file_storage.dart';

extension _LocalFileStoragePaths on LocalFileStorage {
  static const _imageExtensions = {
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
    '.gif',
    '.heic',
  };

  /// Resolves a stored image path to an existing file, including legacy folders.
  Future<String?> resolveExistingImagePath(
    String? path, {
    String? characterFolder,
  }) async {
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    final sanitizedPath = _sanitizeStoredPath(path.trim());
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

  String _basenameKey(String path) {
    return p.basename(_sanitizeStoredPath(path)).toLowerCase();
  }

  bool _isImageFileName(String fileName) {
    if (fileName.startsWith('.')) {
      return false;
    }

    return _imageExtensions.contains(p.extension(fileName).toLowerCase());
  }

  Future<void> _forEachImageFileInDirectory(
    Directory directory,
    void Function(File file) onFile,
  ) async {
    if (!await directory.exists()) {
      return;
    }

    await for (final entity in directory.list()) {
      if (entity is! File) {
        continue;
      }

      final fileName = p.basename(entity.path);
      if (!_isImageFileName(fileName)) {
        continue;
      }

      onFile(entity);
    }
  }

  String _sanitizeStoredPath(String path) {
    var sanitized = path.trim();

    if (sanitized.startsWith('file://')) {
      sanitized = sanitized.substring('file://'.length);
    }

    try {
      sanitized = Uri.decodeComponent(sanitized);
    } on Object {
      // Keep the original path when URI decoding fails.
    }

    return p.normalize(sanitized);
  }

  String _normalizePathForComparison(String path) {
    var normalized = _sanitizeStoredPath(path);

    if (Platform.isIOS || Platform.isMacOS) {
      if (normalized.startsWith('/var/') &&
          !normalized.startsWith('/private/')) {
        normalized = '/private$normalized';
      }
    }

    return normalized;
  }

  bool _isInsideDirectory(String path, String directoryPath) {
    final normalizedPath = _normalizePathForComparison(path);
    final normalizedDirectory = _normalizePathForComparison(directoryPath);
    final directoryPrefix = normalizedDirectory.endsWith('/')
        ? normalizedDirectory
        : '$normalizedDirectory/';

    return normalizedPath == normalizedDirectory ||
        normalizedPath.startsWith(directoryPrefix);
  }

  bool _isInsideDrafts(String path, String storageRootPath) {
    final draftsDirectory = p.join(storageRootPath, draftsFolder);
    return _isInsideDirectory(path, draftsDirectory);
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

      for (final variant in _iosPathVariants(candidate)) {
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

    final storageRoot = await _storageRoot();
    if (characterFolder != null && characterFolder.isNotEmpty) {
      addCandidate(p.join(storageRoot.path, characterFolder, fileName));
      addCandidate(p.join(storageRoot.path, draftsFolder, fileName));
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
    final storageRoot = await _storageRoot();
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
      Directory(p.join(storageRoot.path, draftsFolder)),
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
      if (directoryName.startsWith('.') || directoryName == draftsFolder) {
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

  Iterable<String> _iosPathVariants(String path) sync* {
    final normalized = p.normalize(path);
    yield normalized;

    if (Platform.isIOS || Platform.isMacOS) {
      if (normalized.startsWith('/var/') &&
          !normalized.startsWith('/private/')) {
        yield '/private$normalized';
      }
      if (normalized.startsWith('/private/var/')) {
        yield normalized.substring('/private'.length);
      }
    }
  }

  Future<String?> _rebasePathToCurrentStorageRoot(String path) async {
    final normalized = _normalizePathForComparison(p.normalize(path));
    final marker = '/$storageFolderName/';
    final markerIndex = normalized.indexOf(marker);
    if (markerIndex < 0) {
      return null;
    }

    final suffix = normalized.substring(markerIndex + marker.length);
    if (suffix.isEmpty) {
      return null;
    }

    final storageRoot = await _storageRoot();
    return p.join(storageRoot.path, suffix.replaceAll('\\', '/'));
  }

  String _resolveExtension({
    required String preferredExtension,
    required String fallbackExtension,
  }) {
    if (RegExp(r'^\.[a-zA-Z0-9]+$').hasMatch(preferredExtension)) {
      return preferredExtension;
    }

    if (RegExp(r'^\.[a-zA-Z0-9]+$').hasMatch(fallbackExtension)) {
      return fallbackExtension;
    }

    return '';
  }

  String _uniqueFilePath({
    required String directoryPath,
    required String extension,
  }) {
    return p.join(
      directoryPath,
      '${DateTime.now().microsecondsSinceEpoch}$extension',
    );
  }
}
